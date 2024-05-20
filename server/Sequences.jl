"""
Basic spin-echo (SE) Sequence
"""
SE(FOV::Float64, N::Int, TE::Float64, TR::Float64, sys::Scanner; G=[0,0,0], Δf=0) = begin
    # Excitation and inversion (Sinc pulse) ----------------------------------  

	"""
	# T_rf = 6e-3     # Pulse duration
	# Gss = 2e-3      # Slice-select gradient
	# With T = 6ms, we need B1 = 4.3469e-8 T to produce a flip angle α = 1°
	# B_1° = 4.3469e-8
	"""

	T_rf = 3e-3     # Pulse duration
	Gss = 2e-3      # Slice-select gradient

	# With T = 3ms, we need B1 = 8,69e-8 T to produce a flip angle α = 1°
	B_1° = 8.6938e-8

	# 90º pulse
	EX_90 = PulseDesigner.RF_sinc(90*B_1°,T_rf,sys;G=[0,0,Gss],Δf=Δf)

	# 180º pulse
	EX_180 = PulseDesigner.RF_sinc(180*B_1°*1im,T_rf,sys;G=[0,0,Gss],Δf=Δf)[1]

	# Acquisition ----------------------------------------------------
	# Square acquisition (Nx = Ny = N) 
	# PHASE
	ζ_phase = EX_90[2].GR[1].rise
	T_phase = EX_90[2].GR[1].T


	Δk = (1/FOV)
	FOVk = (N-1)*Δk
	Gx = Gy = FOVk/(γ*(T_phase + ζ_phase))
	step = Δk/(γ*(T_phase + ζ_phase))

	print("Δk = ", Δk, " m⁻¹\n")
	print("FOVk = ", FOVk, " m⁻¹\n")
	print("Gx = ", Gx*1e3, " mT/m\n")
	print("step = ", step*1e3, " mT/m\n")

	# FE and Readout
	TE_min = maximum(2*[(EX_90.DUR[1]/2 + EX_90.DUR[2] + EX_180.DUR[1]/2), 
						(EX_180.DUR[1]/2 + sys.ADC_Δt*(N-1)/2)])
	if TE < TE_min
			print("Error: TE must be greater than TE_min = ", TE_min*1e3, " ms\n")
			return
	end

	delay_TE = TE/2 -(EX_90.DUR[1]/2 + EX_90.DUR[2] + EX_180.DUR[1]/2)

	ACQ_dur = TE - EX_180.DUR[1]
	G_ro = FOVk/(γ*ACQ_dur)
	ζ_ro = G_ro / sys.Smax
	T_ro = ACQ_dur - ζ_ro
	GR = reshape([Grad(G_ro,T_ro,ζ_ro), Grad(0,0), Grad(0,0)],(3,1))
	RO = Sequence(GR)
	RO.ADC[1] = ADC(N, T_ro, ζ_ro)

	delay_TR = TR - TE - ACQ_dur/2 - EX_90.DUR[1]/2

	print("ACQ_dur = ", ACQ_dur*1e3, " ms\n")
	print("G_ro = ", G_ro*1e3, " mT/m\n")
	print("ζ = ", ζ_ro*1e3, " ms\n")

	se = Sequence()
	for i in 0:(N-1)
		# 90º pulse
		EX_90 = PulseDesigner.RF_sinc(90*B_1°,T_rf,sys;G=[0,0,Gss],Δf=Δf)
		EX_90[end].GR[1].A = Gx/2
		EX_90[end].GR[2].A = Gy/2 - i*step
		# 180º pulse
		EX_180 = PulseDesigner.RF_sinc(180*B_1°*1im,T_rf,sys;G=[0,0,Gss],Δf=Δf)[1]

		se += EX_90 + Delay(delay_TE) + EX_180 + RO + Delay(delay_TR)
	end

	R = rotation_matrix(G)
	se.DEF = Dict("Nx"=>N,"Ny"=>N,"Nz"=>1,"Name"=>"se"*string(N)*"x"*string(N),"FOV"=>[FOV, FOV, 0])
	R*se[2:end]
end


"""
Basic gradient-echo (GRE) Sequence
"""
GRE(FOV::Float64, N::Int, TE::Float64, TR::Float64, α, sys::Scanner; G=[0,0,0], Δf=0) = begin
	# Excitation (Sinc pulse) ----------------------------------
	# α = γ ∫(0-T) B1(t)dt 
	# ----------------------
	# We need to obtain B1 from flip angle α and a generic T=3ms duration
	# i.e. we need to resolve the equation above

	T_rf = 3e-3   		# Pulse duration
	Gss = 2e-3     	# Slice-select gradient

	# With T = 3ms, we need B1 = 8,69e-8 T to produce a flip angle α = 1°
	B_1° = 8.6938e-8
	B1 = α*B_1°
	EX = PulseDesigner.RF_sinc(B1,T_rf,sys;G=[0,0,Gss],Δf=Δf)

	# Acquisition ----------------------------------------------
	# Square acquisition (Nx = Ny = N) 
	# PHASE
	ζ_phase = EX[2].GR[1].rise
	T_phase = EX[2].GR[1].T

	Δk = (1/FOV)
	FOVk = (N-1)*Δk
	Gx = Gy = FOVk/(γ*(T_phase + ζ_phase))
	step = Δk/(γ*(T_phase + ζ_phase))

	"""
	print("Δk = ", Δk, " m⁻¹\n")
	print("FOVk = ", FOVk, " m⁻¹\n")
	print("Gx = ", Gx*1e3, " mT/m\n")
	print("step = ", step*1e3, " mT/m\n")
	"""

	# FE and Readout
	TE_min = (1/2) * ( sys.ADC_Δt*(N-1) + 2*((EX.DUR[1]/2) + EX.DUR[2]) )
	if TE < TE_min
		print("Error: TE must be greater than TE_min = ", TE_min*1e3, " ms\n")
		return
	end

	ACQ_dur = 2 * (TE - ( (EX.DUR[1]/2) + EX.DUR[2] ))
	G_ro = FOVk/(γ*ACQ_dur)
	ζ_ro = G_ro / sys.Smax
	T_ro = ACQ_dur - ζ_ro
	GR = reshape([Grad(G_ro,T_ro,ζ_ro), Grad(0,0), Grad(0,0)],(3,1))
	RO = Sequence(GR)
	RO.ADC[1] = ADC(N, T_ro, ζ_ro)
	delay_TR = TR - (EX.DUR[1] + EX.DUR[2] + RO.DUR[1])

	"""
	print("ACQ_dur = ", ACQ_dur*1e3, " ms\n")
	print("G_ro = ", G_ro*1e3, " mT/m\n")
	print("ζ = ", ζ_ro*1e3, " ms\n")
	"""

	gre = Sequence()
	for i in 0:(N-1)
		# Excitation and first phase 
		EX = PulseDesigner.RF_sinc(B1,T_rf,sys;G=[0,0,Gss],Δf=Δf)
		EX[end].GR[1].A = -Gx/2
		EX[end].GR[2].A = -Gy/2 + i*step
		gre += EX

		# FE and Readout
		gre += RO + Delay(delay_TR)
	end
	gre.DEF = Dict("Nx"=>N,"Ny"=>N,"Nz"=>1,"Name"=>"gre"*string(N)*"x"*string(N),"FOV"=>[FOV, FOV, 0])
	return gre
end



bSSFP(FOV::Float64, N::Int, TR::Float64, α, sys::Scanner; G=[0,0,0], Δf=0) = begin
	# Excitation (Sinc pulse) ----------------------------------
	# α = γ ∫(0-T) B1(t)dt 
	# ----------------------
	# We need to obtain B1 from flip angle α and a generic T=3ms duration
	# i.e. we need to resolve the equation above

	T_rf = 3e-3   	# Pulse duration
	Gss = 2e-3     	# Slice-select gradient

	# With T = 3ms, we need B1 = 8,69e-8 T to produce a flip angle α = 1°
	B_1° = 8.6938e-8
	B1 = α*B_1°
	EX = RF_sinc(B1,T_rf,sys;G=[0,0,Gss],Δf=Δf)

	# Acquisition ----------------------------------------------
	# Square acquisition (Nx = Ny = N) 
	# PHASE
	ζ_phase = EX[2].GR[1].rise
	T_phase = EX[2].GR[1].T

	Δk = (1/FOV)
	FOVk = (N-1)*Δk
	Gx = Gy = FOVk/(γ*(T_phase + ζ_phase))
	step = Δk/(γ*(T_phase + ζ_phase))

	#=
	print("Δk = ", Δk, " m⁻¹\n")
	print("FOVk = ", FOVk, " m⁻¹\n")
	print("Gx = ", Gx*1e3, " mT/m\n")
	print("step = ", step*1e3, " mT/m\n")
	=#

	# FE and Readout
	delay = 0.1*TR # delay to "strech" readout time
	ACQ_dur = TR - (EX.DUR[1] + 2*EX.DUR[2] + 2*delay)
	G_ro = FOVk/(γ*ACQ_dur)
	ζ_ro = G_ro / sys.Smax
	T_ro = ACQ_dur - ζ_ro
	GR = reshape([Grad(G_ro,T_ro,ζ_ro), Grad(0,0), Grad(0,0)],(3,1))
	RO = Sequence(GR)
	RO.ADC[1] = ADC(N, T_ro, ζ_ro)

	#=
	print("ACQ_dur = ", ACQ_dur*1e3, " ms\n")
	print("G_ro = ", G_ro*1e3, " mT/m\n")
	print("ζ = ", ζ_ro*1e3, " ms\n")
	=#

	gre = Sequence()
	for i in 0:(N-1)
		# Excitation and first phase 
		EX = RF_sinc(B1,T_rf,sys;G=[0,0,Gss],Δf=Δf)
		EX[end].GR[1].A = -Gx/2
		EX[end].GR[2].A = -Gy/2 + i*step
		gre += EX

		# FE and Readout
		balance = Sequence(reshape([ EX[end].GR[1],
									-EX[end].GR[2],
									 EX[end].GR[3]],(3,1)))

		# balance = Sequence(reshape([  Grad(0,EX[end].GR[1].T),
		# 							  Grad(0,EX[end].GR[2].T),
		# 							  Grad(0,EX[end].GR[2].T)],(3,1)))	

		gre += Delay(delay) + RO + Delay(delay) + balance
	end
	gre.DEF = Dict("Nx"=>N,"Ny"=>N,"Nz"=>1,"Name"=>"gre"*string(N)*"x"*string(N),"FOV"=>[FOV, FOV, 0])
	gre[2:end]
end