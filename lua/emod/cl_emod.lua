hook.Add("AddToolMenuTabs", "EMod.SpawnMenuTab", function()
	spawnmenu.AddToolTab("EMod", "EMod", "icon16/transmit.png")
end)

--models/props_c17/utilitypolemount01a.mdl
EMod = EMod or {}
EMODTick = GetConVar("emod_tickrate"):GetFloat()
EMODTemp = GetConVar("emod_defaulttemp"):GetFloat()

hook.Add("PostDrawTranslucentRenderables", "EMod", function(_, __)
	for k, v in ipairs(EMod.Entities) do
		if v.type == EMod.Type.Wire then
			local info = v.entity.backReference
			local mils = v.entity.mils
			local material = v.entity.material
			local ent1, pin1, ent2, pin2 = info[1].entity, info[1].pin, info[2].entity, info[2].pin
			if not IsValid(ent1) or not IsValid(ent2) then continue end
			local pinPos1, pinPos2 = ent1:LocalToWorld(ent1:GetPinPos(pin1)), ent2:LocalToWorld(ent2:GetPinPos(pin2))
			local vec1 = render.ComputeLighting(pinPos1, -(pinPos1 - EyePos()):GetNormalized()).x
			local vec2 = render.ComputeLighting(pinPos2, -(pinPos2 - EyePos()):GetNormalized()).x
			local vec3 = render.ComputeLighting(pinPos1, Vector(0,0,1)).x
			local vec4 = render.ComputeLighting(pinPos2, Vector(0,0,1)).x
			local level = math.max(vec1, vec2, vec3, vec4) * 255
			render.SetMaterial(Material(material or "cable/cable2"))
			render.DrawBeam(pinPos1, pinPos2, 0.5 + (mils / 10), 0, 1, Color(level, level, level))
		end
	end
end)

--[[-------------------------------------------------------------------------
EMod Net
---------------------------------------------------------------------------]]
local NET_BOOL = 1
local NET_ENT = 2
local NET_PIN = 3
local NET_FLOAT = 4
local NET_STRING = 5

function EMod.Net.ReadPin()
	return net.ReadUInt(5)
end

function EMod.Net.AddMethod(id, func)
	EMod.Net.Methods[id] = func
end

local function netWire()
	local ent1, ent2 = net.ReadEntity(), net.ReadEntity()
	local pin1, pin2 = EMod.Net.ReadPin(), EMod.Net.ReadPin()
	local wireMil, wireMat = net.ReadFloat(), net.ReadString()
	if not IsValid(ent1) or not IsValid(ent2) or not ent1:IsEModComponent() or not ent2:IsEModComponent() then return end
	local ent1Pins, ent2Pins = ent1:GetPins(), ent2:GetPins()
	local Pin1, Pin2 = ent1Pins[pin1], ent2Pins[pin2]
	if not Pin1 or not Pin2 then return end
	local wire = EMod.Wire(wireMil, wireMat)
	EMod.AddEntity(wire, EMod.Type.Wire)
	Pin1.wireInfo = EMod.WireInfo(wire, ent2, pin2)
	Pin2.wireInfo = EMod.WireInfo(wire, ent1, pin1)
	Pin1.connected = true
	Pin2.connected = true
end

local function netUnWire()
	local ent1, ent2 = net.ReadEntity(), net.ReadEntity()
	local pin1, pin2 = EMod.Net.ReadPin(), EMod.Net.ReadPin()
	if not IsValid(ent1) or not IsValid(ent2) or not ent1:IsEModComponent() or not ent2:IsEModComponent() then return end
	local ent1Pins, ent2Pins = ent1:GetPins(), ent2:GetPins()
	local Pin1, Pin2 = ent1Pins[pin1], ent2Pins[pin2]
	if not Pin1 or not Pin2 then return end
	local wire = Pin1.wireInfo.wire
	Pin1.wireInfo = {}
	Pin2.wireInfo = {}
	EMod.RemoveEntity(wire)
	Pin1.connected = false
	Pin2.connected = false
end

net.Receive("EMod.Net", function(len)
	local msgType = net.ReadUInt(4)

	if EMod.Net.Methods[msgType] then
		EMod.Net.Methods[msgType]()
	else
		print("[EMod] Received unknown msgType!")
	end
end)

EMod.Net.AddMethod(EMod.Net.Wire, netWire)
EMod.Net.AddMethod(EMod.Net.UnWire, netUnWire)