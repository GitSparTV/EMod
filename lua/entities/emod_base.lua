AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Base"
ENT.Author = "Spar"
ENT.Contact = "https://github.com/GitSparTV/EMod"
ENT.EMODComponent = true
-- include("emod/sv_emod.lua")

if CLIENT then
	function ENT:GetGUICache()
		return self.EMod.GUICache
	end
end

function ENT:SetTemperature(temp)
	self.EMod.Temperature = temp
end

function ENT:GetTemperature(temp)
	return self.EMod.Temperature
end

function ENT:AddPin(name, posOnModel)
	return table.insert(self.EMod.Pins, EMod.Pin(name, posOnModel))
end

function ENT:AddScheme(pinNum, ...)
	self.EMod.Scheme[pinNum] = EMod.SealScheme(...)
end

function ENT:GetPins()
	return self.EMod.Pins
end

function ENT:GetPinPos(pin)
	local pins = self.EMod.Pins
	return pins[pin].pinPos or Vector()
end

function ENT:EModInstall()
	self.EMod = {}
	self.EMod.Temperature = EMODTemp
	self.EMod.Pins = {}
	self.EMod.Scheme = {}
	self.EMod.CurrentCallbacks = {}

	if CLIENT then
		self.EMod.GUICache = {}
	end
end

function ENT:GetScheme()
	return self.EMod.Scheme
end

function ENT:GetEModInfo()
	return self.EMod
end

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_lab/tpplug.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()
		self:EModInstall()
		self:EModSetup()
	end

	function ENT:EModSetup()
	end

	function ENT:EModSettings(settings)
	end
	-- function ENT:MakeTick(edata)
	-- 	-- if not istable(self.EModCharge) then return end
	-- 	-- if not istable(self.EModCharge[id]) then return end
	-- 	for k, v in ipairs(edata.Route) do
	-- 		v(edata)
	-- 	end
	-- 	edata = nil
	-- end
	-- function ENT:IsGround(id)
	-- 	if not istable(self.EModOutputs[id]) then return end
	-- 	return self.EModOutputs[id].name == EMod.Zero
	-- end
	-- function ENT:FlowScheme(pin, edata)
	-- 	for k, v in pairs(self.EModScheme[pin]) do
	-- 		local cedata = table.Copy(edata)
	-- 		if v.disabled == true then continue end
	-- 		if v.ChargeSettings then
	-- 			EModApplyData(cedata, v.ChargeSettings)
	-- 		end
	-- 		timer.Simple(cedata.R and cedata.R * 0.00001 or 0, function()
	-- 			if not IsValid(self) then return end
	-- 			self:FlowCurrent(k, cedata)
	-- 		end)
	-- 		-- print("\tRedirect from "..self.EModOutputs[pin].name.." to "..self.EModOutputs[k].name)
	-- 	end
	-- end
	-- function ENT:FlowCurrent(from, edata)
	-- 	local connected = self.EModOutputs[from]
	-- 	if connected.to == nil or connected.wire == nil or connected.to_pin == nil then return end
	-- 	if not IsValid(connected.to) or not IsValid(connected.wire) then
	-- 		EModRemoveWire(self, from)
	-- 		return
	-- 	end
	-- 	if EModIsACycle(edata, connected.to, connected.to_pin) then return end
	-- 	if not istable(edata.Route) then
	-- 		edata.Route = {}
	-- 	end
	-- 	timer.Simple(EMODTick + (edata.R and edata.R * 0.001 or 0), function()
	-- 		if not IsValid(self) then return end
	-- 		if connected.to == nil or connected.wire == nil or connected.to_pin == nil then return end
	-- 		if not IsValid(connected.to) or not IsValid(connected.wire) then
	-- 			EModRemoveWire(self, from)
	-- 			return
	-- 		end
	-- 		-- print("From "..tostring(self.EModOutputs[from].name).." to "..tostring(connected.to.EModOutputs[connected.to_pin].name))
	-- 		if connected.to:IsGround(connected.to_pin) and edata.ChargeOwner == connected.to then
	-- 			connected.to:TriggerOnCurrent(connected.to_pin, edata)
	-- 			return
	-- 		end
	-- 		-- edata.ChargeOwner:AddTickCache(edata.ChargeID,function() connected.to:TriggerOnCurrent(connected.to_pin,edata) end)
	-- 		table.insert(edata.Route, function(dedata)
	-- 			connected.to:TriggerOnCurrent(connected.to_pin, edata, dedata)
	-- 		end)
	-- 		if table.Count(connected.to.EModScheme[connected.to_pin]) == 0 then
	-- 			edata = nil
	-- 			return
	-- 		end
	-- 		connected.to:FlowScheme(connected.to_pin, edata)
	-- 	end)
	-- end
	-- function ENT:TriggerOnCurrent(pin, edata, dedata)
	-- 	if not self.CurrentCallbacks then return end
	-- 	for k, v in pairs(self.CurrentCallbacks) do
	-- 		if v.pin == pin then
	-- 			if v.efunc then
	-- 				edata = v.efunc(edata)
	-- 			end
	-- 			v.func(edata, dedata)
	-- 		end
	-- 	end
	-- end
	-- function ENT:RegisterCallback(pin, func, efunc)
	-- 	if self.CurrentCallbacks == nil then
	-- 		self.CurrentCallbacks = {}
	-- 	end
	-- 	table.insert(self.CurrentCallbacks, {
	-- 		pin = pin,
	-- 		func = func,
	-- 		efunc = efunc
	-- 	})
	-- end
	-- util.AddNetworkString("EModGetOutputs")
	-- net.Receive("EModGetOutputs", function(len, ply)
	-- 	local ent = net.ReadEntity()
	-- 	for k, v in pairs(ent.EModOutputs) do
	-- 		if v.to == nil or v.wire == nil then continue end
	-- 		if not IsValid(v.to) or not IsValid(v.wire) then
	-- 			EModRemoveWire(ent, k)
	-- 			continue
	-- 		end
	-- 	end
	-- 	net.Start("EModGetOutputs")
	-- 	net.WriteEntity(ent)
	-- 	net.WriteTable(ent.EModOutputs)
	-- 	net.Send(ply)
	-- end)
	-- function EModRemoveWire(ent1, pin1)
	-- 	ent1.EModOutputs[pin1].to = nil
	-- 	ent1.EModOutputs[pin1].to_pin = nil
	-- 	if IsValid(ent1.EModOutputs[pin1].wire) then
	-- 		ent1.EModOutputs[pin1].wire:Remove()
	-- 	end
	-- 	if IsValid(ent1.EModOutputs[pin1].Pwire) then
	-- 		ent1.EModOutputs[pin1].Pwire:Remove()
	-- 	end
	-- 	ent1.EModOutputs[pin1].wire = nil
	-- 	ent1.EModOutputs[pin1].Pwire = nil
	-- 	local ent2 = ent1.EModOutputs[pin1].to
	-- 	local pin2 = ent1.EModOutputs[pin1].to_pin
	-- 	if not ent2 or not pin2 or not IsValid(ent2) then return end
	-- 	ent2.EModOutputs[pin2].to = nil
	-- 	ent2.EModOutputs[pin2].to_pin = nil
	-- 	ent2.EModOutputs[pin2].wire = nil
	-- 	ent2.EModOutputs[pin2].Pwire = nil
	-- 	net.Start("EModGetOutputs")
	-- 	net.WriteEntity(ent1)
	-- 	net.WriteTable(ent1.EModOutputs)
	-- 	net.Broadcast()
	-- 	net.Start("EModGetOutputs")
	-- 	net.WriteEntity(ent2)
	-- 	net.WriteTable(ent2.EModOutputs)
	-- 	net.Broadcast()
	-- end
	-- function EModDataCalculator(edata, val)
	-- 	if val == "I" then
	-- 		edata.R = edata.U / edata.I * 1000
	-- 		edata.P = edata.U * edata.I / 1000
	-- 	end
	-- 	if val == "R" then
	-- 		edata.I = edata.U / edata.R * 1000
	-- 		edata.P = edata.U * edata.I / 1000
	-- 	end
	-- 	if val == "P" then
	-- 		edata.I = edata.P / edata.U * 1000
	-- 		edata.R = edata.U / edata.I / 1000
	-- 	end
	-- 	-- if val == "U" then d1.R = d1.U/d1.I end  |Needs to be known everytime|
	-- end
	-- function EModApplyData(d1, d2)
	-- 	for k, v in pairs(d2) do
	-- 		if not v[2] then
	-- 			if d1[k] and d1[k] ~= math.huge then
	-- 				d1[k] = math.Clamp(d1[k] - math.Clamp(v[1], 0, math.huge), 0, math.huge)
	-- 			else
	-- 				d1[k] = math.Clamp(v[1], 0, math.huge)
	-- 			end
	-- 		else
	-- 			d1[k] = math.Clamp(v[1], 0, math.huge)
	-- 		end
	-- 		EModDataCalculator(d1, k)
	-- 	end
	-- 	return d1
	-- end
	-- function EModIsACycle(edata, obj, pin)
	-- 	if not istable(edata.Route[obj]) then return false end
	-- 	return edata.Route[obj][pin] and true or false
	-- end
	-- function EModPerformDischarge(bat, I)
	-- 	local mAh = bat:GetAvailable()
	-- 	local mAs = mAh * 3600
	-- 	local newmAs = math.Clamp((mAs - I) / 3600, 0, bat:GetCapacity())
	-- 	bat:SetAvailable(newmAs)
	-- end
else
	function ENT:Initialize()
		self:EModInstall()
		self:EModSetup()
	end
	-- function EModValueFold(val)
	-- 	if val == math.huge then
	-- 		return "∞"
	-- 	elseif val == -math.huge then
	-- 		return "-∞"
	-- 	end
	-- 	local len = string.len(math.floor(val))
	-- 	if len >= 5 then return math.floor(val / 10000) .. "kk" end
	-- 	if len >= 4 then return math.floor(val / 1000) .. "k" end
	-- 	return val
	-- end
	-- function GetLightAmount(vec)
	-- 	local color = render.GetLightColor(vec):ToColor()
	-- 	return math.Clamp(math.floor(0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b), 80, 255)
	-- end
end

function tomA(val)
	return val * 1000
end

function toA(val)
	return val / 1000
end