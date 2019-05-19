TOOL.Category = "EMod Tools"
TOOL.Name = "E-Wire"
TOOL.Tab = "EMod"
TOOL.ClientConVar["wiremils"] = "0"
TOOL.ClientConVar["selectedpin"] = "0"
-- local List = {"models/emod/cable_copper", "models/emod/cable_patch", "cable/cable2"}
local UnlitMat

if CLIENT then
	TOOL.AnimClock = 0
	TOOL.AnimState = false
	TOOL.SizeCache = 0
	TOOL.AnimStart = 0

	TOOL.Information = {
		{
			name = "left",
			stage = 0
		},
		{
			name = "left_1",
			stage = 1
		},
		{
			name = "right",
			stage = 0
		},
		{
			name = "right",
			stage = 1
		},
		{
			name = "reload",
			stage = 0
		},
		{
			name = "reload_1",
			stage = 1
		}
	}

	language.Add("tool.emod_wire.name", "E-Wire")
	language.Add("tool.emod_wire.desc", "Wires E-Components")
	language.Add("tool.emod_wire_wiremils", "Wire cross section:")
	language.Add("tool.emod_wire_wiremils.help", "Snapped by every 0.25.\nMeasuring unit: squared mm")
	language.Add("tool.emod_wire.left", "Start wiring selected pin")
	language.Add("tool.emod_wire.left_1", "Wire to selected pin")
	language.Add("tool.emod_wire.right", "Select next pin")
	language.Add("tool.emod_wire.reload", "Remove wire from selected pin")
	language.Add("tool.emod_wire.reload_1", "Stop wiring")
	local mat = Material("phoenix_storms/wire/pcb_blue")
	local params = {}
	params["$basetexture"] = mat:GetString("$basetexture")
	params["$vertexcolor"] = 1
	params["$vertexalpha"] = 1
	UnlitMat = CreateMaterial("EModWireToolBackground", "UnlitGeneric", params)
else
	TOOL.Cache = {}
end

function TOOL:LeftClick(trace)
	local ent = trace.Entity
	local stage = self:GetStage()
	if not IsValid(ent) or not ent:IsEModComponent() then return false end

	if SERVER then
		local pinNum = self:GetClientNumber("selectedpin", 1)

		if stage == 0 then
			self.Cache.Entity1 = ent
			self.Cache.Pin1 = pinNum
			self:SetStage(1)
		else
			local ent1, pin1, ent2, pin2 = self.Cache.Entity1, self.Cache.Pin1, ent, pinNum
			self.Cache.Entity1, self.Cache.Pin1, ent, pinNum = nil, nil, nil, nil

			timer.Simple(0, function()
				EMod.DoWire(ent1, pin1, ent2, pin2, self:GetClientNumber("wiremils"))
			end)

			self:ClearObjects()
		end
	end

	return true
end

function TOOL:RightClick(trace)
	if CLIENT and IsFirstTimePredicted() then
		local ent = trace.Entity

		if IsValid(ent) and ent:IsEModComponent() then
			local GUICache = ent:GetGUICache()

			if input.IsKeyDown(KEY_LSHIFT) then
				GUICache.EWireSelected = GUICache.EWireSelected - 1

				if GUICache.EWireSelected < 1 then
					GUICache.EWireSelected = #ent:GetPins()
				end
			else
				GUICache.EWireSelected = GUICache.EWireSelected + 1

				if #ent:GetPins() < GUICache.EWireSelected then
					GUICache.EWireSelected = 1
				end
			end

			RunConsoleCommand("emod_wire_selectedpin", GUICache.EWireSelected)
		end
	end

	return false
end

function TOOL:Reload(trace)
	if self:GetStage() == 1 then self:ClearObjects() return false end
	local ent = trace.Entity
	if not IsValid(ent) or not ent:IsEModComponent() then return false end

	if SERVER then
		local pinNum = self:GetClientNumber("selectedpin", 1)

		timer.Simple(0, function()
			EMod.DoUnWire(ent, pinNum)
		end)
	end

	return true
end

function TOOL:Holster()
	self:ClearObjects()
end

local GUIPinSize, GUIPinOutdent = 30, 3

function TOOL:DrawHUD()
	local ent = LocalPlayer():GetEyeTrace().Entity
	local PinInfo, GUICache

	if not IsValid(ent) or not ent:IsEModComponent() then
		self.AnimClock = math.Clamp(self.AnimClock - RealFrameTime() * 5, 0, 1)
		self.AnimState = false
	else
		self.AnimClock = math.Clamp(self.AnimClock + RealFrameTime() * 10, 0, 1)

		if not self.AnimState then
			self.AnimStart = SysTime()
		end

		self.AnimState = true
		PinInfo = ent:GetPins()
		self.SizeCache = #PinInfo
		GUICache = ent:GetGUICache()
		GUICache.EWireSelected = GUICache.EWireSelected or 1

		if self:GetClientNumber("emod_wire_selectedpin", 0) ~= GUICache.EWireSelected then
			RunConsoleCommand("emod_wire_selectedpin", GUICache.EWireSelected)
		end
	end

	surface.SetAlphaMultiplier(self.AnimClock)
	local w, t = 200 * self.AnimClock, (20 + 10 + GUIPinSize * self.SizeCache + GUIPinOutdent * (self.SizeCache - 1)) * self.AnimClock
	local xc, yc = ScrW() / 2 - w - 40 * self.AnimClock, ScrH() / 2 - t / 2
	draw.RoundedBox(8, xc, yc, w, t, Color(20, 20, 20))
	surface.SetMaterial(UnlitMat)
	surface.SetDrawColor(150, 150, 150)
	surface.DrawTexturedRectUV(xc + 10, yc + 10, w - 20, t - 20, 0, 0, ((w - 20) / 1024) * 3, ((t - 20) / 1024) * 3)
	surface.SetAlphaMultiplier(1)
	if not self.AnimState or self.AnimClock ~= 1 then return end
	local selectedPin = GUICache.EWireSelected

	for k, v in ipairs(PinInfo) do
		draw.RoundedBox(0, xc + 15, yc + 15 + (GUIPinSize + GUIPinOutdent) * (k - 1), w - 30, GUIPinSize, v.connected and Color(100, 0, 0, 200) or Color(0, 0, 0, 200))

		if selectedPin == k then
			draw.RoundedBox(0, xc + 15, yc + 15 + (GUIPinSize + GUIPinOutdent) * (k - 1), w - 30, GUIPinSize, Color(100, 100, 100, 120 + 30 * math.sin(SysTime() * 2)))
		end

		surface.SetMaterial(Material("emod/emod_pin"))
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(xc + 15 + 5, yc + 15 + (GUIPinSize + GUIPinOutdent) * (k - 1) + GUIPinSize / 2 - 10, 20, 20)
		render.SetScissorRect(xc + 15 + 5 + 20 + 5, yc + 15 + (GUIPinSize + GUIPinOutdent) * (k - 1), xc + w - 30 + 10, yc + 15 + (GUIPinSize + GUIPinOutdent) * (k - 1) + GUIPinSize, true)
		surface.SetFont("Trebuchet24")
		local len = surface.GetTextSize(v.name)
		local scroll = len >= ((w - 30) / 2) and w + ((SysTime() + 2.5 - self.AnimStart) * 100 % (len + (w - 30) * 2) * -1) or -w / 2
		draw.SimpleText(v.name, "Trebuchet24", scroll + xc + 15 + (w), yc + 16 + (GUIPinSize + GUIPinOutdent) * (k - 1), Color(255, 255, 255, 200), 1)
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Description = "#tool.emod_wire.desc"
	})

	CPanel:AddControl("ComboBox", {
		MenuButton = 1,
		Folder = "emod_wire",
		Options = {
			["#preset.default"] = ConVarsDefault
		},
		CVars = table.GetKeys(ConVarsDefault)
	})

	local slider = CPanel:AddControl("Slider", {
		Label = "#tool.emod_wire_wiremils",
		Command = "emod_wire_wiremils",
		Type = "Float",
		Min = 0.5,
		Max = 10,
		Help = true
	})

	local maxI = CPanel:AddControl("Label", {
		Text = "Max Current: " .. ecalc.SI(GetConVar("emod_wire_wiremils"):GetFloat() * 6.1) .. " A"
	})

	local maxP = CPanel:AddControl("Label", {
		Text = "Max Power: " .. ecalc.SI(ecalc.PIV(GetConVar("emod_wire_wiremils"):GetFloat() * 6.1, 220)) .. " W"
	})

	function CPanel:Think()
		self.animSlide:Run()

		if slider:IsVisible() then
			local val = slider:GetValue()
			local add = val % 0.25
			if add == 0 then return end
			slider:SetValue(val + 0.25 - add)
			val = val + 0.25 - add
			maxI:SetText("Max Current: " .. ecalc.SI(val * 6.1, true) .. "A")
			maxP:SetText("Max Power: " .. ecalc.SI(ecalc.PIV(val * 6.1, 220), true) .. "W")
		end
	end

	-- The Relation between Wire Mils and Max Current is not linear. Everyone has tables with some pre-calculated values.
	-- I don't want to store the table of these values, so I just took one table and calculated what the max current would be relatively to this value on wire mil 1 mm and took their average
	-- For example, the value in the table: 1.5 mm = 19 A (220V, copper). So I did ( 1 * 19 ) / 1.5 = (maxA on 1 mm)
	-- For 10 mm = 70 I did ( 1 * 70 ) / 10 = (maxA on 1mm)
	-- Then I took their average (12 in total) and got the value: (6.1 A) per (1 mm)
	-- CPanel:AddControl("checkbox",{Label="#tool.emod_wire.auto",Command="emod_wire_fitto",Help=true})
	CPanel:MatSelect("emod_wire_ropematerial", List, true, 50, 80)
end