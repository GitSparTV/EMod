EMOD_VERSION = "0.4.0"

if SERVER then
	include("emod/sh_emod.lua")
	include("emod/sv_emod.lua")
	include("emod/ecalc.lua")
	AddCSLuaFile("emod/sh_emod.lua")
	AddCSLuaFile("emod/cl_emod.lua")
	AddCSLuaFile("emod/ecalc.lua")
else
	include("emod/sh_emod.lua")
	include("emod/cl_emod.lua")
	include("emod/ecalc.lua")
end
--[[
Ideas:

DarkRP House integration

Wiremod integration

Non-entitiy wires

Ambient temperature	Factor
10 °C	1,22
15 °C	1,17
20 °C	1,12
25 °C	1,06
30 °C	1,00
35 °C	0,94
40 °C	0,87
45 °C	0,79
50 °C	0,71
55 °C	0,61
60 °C	0,50
65 °C 	0,35

]]
--
--[[
Voltage			Volt		V			Unit of Electrical Potential		V  = I × R
Current			Ampere		I			Unit of Electrical Current 			I  = V ÷ R
Resistance		Ohm			R or Ω		Unit of DC Resistance 				R  = V ÷ I
Conductance		Siemen		G			Reciprocal of Resistance 			G  = 1 ÷ R
Capacitance		Farad		C			Unit of Capacitance 				C  = Q ÷ V
Charge			Coulomb		Q			Unit of Electrical Charge 			Q  = C × V
Inductance		Henry		H			Unit of Inductance					VL = -L(di/dt)
Power			Watts		W			Unit of Power 						P  = V × I  or I^2 × R
Impedance		Ohm			Z			Unit of AC Resistance 				Z^2 = R^2 + X^2
Frequency		Hertz		Hz			Unit of Frequency 					ƒ  = 1 ÷ T
]]
--
--[[
Terra	kkkk		1,000,000,000,000		10^12
Giga	kkk			1,000,000,000			10^9
Mega	kk			1,000,000				10^6
kilo	k			1,000					10^3
none	none		1						10^0
milli	m			1/1,000					10^-3
micro	µ			1/1,000,000				10^-6
nano	n			1/1,000,000,000			10^-9
pico	p			1/1,000,000,000,000		10^-12
]]
--