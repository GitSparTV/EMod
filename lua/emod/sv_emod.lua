EMod = {}
EMod.Components = {}

function EMod.Pin(name,posOnModel)
	return {name=name or "PIN",pinPos=posOnModel or Vector()}
end

function EMod.Scheme(outputsTo,SchemeData)
	return {outputsTo,SchemeData or {}}
end

function EMod.SealScheme(...)
	local args = {...}
	if table.IsEmpty(args) then return {} end
	local scheme = {}
	for k=1,#args,2 do
		scheme[args[k]] = args[k+1]
	end
	return scheme
end

function EMod.RegisterComponent(ENT,name,category,manualSpawn,author,contact)
	if not name then error("] [EMod] Missing argument #1: name (string)") end
	ENT.PrintName = "EMod | "..name
	ENT.Author = author
	ENT.Contact = contact
	ENT.Category = "EMod"
	ENT.Spawnable = manualSpawn or false

	EMod.Components[ENT.Folder:gsub("entities/","")] = {Name=name,Category=category or "Uncategorized"}
end

local Tick = CreateConVar("emod_tickrate",0.1,{FCVAR_NOTIFY},"Sets the electricity tickrate. Chosen value represents the next time when EMod-Electron will flow. Alike the \"current\" speed. Used against server overload. Input: number (0 > x). 1 is one second.")
EMODTick = Tick:GetFloat()
cvars.AddChangeCallback("emod_tickrate",function()
	EMODTick = Tick:GetFloat()
end)

local DefaultTemp = CreateConVar("emod_defaulttemp",25,{FCVAR_NOTIFY},"Sets the default temperature for all EMod-Electronics. Input: number.")
EMODTemp = DefaultTemp:GetFloat()
cvars.AddChangeCallback("emod_defaulttemp",function()
	EMODTemp = DefaultTemp:GetFloat()
end)

EMod.Zero = "ZERO"
EMod.Plus = "ANODE"
EMod.Minus = "KATHODE"