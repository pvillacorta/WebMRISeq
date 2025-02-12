include("Sequences.jl")

"Convert a 1D vector with system paramaters into a KomaMRICore.Scanner object"
vec_to_scanner(vec) = begin
   sys = Scanner()
   sys.B0 =        vec[1]       # Main magnetic field [T]
   sys.B1 =        vec[2]       # Max RF amplitude [T]
   sys.ADC_Δt =    vec[3]       # ADC sampling time
   sys.Gmax =      vec[4]       # Max Gradient [T/m]
   sys.Smax =      vec[5]       # Max Slew-Rate

   sys
end

"Convert a 2D matrix containing sequence information into a KomaMRICore.Sequence object"
mat_to_seq(mat,sys::Scanner) = begin
   seq = Sequence()

   for i=1:size(mat)[2]

      if mat[1,i] == 1 # Excitation
         B1 = mat[6,i] + mat[7,i]im;
         duration = mat[2,i]
         Δf = mat[8,i];
         EX = PulseDesigner.RF_hard(B1, duration, sys; G = [mat[3,i] mat[4,i] mat[5,i]], Δf)
         seq += EX

         G = EX.GR.A; G = [G[1];G[2];G[3]];
         REF = [0;0;1];

         # We need to create a rotation matrix which transfomrs vector [0 0 1] into vector G
         # To do this, we can use axis-angle representation, and then calculate rotation matrix with that
         # https://en.wikipedia.org/wiki/Rotation_matrix#Conversion_from_rotation_matrix_to_axis%E2%80%93angle

         # Cross product:
         global cross_prod = LinearAlgebra.cross(REF,G);
         # Rotation axis (n = axb) Normalized cross product:
         n = normalize(cross_prod);
         # Rotation angle:
         θ = asin(norm(cross_prod)/((norm(REF))*(norm(G))));
         # Rotation matrix:
         global R = [cos(θ)+n[1]^2*(1-cos(θ))            n[1]*n[2]*(1-cos(θ))-n[3]*sin(θ)     n[1]*n[3]*(1-cos(θ))+n[2]*sin(θ);
                     n[2]*n[1]*(1-cos(θ))+n[3]*sin(θ)    cos(θ)+n[2]^2*(1-cos(θ))             n[2]*n[3]*(1-cos(θ))-n[1]*sin(θ);
                     n[3]*n[1]*(1-cos(θ))-n[2]*sin(θ)    n[3]*n[2]*(1-cos(θ))+n[1]*sin(θ)     cos(θ)+n[3]^2*(1-cos(θ))        ];


      elseif mat[1,i] == 2 # Delay
         DELAY = Delay(mat[2,i])
         seq += DELAY


      elseif ((mat[1,i] == 3) || (mat[1,i] == 4)) # Dephase or Readout
         AUX = Sequence()

         ζ = abs(sum([mat[3,i],mat[4,i],mat[5,i]])) / sys.Smax
         ϵ1 = mat[2,i]/(mat[2,i]+ζ)

         AUX.GR[1] = Grad(mat[3,i],mat[2,i],ζ)
         AUX.GR[2] = ϵ1*Grad(mat[4,i],mat[2,i],ζ)
         AUX.GR[3] = Grad(mat[5,i],mat[2,i],ζ)

         AUX.DUR = convert(Vector{Float64}, AUX.DUR)
         AUX.DUR[1] = mat[2,i] + 2*ζ

         AUX.ADC[1].N = (mat[1,i] == 3) ? 0 : trunc(Int,mat[10,i])     # No samples during Dephase interval
         AUX.ADC[1].T = mat[2,i]                                       # The duration must be explicitly stated
         AUX.ADC[1].delay = ζ

         AUX = (norm(cross_prod)>0) ? R*AUX : AUX

         if(mat[1,i]==4)
             global N_x = trunc(Int,mat[10,i])
         end

         seq += AUX


      elseif mat[1,i] == 5 # EPI
          FOV = mat[9,i]
          N = trunc(Int,mat[10,i])

          EPI = PulseDesigner.EPI(FOV, N, sys)
          EPI = (norm(cross_prod)>0) ? R*EPI : EPI
          seq += EPI

          N_x = N
      end

   end

   seq.DEF = Dict("Nx"=>N_x,"Ny"=>N_x,"Nz"=>1)

   seq
end

"Convert a json string containing sequence information into a KomaMRIBase.Sequence object"
json_to_sequence(json_seq::JSON3.Object, sys::Scanner) = begin
   global seq = Sequence()
   # global R = rotation_matrix()
   
   N_x = 0

   blocks = json_seq["blocks"]

   function get_gradients(block::JSON3.Object, rep::Int)
      gradients = block["gradients"]
      GR = reshape([Grad(0,0) for i in 1:3],(3,1))
      for grad in gradients
         axis        = grad["axis"]
         delay       = grad["delay"]
         rise        = grad["rise"]
         flatTopTime = grad["flatTop"]
         amplitude   = grad["amplitude"] + rep*grad["step"]

         idx = axis == "x" ? 1 :
               axis == "y" ? 2 :
               axis == "z" ? 3 : 
               -1

         if amplitude > sys.Gmax
            error("G=$(amplitude) mT/m exceeds Gmax=$(sys.Gmax) mT/m")
         elseif amplitude/rise > sys.Smax
            error("Slew rate=$(amplitude/rise) mT/m/ms exceeds Smax=$(sys.Smax) mT/m/ms")
         end

         GR[idx] = Grad(amplitude, flatTopTime, rise, delay)
      end
      return GR
   end

   function isChild(index::Int)
      for i in eachindex(blocks)
         children = blocks[i]["children"]
         for j in eachindex(children)
            if children[j].number == (index - 1)
               return true
            end
         end
      end
      return false
   end

   function addToSeq(block::JSON3.Object, rep::Int) 
      if block["cod"] == 0          # <------------- Group
         repetitions =  block["repetitions"]
         children =     block["children"]
         for i in 0:(repetitions-1)
            for j in eachindex(children)
               addToSeq(blocks[children[j].number+1],i)
            end
         end

      elseif block["cod"] == 1       # <-------------------------- Excitation
         print("Excitation\n")

         rf     = block["rf"][1]
         shape  = rf["shape"]
         deltaf = rf["deltaf"]

         # Flip angle and duration
         if haskey(block, "duration") & haskey(rf, "flipAngle")
            duration = block["duration"]
            flipAngle = rf["flipAngle"]

            aux_amplitude = 1e-6
            # 1. Rectangle (hard)
            if shape == 0
               AUX = PulseDesigner.RF_hard(aux_amplitude, duration, sys)
            # 2. Sinc
            elseif shape == 1
               AUX = PulseDesigner.RF_sinc(aux_amplitude, duration, sys)
            end

            amplitude = aux_amplitude * (flipAngle/get_flip_angles(AUX)[1])

         # Amplitude and duration
         elseif haskey(block, "duration") & haskey(rf, "b1Module")
            duration = block["duration"]  
            amplitude = rf["b1Module"]
        
         # Flip angle and amplitude
         elseif haskey(rf, "flipAngle") & haskey(rf, "b1Module")
            flipAngle = rf["flipAngle"]
            amplitude = rf["b1Module"]

            aux_duration = 1e-3
            # 1. Rectangle (hard)
            if shape == 0
               AUX = PulseDesigner.RF_hard(amplitude, aux_duration, sys)
            # 2. Sinc
            elseif shape == 1
               AUX = PulseDesigner.RF_sinc(amplitude, aux_duration, sys)
            end

            duration = aux_duration * (flipAngle/get_flip_angles(AUX)[1])
         end

         # 1. Rectangle (hard)
         if shape == 0
            EX = PulseDesigner.RF_hard(amplitude, duration, sys; Δf=deltaf)
         # 2. Sinc
         elseif shape == 1
            EX = PulseDesigner.RF_sinc(amplitude, duration, sys; Δf=deltaf)[1]
         end

         EX.GR = get_gradients(block, rep)
         EX.RF[1].delay = maximum(EX.GR.rise)
         EX.DUR[1] = EX.RF[1].delay + max(maximum(EX.GR.T .+ EX.GR.fall), duration)
         seq += EX

      elseif block["cod"] == 2       # <-------------------------- Delay
         print("Delay\n")

         duration = block["duration"]
         DELAY = Delay(duration)
         seq += DELAY

      elseif block["cod"] in [3,4]   # <-------------------------- Dephase or Readout
         if block["cod"] == 3
            print("Dephase\n")
         elseif block["cod"] == 4
            print("Readout\n")
         end

         DEPHASE = Sequence(get_gradients(block, rep))

         if block["cod"] == 4
            DEPHASE.ADC[1].N = block["samples"]
            DEPHASE.ADC[1].T = block["duration"]
            DEPHASE.ADC[1].delay = block["adcDelay"]

            N_x = block["samples"]
         end

         seq += DEPHASE

      elseif block["cod"] == 5       # <-------------------------- EPI
         print("EPI\n")

         fov = block["fov"]
         lines = block["lines"]
         samples = block["samples"]

         N_x = block["samples"]

         EPI = PulseDesigner.EPI(fov, lines, sys)

         seq += EPI

      elseif block["cod"] == 6       # <-------------------------- GRE  
         print("GRE\n")

         fov = block["fov"]
         lines = block["lines"]
         samples = block["samples"]

         t  = block["t"][1]
         te = t["te"]
         tr = t["tr"]

         rf    = block["rf"][1]
         α     = rf["flipAngle"]
         Δf    = rf["deltaf"]

         seq += GRE(fov, lines, te, tr, α, sys; Δf=Δf)
      end 
   end

   for i in eachindex(blocks)
      if !isChild(i)
         addToSeq(blocks[i],0)
      end
   end

   seq.DEF = Dict("Nx"=>N_x,"Ny"=>N_x,"Nz"=>1)

   display(seq)
   return seq
end

"Convert a json string containing scanner information into a KomaMRIBase.Scanner object"
json_to_scanner(json_scanner::JSON3.Object) = begin
   parameters = json_scanner["parameters"]

   sys = Scanner(
      B0 = parameters["b0"],
      B1 = parameters["b1"],
      Gmax = parameters["gmax"],
      Smax = parameters["smax"],
      ADC_Δt = parameters["deltat"],
   )
   return sys
end

"Obtain the reconstructed image from raw_signal (obtained from simulation)"
recon(raw_signal) = begin
   recParams = Dict{Symbol,Any}(:reco=>"direct")

   acqData = AcquisitionData(raw_signal)
   acqData.traj[1].circular = false #Removing circular window
   acqData.traj[1].nodes = acqData.traj[1].nodes[1:2,:] ./ maximum(2*abs.(acqData.traj[1].nodes[:])) #Normalize k-space to -.5 to .5 for NUFFT
   Nx, Ny = raw_signal.params["reconSize"][1:2]
   recParams[:reconSize] = (Nx, Ny)
   recParams[:densityWeighting] = true

   aux = @timed reconstruction(acqData, recParams)
   image  = reshape(aux.value.data,Nx,Ny,:)
   kspace = KomaMRI.fftc(reshape(aux.value.data,Nx,Ny,:))

   return image, kspace
end

"Obtain raw RM signal. Input arguments are a 2D matrix (sequence) and a 1D vector (system parameters)"
sim(sequence_json, scanner_json, phantom, path) = begin
   # Phantom
   if phantom     == "Brain 2D"
      phant = KomaMRI.brain_phantom2D()
   elseif phantom == "Brain 3D"
      phant = KomaMRI.brain_phantom3D()
   elseif phantom == "Pelvis 2D"
      phant = KomaMRI.pelvis_phantom2D()
   end
   phant.Δw .= 0

   # Scanner
   sys = json_to_scanner(scanner_json)

   # Sequence
   seq = json_to_sequence(sequence_json, sys)

   # Simulation parameters
   simParams = Dict{String,Any}()

   # Simulation
   raw_signal = simulate(phant, seq, sys; sim_params=simParams, w=path)

   # Reconstruction
   image, kspace = recon(raw_signal)

   if path !== nothing
         io = open(path,"w") # "w" mode overwrites last status value, even if it has not been read yet
         write(io,trunc(Int,101))
         close(io)
   end

   image
end

"Render an HTML file in order to send it to the client"
function render_html(html_file::String; status=200, headers=["Content-type" => "text/html"]) :: HTTP.Response
   io = open(html_file,"r") do file
      read(file, String)
   end
   return html(io)
end