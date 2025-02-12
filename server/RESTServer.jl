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

using StatsBase, FFTW
using StructTypes

@everywhere begin
   using KomaMRI
   using LinearAlgebra
   using JSON3
   using CUDA
end

dynamic_files_path = string(@__DIR__, "/../client/dist")
dynamicfiles(dynamic_files_path, "dynamic") 
staticfiles("../public", "public") 

# ------------------------------- STRUCTS ------------------------------------
global simulationId = 1
global simProgress = -1
global statusFile = ""

mutable struct Image
   # id::Int
   data::Array{Float32,2}
end

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
@get "/" function(req::HTTP.Request)
   return HTTP.Response(301, ["Location" => "/editor"])
end

@get "/editor" function(req::HTTP.Request)
   return render_html(dynamic_files_path * "/index.html")
end

@get "/greet" function(req::HTTP.Request)
   return "Hello world!"
end

## SIMULATION
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

"""
                  [ -1,      if the simulation has not started yet
    simProgress = [ (0,100), if the simulation is running
                  [ 100,     if the simulation has finished, reconstructing
                  [ 101,     if the reconstruction has finished
"""


"""If the simulation has finished, it returns its result. If not, it returns 303 with location = /simulate/{simulationId}/status"""

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
      println("Height: ", typeof(height))
      println("Width: ", typeof(width))
      im = fetch(result)      # TODO: once the simulation-process correspondence table is implemented, this will be replaced by the corresponding image 
      p = plot_image(abs.(im[:,:,1]); darkmode=true, width=width, height=height)
      html_buffer = IOBuffer()
      KomaMRIPlots.PlotlyBase.to_html(html_buffer, p.plot)
      return HTTP.Response(200,body=take!(html_buffer))
   end
end


@get "/simulate/{simulationId}/status" function(req::HTTP.Request, simulationId)
   return HTTP.Response(200,body=JSON3.write(simProgress))
end

# PLOT SEQUENCE
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

serve(host="0.0.0.0",port=8085)
