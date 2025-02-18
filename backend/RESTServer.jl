using Distributed

if nprocs() <= 1
   addprocs(1)
end

@everywhere begin
   cd(@__DIR__)
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
end

using Oxygen
using HTTP
using SwaggerMarkdown

using StatsBase, FFTW
using StructTypes

@everywhere begin
   using KomaMRI
   using LinearAlgebra
   using JSON3
   # using CUDA #TODO: Find a way to choose between CPU and GPU
end

dynamic_files_path = string(@__DIR__, "/../frontend/dist")
dynamicfiles(dynamic_files_path, "dynamic") 
staticfiles("../public", "public") 

# ---------------------------- GLOBAL VARIABLES --------------------------------
# These won't be necessary once the simulation-process 
# correspondence table is implemented

global simulationId = 1
global simProgress = -1
global statusFile = ""
global result = nothing

# ------------------------------ FUNCTIONS ------------------------------------
@everywhere begin
   include("ServerFunctions.jl")

   """Updates simulation progress and writes it in a file."""
   function KomaMRICore.update_blink_window_progress!(w::String, block, Nblocks)
      io = open(w,"w") # "w" mode overwrites last status value, even if it was not read yet
      progress = trunc(Int, block / Nblocks * 100)
      write(io,progress)
      close(io)
      return nothing
   end
end

# ---------------------------- API METHODS ---------------------------------
## RENDER HTML
@swagger """
/:
   get:
      tags:
      - web
      summary: Redirect to the app
      description: Redirect to the app
      responses:
         '301':
            description: Redirect to /app
            headers:
              Location:
                description: URL with the app
                schema:
                  type: string
                  format: uri
         default:
            description: Always returns a 301 redirect to /app
            headers:
              Location:
                schema:
                  type: string
                  example: "/app"
"""
@get "/" function(req::HTTP.Request)
   return HTTP.Response(301, ["Location" => "/app"])
end

@swagger """
/app:
   get:
      tags:
      - web
      summary: Get the app and the web content
      description: Get the app and the web content
      responses:
         '200':
            description: App and web content
            content:
              text/html:
                schema:
                  format: html
         '404':
            description: Not found
         '500':
            description: Internal server error
"""
@get "/app" function(req::HTTP.Request)
   return render_html(dynamic_files_path * "/index.html")
end

## SIMULATION
@swagger """
/simulate:
   post:
      tags:
      - simulation
      summary: Add a new simulation request
      description: Add a new simulation request
      requestBody:
         required: true
         content:
            application/json:
               schema:
                  type: object
                  properties:
                     phantom:
                        type: string
                     sequence:
                        type: object
                     scanner:
                        type: object
               example:
                  phantom: "Brain 2D"
                  sequence: {
                     "blocks": [
                        {
                              "children": [],
                              "cod": 1,
                              "duration": 1e-3,
                              "gradients": [
                                 {
                                    "amplitude": 1e-3,
                                    "axis": "x",
                                    "delay": 0,
                                    "flatTop": 1e-3,
                                    "rise": 5e-4,
                                    "step": 0
                                 },
                                 {
                                    "amplitude": 0,
                                    "axis": "y",
                                    "delay": 0,
                                    "flatTop": 0,
                                    "rise": 0,
                                    "step": 0
                                 },
                                 {
                                    "amplitude": 0,
                                    "axis": "z",
                                    "delay": 0,
                                    "flatTop": 0,
                                    "rise": 0,
                                    "step": 0
                                 }
                              ],
                              "name": "",
                              "ngroups": 0,
                              "rf": [
                                 {
                                    "deltaf": 0,
                                    "flipAngle": 10,
                                    "shape": 0
                                 }
                              ]
                        },
                        {
                           "adcDelay": 0,
                           "children": [],
                           "cod": 4,
                           "duration": 1e-3,
                           "gradients": [
                              {
                                 "amplitude": 1e-3,
                                 "axis": "x",
                                 "delay": 0,
                                 "flatTop": 1e-3,
                                 "rise": 5e-4,
                                 "step": 0
                              },
                              {
                                 "amplitude": 0,
                                 "axis": "y",
                                 "delay": 0,
                                 "flatTop": 0,
                                 "rise": 0,
                                 "step": 0
                              },
                              {
                                 "amplitude": 0,
                                 "axis": "z",
                                 "delay": 0,
                                 "flatTop": 0,
                                 "rise": 0,
                                 "step": 0
                              }
                           ],
                           "name": "",
                           "ngroups": 0,
                           "samples": 64
                        }
                     ],
                     "description": "Simple RF pulse and ADC sequence",
                  }
                  scanner: {
                     "parameters": {
                        "b0": 1.5,
                        "b1": 10e-6,
                        "deltat": 2e-6,
                        "gmax": 60e-3,
                        "smax": 500
                     },
                  }
      responses:
         '202':
            description: Accepted operation
            headers:
              Location:
                description: URL with the simulation ID, to check the status of the simulation
                schema:
                  type: string
                  format: uri
         '400':
            description: Invalid input
         '500':
            description: Internal server error
"""
@post "/simulate" function(req::HTTP.Request)
   global statusFile = tempname()
   touch(statusFile)

   scanner_json   = json(req)["scanner"]
   sequence_json  = json(req)["sequence"]
   phantom_string = json(req)["phantom"]

   # Simulation  (asynchronous. It should not block the HTTP 202 Response)
   global result = @spawnat 2 sim(sequence_json, scanner_json, phantom_string, statusFile) # Process 2 executes simulation

   # while 1==1
   #    io = open(statusFile,"r")
   #    if (!eof(io))
   #       global simProgress = read(io,Int32)
   #       print("leido\n")
   #    end
   #    close(io)
   #    print("Progreso: ", simProgress, '\n')
   #    sleep(0.2)
   # end

   # TODO: Update simulation-process correspondence table

   headers = ["Location" => string("/simulate/",simulationId)]
   global simulationId += 1
   # 202: Partial Content
   return HTTP.Response(202,headers)
end

@swagger """
/simulate/{simulationId}:
   get:
      tags:
      - simulation
      summary: Get the result of a simulation
      description: Get the result of a simulation. If the simulation has finished, it returns its result. If not, it returns 303 with location = /simulate/{simulationId}/status
      parameters:
         - in: path
           name: simulationId
           required: true
           description: The ID of the simulation
           schema:
              type: integer
              example: 1
         - in: query
           name: width
           description: Width of the image
           schema:
              type: integer
              example: 800
         - in: query 
           name: height
           description: Height of the image
           schema:
              type: integer
              example: 600
      responses:
         '200':
            description: Simulation result
            content:
              text/html:
                schema:
                  format: html
         '303':
            description: Simulation not finished yet
            headers:
              Location:
                description: URL with the simulation status
                schema:
                  type: string
                  format: uri
         '404':
            description: Simulation not found
         '500':
            description: Internal server error
"""
@get "/simulate/{simulationId}" function(req::HTTP.Request, simulationId, width::Int, height::Int)
   io = open(statusFile,"r")
   if (!eof(io))
      global simProgress = read(io,Int32)
   end
   close(io)
   if simProgress < 101      # Simulation not started or in progress
      headers = ["Location" => string("/simulate/",simulationId,"/status")]
      return HTTP.Response(303,headers)
   elseif simProgress == 101  # Simulation finished
      global simProgress = -1 # TODO: this won't be necessary once the simulation-process correspondence table is implemented 
      width  = width  - 15
      height = height - 20
      im = fetch(result)      # TODO: once the simulation-process correspondence table is implemented, this will be replaced by the corresponding image 
      p = plot_image(abs.(im[:,:,1]); darkmode=true, width=width, height=height)
      html_buffer = IOBuffer()
      KomaMRIPlots.PlotlyBase.to_html(html_buffer, p.plot)
      return HTTP.Response(200,body=take!(html_buffer))
   end
end

@swagger """
/simulate/{simulationId}/status:
   get:
      tags:
      - simulation
      summary: Get the status of a simulation
      description: |
         Get the status of a simulation:
         - If the simulation has not started yet, it returns -1
         - If the simulation is running, it returns a value between 0 and 100
         - If the simulation has finished but the reconstruction is in progress, it returns 100
         - If the reconstruction has finished, it returns 101
      parameters:
         - in: path
           name: simulationId
           required: true
           description: The ID of the simulation
           schema:
              type: integer
              example: 1
      responses:
         '200':
            description: Simulation status
            content:
              application/json:
                schema:
                  type: object
                  properties:
                     progress:
                        type: integer
                        description: Simulation progress
         '404':
            description: Simulation not found
         '500':
            description: Internal server error
"""
@get "/simulate/{simulationId}/status" function(req::HTTP.Request, simulationId)
   return HTTP.Response(200,body=JSON3.write(simProgress))
end

# PLOT SEQUENCE
@swagger """
/plot:
   post:
      tags:
      - plot
      summary: Plot a sequence
      description: Plot a sequence
      requestBody:
         required: true
         content:
            application/json:
               schema:
                  type: object
                  properties:
                     scanner:
                        type: object
                     sequence:
                        type: object
                     width:
                        type: integer
                     height:
                        type: integer
               example:
                  scanner: {
                     "parameters": {
                        "b0": 1.5,
                        "b1": 10e-6,
                        "deltat": 2e-6,
                        "gmax": 60e-3,
                        "smax": 500
                     },
                  }
                  sequence: {
                     "blocks": [
                        {
                              "children": [],
                              "cod": 1,
                              "duration": 1e-3,
                              "gradients": [
                                 {
                                    "amplitude": 1e-3,
                                    "axis": "x",
                                    "delay": 0,
                                    "flatTop": 1e-3,
                                    "rise": 5e-4,
                                    "step": 0
                                 },
                                 {
                                    "amplitude": 0,
                                    "axis": "y",
                                    "delay": 0,
                                    "flatTop": 0,
                                    "rise": 0,
                                    "step": 0
                                 },
                                 {
                                    "amplitude": 0,
                                    "axis": "z",
                                    "delay": 0,
                                    "flatTop": 0,
                                    "rise": 0,
                                    "step": 0
                                 }
                              ],
                              "name": "",
                              "ngroups": 0,
                              "rf": [
                                 {
                                    "deltaf": 0,
                                    "flipAngle": 10,
                                    "shape": 0
                                 }
                              ]
                        },
                        {
                           "adcDelay": 0,
                           "children": [],
                           "cod": 4,
                           "duration": 1e-3,
                           "gradients": [
                              {
                                 "amplitude": 1e-3,
                                 "axis": "x",
                                 "delay": 0,
                                 "flatTop": 1e-3,
                                 "rise": 5e-4,
                                 "step": 0
                              },
                              {
                                 "amplitude": 0,
                                 "axis": "y",
                                 "delay": 0,
                                 "flatTop": 0,
                                 "rise": 0,
                                 "step": 0
                              },
                              {
                                 "amplitude": 0,
                                 "axis": "z",
                                 "delay": 0,
                                 "flatTop": 0,
                                 "rise": 0,
                                 "step": 0
                              }
                           ],
                           "name": "",
                           "ngroups": 0,
                           "samples": 64
                        }
                     ],
                     "description": "Simple RF pulse and ADC sequence",
                  }
                  width: 800
                  height: 600
      responses: 
         '200':
            description: Plot of the sequence
            content:
              text/html:
                schema:
                  format: html
         '400':
            description: Invalid input
         '500':
            description: Internal server error
"""
@post "/plot" function(req::HTTP.Request)
   scanner_data = json(req)["scanner"]
   seq_data     = json(req)["sequence"]
   width  = json(req)["width"]  - 15
   height = json(req)["height"] - 20
   sys = json_to_scanner(scanner_data)
   seq = json_to_sequence(seq_data, sys)
   p = plot_seq(seq; darkmode=true, width=width, height=height, slider=height>275)
   html_buffer = IOBuffer()
   KomaMRIPlots.PlotlyBase.to_html(html_buffer, p.plot)
   return HTTP.Response(200,body=take!(html_buffer))
end
# ---------------------------------------------------------------------------

# title and version are required
info = Dict("title" => "WebMRISeq API", "version" => "1.0.0")
openApi = OpenAPI("3.0", info)
swagger_document = build(openApi)
  
# # merge the SwaggerMarkdown schema with the internal schema
setschema(swagger_document)

serve(host="0.0.0.0",port=8085)
