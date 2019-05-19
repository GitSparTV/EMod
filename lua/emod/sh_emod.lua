EMod = EMod or {}
EMod.Components = EMod.Components or {}
EMod.Entities = EMod.Entities or {}
EMod.Net = EMod.Net or {}
EMod.Net.Methods = EMod.Net.Methods or {}
EMod.Net.Wire = 1
EMod.Net.UnWire = 2

cvars.AddChangeCallback("emod_tickrate", function()
	EMODTick = Tick:GetFloat()
end)

cvars.AddChangeCallback("emod_defaulttemp", function()
	EMODTemp = DefaultTemp:GetFloat()
end)

local ENT = FindMetaTable("Entity")

function ENT:IsEModComponent()
	return self.EMODComponent
end

function EMod.Wire(mils, material)
	return {
		temp = EMODTemp,
		mils = mils,
		material = material
	}
end

function EMod.WireInfo(wire, toEnt, toPin)
	local t = {
		wire = wire,
		entity = toEnt,
		pin = toPin
	}

	wire.backReference = wire.backReference or {}
	table.insert(wire.backReference, t)

	return t
end

function EMod.Pin(name, posOnModel)
	return {
		name = name or "PIN",
		pinPos = posOnModel or Vector(),
		wireInfo = {},
		connected = false
	}
end

function EMod.Scheme(outputsTo, SchemeData)
	return {outputsTo, SchemeData or {}}
end

function EMod.SealScheme(...)
	local args = {...}
	if table.IsEmpty(args) then return {} end
	local scheme = {}

	for k = 1, #args, 2 do
		scheme[args[k]] = args[k + 1]
	end

	return scheme
end

function EMod.RegisterComponent(ENT, name, category, manualSpawn, author, contact)
	if not name then
		error("] [EMod] Missing argument #1: name (string)")
	end

	ENT.PrintName = "EMod | " .. name
	ENT.Author = author
	ENT.Contact = contact
	ENT.Category = "EMod"
	ENT.Spawnable = manualSpawn or false

	EMod.Components[ENT.Folder:gsub("entities/", "")] = {
		Name = name,
		Category = category or "Uncategorized"
	}
end

function EMod.AddEntity(object, type)
	if not object or not type then return end

	table.insert(EMod.Entities, {
		entity = object,
		type = type
	})
end

function EMod.RemoveEntity(object)
	for k, v in ipairs(EMod.Entities) do
		if v.entity == object then return table.remove(EMod.Entities, k) end
	end
end

function ents.GetEModComponents()
	return EMod.Entities
end

EMod.Zero = "ZERO"
EMod.Plus = "ANODE"
EMod.Minus = "KATHODE"
EMod.Type = {}
EMod.Type.Component = 0
EMod.Type.Wire = 1
EMod.HighVoltage = 0
EMod.CommonVoltage = 1
EMod.LowVoltage = 2