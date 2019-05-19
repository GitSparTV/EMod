EMod = EMod or {}
local Tick = CreateConVar("emod_tickrate", 0.1, {FCVAR_NOTIFY}, "Sets the electricity tickrate. Chosen value represents the next time when EMod-Electron will flow. Alike the \"current\" speed. Used against server overload. Input: number (0 > x). 1 is one second.")
EMODTick = Tick:GetFloat()

cvars.AddChangeCallback("emod_tickrate", function()
	EMODTick = Tick:GetFloat()
end)

local DefaultTemp = CreateConVar("emod_defaulttemp", 25, {FCVAR_NOTIFY}, "Sets the default temperature for all EMod-Electronics. Input: number.")
EMODTemp = DefaultTemp:GetFloat()

cvars.AddChangeCallback("emod_defaulttemp", function()
	EMODTemp = DefaultTemp:GetFloat()
end)

function EMod.DoWire(ent1, pin1, ent2, pin2, mils)
	if not IsValid(ent1) or not pin1 or not IsValid(ent2) or not pin2 or not ent1:IsEModComponent() or not ent2:IsEModComponent() then return false end
	if ent1 == ent2 and pin1 == pin2 then return false end
	local ent1Pins, ent2Pins = ent1:GetPins(), ent2:GetPins()
	local Pin1, Pin2 = ent1Pins[pin1], ent2Pins[pin2]
	if not Pin1 or not Pin2 then return false end

	if Pin1.connected then
		EMod.DoUnWire(ent1, pin1)
	end

	if Pin2.connected then
		EMod.DoUnWire(ent2, pin2)
	end

	local wire = EMod.Wire(mils, "cable/cable2")
	EMod.AddEntity(wire, EMod.Type.Wire)
	Pin1.wireInfo = EMod.WireInfo(wire, ent2, pin2)
	Pin2.wireInfo = EMod.WireInfo(wire, ent1, pin1)
	Pin1.connected = true
	Pin2.connected = true
	EMod.Net.Queue(EMod.Net.Wire, ent1, ent2, pin1, pin2, wire)
end

function EMod.DoUnWire(ent1, pin1)
	if not IsValid(ent1) or not pin1 or not ent1:IsEModComponent() then return false end
	local ent1Pins = ent1:GetPins()
	local Pin1 = ent1Pins[pin1]
	if not Pin1 or not Pin1.connected then return false end
	local wire = Pin1.wireInfo.wire
	EMod.RemoveEntity(wire)
	local ent2 = Pin1.wireInfo.entity
	local pin2 = Pin1.wireInfo.pin
	local Pin2 = ent2:GetPins()[pin2]

	if not Pin2 then
		error("] [EMod] ???")
	end

	Pin1.wireInfo = {}
	Pin2.wireInfo = {}
	Pin1.connected = false
	Pin2.connected = false
	EMod.Net.Queue(EMod.Net.UnWire, ent1, ent2, pin1, pin2)
end

--[[-------------------------------------------------------------------------
EMod Net
---------------------------------------------------------------------------]]
local NET_BOOL = 1
local NET_ENT = 2
local NET_PIN = 3
local NET_FLOAT = 4
local NET_STRING = 5
EMod.Net.InQueue = {}
util.AddNetworkString("EMod.Net")

timer.Create("EMod.Net.Queue", 1 / 100, 0, function()
	if EMod.Net.InQueue[1] then
		local msgType = EMod.Net.InQueue[1][1]
		local data = EMod.Net.InQueue[1][2]
		net.Start("EMod.Net")
		net.WriteUInt(msgType, 4)

		for I = 1, #data, 2 do
			local type = data[I]
			local value = data[I + 1]

			if type == NET_BOOL then
				net.WriteUInt(value and 1 or 0, 1)
				-- print("BOOL")
			elseif type == NET_ENT then
				net.WriteEntity(value)
			elseif type == NET_PIN then
				-- print("ENT")
				net.WriteUInt(value, 5)
			elseif type == NET_FLOAT then
				-- print("PIN")
				net.WriteFloat(value)
			elseif type == NET_STRING then
				-- print("FLOAT")
				net.WriteString(value)
			end
			-- print("STRING")
		end

		net.Broadcast()
		table.remove(EMod.Net.InQueue, 1)
	end
end)

function EMod.Net.AddMethod(id, func)
	EMod.Net.Methods[id] = func
end

local function netWire(ent1, ent2, pin1, pin2, wireEnt)
	return {NET_ENT, ent1, NET_ENT, ent2, NET_PIN, pin1, NET_PIN, pin2, NET_FLOAT, wireEnt.mils, NET_STRING, wireEnt.material}
end

local function netUnWire(ent1, ent2, pin1, pin2)
	return {NET_ENT, ent1, NET_ENT, ent2, NET_PIN, pin1, NET_PIN, pin2}
end

function EMod.Net.Queue(msgType, ...)
	if EMod.Net.Methods[msgType] then
		table.insert(EMod.Net.InQueue, {msgType, EMod.Net.Methods[msgType](...)})
	else
		print("[EMod] Invalid msgType.")
	end
end

EMod.Net.AddMethod(EMod.Net.Wire, netWire)
EMod.Net.AddMethod(EMod.Net.UnWire, netUnWire)