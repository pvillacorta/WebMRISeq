"""
Basic gradient-echo (GRE) Sequence (12/02/2025)
"""
function GRE(
	FOV::Float64, 
	N::Int, 
	TE::Float64, 
	TR::Float64, 
	α, sys::Scanner; 
	G=[0,0,1e-3], 
	Δf=0,
	pulse_duration = 3e-3,
	adc_duration = 2e-3,
)
	ζ = 1e-4

	# Excitation (Sinc pulse) ----------------------------------
	rut_slice = ζ
	B_1° = 2.59947e-7 / (pulse_duration * 1e3)
	B1 = α * B_1°
	EX = PulseDesigner.RF_sinc(-1im*B1,pulse_duration,sys;G=G,Δf=Δf)
	rf = EX.RF[1]
	G_slice = EX.GR[3].A
	m0_slice = G_slice * (pulse_duration + 2*rut_slice)
	
	# Acquisition ----------------------------------------------
	# Square acquisition (Nx = Ny = N) 
	# DEPHASE
	Δk = (1/FOV)
	kmax = N * Δk
	m0_deph = kmax / γ
	m0_deph_step = Δk / γ
	rut_deph = ζ
	ft_deph  = rf.T/2

	# Frecuency encoding and Readout
	G_ro = m0_deph / adc_duration
	rut_ro = G_ro / (0.9*sys.Smax)

	TE_min = rf.T/2 + ft_deph + 3*rut_deph + rut_ro + adc_duration/2 
	TE >= TE_min || return error("Error: TE must be greater than TE_min = ", TE_min*1e3, " ms\n")
	delay_TE = TE - TE_min

	TR_min = rf.T + ft_deph + 4*rut_deph + delay_TE + 2*rut_ro + adc_duration
	TR >= TR_min || return error("Error: TR must be greater than TR_min = ", TR_min*1e3, " ms\n")
	delay_TR = TR - TR_min

	gre = Sequence()
	for i in 0:(N-1)
		# Excitation and first phase 
		gr_ss_z   = Grad(G_slice, rf.T, rut_slice)

		@addblock gre += (rf, z=gr_ss_z)

		# Dephase
		gr_deph_x = Grad((-m0_deph/2) / (rut_deph + ft_deph), ft_deph, rut_deph)
		gr_deph_y = Grad((-m0_deph/2 + i*m0_deph_step) / (rut_deph + ft_deph), ft_deph, rut_deph)
		gr_deph_z = Grad((-m0_slice/2) / (ft_deph + rut_deph), ft_deph, rut_deph)
		
		@addblock gre += (x=gr_deph_x, y=gr_deph_y, z=gr_deph_z) + (Duration(delay_TE))

		# FE and Readout
		gr_ro_x = Grad(G_ro, adc_duration, rut_ro)
		adc_ro_x = ADC(N, adc_duration, rut_ro)
		@addblock gre += (x=gr_ro_x, adc_ro_x) + (Duration(delay_TR))
	end

	gre.DEF = Dict("Nx"=>N,"Ny"=>N,"Nz"=>1,"Name"=>"gre"*string(N)*"x"*string(N),"FOV"=>[FOV, FOV, 0], "TE"=>TE, "TR"=>TR)
	
	return gre
end

"""
EPI Sequence (12/02/2025)
"""
function EPI(FOV::Real, N::Integer, sys::Scanner; Δt=sys.ADC_Δt)
	Gmax = sys.Gmax
	Nx = Ny = N #Square acquisition
	Δx = FOV/(Nx-1)
	Ta = Δt*(Nx-1) #4-8 us
	Δτ = Ta/(Ny-1)
	Ga = 1/(γ*Δt*FOV)
	ζ = Ga / sys.Smax
	if Ga > Gmax
		println("Ga=$(Ga*1e3) mT/m exceeds Gmax=$(Gmax*1e3) mT/m, increasing Δt to Δt_min="*string(round(1e6/(γ*Gmax*FOV),digits=2))*" us...")
		return EPI(FOV, N, sys; Δt=1/(γ*Gmax*0.99*FOV))
	end
	ϵ1 = Δτ/(Δτ+ζ)
	#EPI base
	epi = Sequence(vcat(
		[mod(i,2)==0 ? Grad(Ga*(-1)^(i/2),Ta,ζ) : Grad(0.,Δτ,ζ) for i=0:2*Ny-2],  #Gx
		[mod(i,2)==1 ? ϵ1*Grad(Ga,Δτ,ζ) :         Grad(0.,Ta,ζ) for i=0:2*Ny-2])) #Gy
	epi.ADC = [mod(i,2)==1 ? ADC(0,Δτ,ζ) : ADC(N,Ta,ζ) for i=0:2*Ny-2]
	# Relevant parameters
	Δfx_pix = 1/Ta
	Δt_phase = (Ta+2ζ)*Ny + (Δτ+2ζ)*Ny
	Δfx_pix_phase = 1/Δt_phase
	#Pre-wind and wind gradients
	ϵ2 = Ta/(Ta+ζ)
	PHASE =   Sequence(reshape(1/2*[Grad(      -Ga, Ta, ζ); ϵ2*Grad(-Ga, Ta, ζ)],:,1)) #This needs to be calculated differently
	DEPHASE = Sequence(reshape(1/2*[Grad((-1)^N*Ga, Ta, ζ); ϵ2*Grad(-Ga, Ta, ζ)],:,1)) #for even N
	seq = PHASE+epi+DEPHASE
	#Saving parameters
	seq.DEF = Dict("Nx"=>Nx,"Ny"=>Ny,"Nz"=>1,"Name"=>"epi")
	return seq
end

