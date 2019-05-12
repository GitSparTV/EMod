EMOD_VERSION = "0.2.0"

if SERVER then
	include("emod/sv_emod.lua")
	AddCSLuaFile("emod/cl_emod.lua")
else
	include("emod/cl_emod.lua")
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

]]--