TOOL.Category = "EMod Tools"
TOOL.Name = "E-Wire"
TOOL.Tab = "EMod"


local List = {
	"models/emod/cable_copper",
	"models/emod/cable_patch",
	"cable/cable2"
}

local PLY = FindMetaTable("Player")
-- function PLY:GetToolObject()
-- 	local activeWep = self:GetActiveWeapon()
-- 	if not IsValid(activeWep) or activeWep:GetClass() ~= "gmod_tool" then end

-- 	return GetConVar("gmod_toolmode"):GetString()
-- end

local function CreateNode(trace,self)
	local node = ents.Create("emod_wire_node")
	node:Spawn()
	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90
	local min = node:OBBMins()
	node:SetPos( trace.HitPos - trace.HitNormal * min.z )
	node:SetAngles( ang )
	node:SetPlayer(self:GetOwner())

	constraint.Weld(node,trace.Entity,0,trace.PhysicsBone,0,1,true)
	DoPropSpawnedEffect(node)
	local physobj = node:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:EnableMotion(false)
		self:GetOwner():AddFrozenPhysicsObject(node,physobj)
	end

	undo.Create( "emod_wire_node" )
		undo.AddEntity(node)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()

	return node
end

function EModIsConnected(who,to)
	if not who.EMODable then return false end 
	for k,v in pairs(who.ConnectedTo) do
		if v.to == to then return true end
	end
	return false
end 


if CLIENT then

	TOOL.SelectedOut = 1
	TOOL.WireInfo = {}
	TOOL.Chatter = 0

	TOOL.ClientConVar = {
		length="1", 
		color_r="0",
		color_g="0",
		color_b="0",
		lastnode="0",
		ropematerial="models/emod/cable_copper",
		fitto="0"
	}
	TOOL.LastMessage = CurTime()
	language.Add("tool.emod_wire.name","E-Wire")
	language.Add("tool.emod_wire.desc","Connects EMod Elements")

	language.Add("tool.emod_wire.0","Hold ALT and scroll to select wire length")
	language.Add("tool.emod_wire.1","Hold ALT and scroll to select wire length")

	language.Add("tool.emod_wire.left","Select output (SHIFT: Create Node)")
	language.Add("tool.emod_wire.right","Next output")

	language.Add("tool.emod_wire.left_select","Select second object")
	language.Add("tool.emod_wire.right_select","Next output")

	language.Add("tool.emod_wire.auto","Fit wire to distance")
	language.Add("tool.emod_wire.auto.help","If checked, length of wire will be automatically fit to distance between them")
	language.Add("Undone_emod_wire_node","Undone Wire Node")

	TOOL.Information = {
		{ name = "info"},
		{ name = "left", stage = 0},
		{ name = "right", stage = 0},
		{ name = "left_select", stage = 1 },
		{ name = "right_select", stage = 1 },
	}
end

if SERVER then
	local function CreateWire(ent1,ent2,out1,out2,fitto,length,material)
		local pinPos1,pinPos2 = ent1.EModOutputs[out1].pinPos,ent2.EModOutputs[out2].pinPos
		if ent1 != ent2 then
			-- print(ent1:Visible(ent2))
			-- if not ent1:Visible(ent2) then return false end
		end
		local B, ROPE = constraint.Rope(ent1,ent2,0,0,pinPos1,pinPos2,fitto == 1 and pinPos1:Distance(pinPos2) or length,0,0,1,material,false)
		if B then
			ent1.EModOutputs[out1].to=ent2 ent1.EModOutputs[out1].to_pin = out2 ent1.EModOutputs[out1].wire=ROPE ent1.EModOutputs[out1].Pwire=B
			ent2.EModOutputs[out2].to=ent1 ent2.EModOutputs[out2].to_pin = out1 ent2.EModOutputs[out2].wire=ROPE ent2.EModOutputs[out2].Pwire=B
			return true
		else
			return false
		end
	end

	util.AddNetworkString("EmodCreateWire")
	util.AddNetworkString("EmodRemoveWire")
	net.Receive("EmodCreateWire",function(len,ply)
		local tbl = net.ReadTable()
		if IsValid(tbl.ent1.EModOutputs[tbl.out1].wire) then EModRemoveWire(tbl.ent1,tbl.out1) end
		if IsValid(tbl.ent2.EModOutputs[tbl.out2].wire) then EModRemoveWire(tbl.ent2,tbl.out2) end
		if CreateWire(tbl.ent1,tbl.ent2,tbl.out1,tbl.out2,tbl.fitto,tbl.length,tbl.material) then
			net.Start("EModGetOutputs")
				net.WriteEntity(tbl.ent1)
				net.WriteTable(tbl.ent1.EModOutputs)
			net.Send(ply)
			net.Start("EModGetOutputs")
				net.WriteEntity(tbl.ent2)
				net.WriteTable(tbl.ent2.EModOutputs)
			net.Send(ply)
		end
	end)
	net.Receive("EModRemoveWire",function(len,ply)
		local tbl = net.ReadTable()
		local ent1 = tbl[1]
		local pin1 = tbl[2]

		if not ent1 or not pin1 or not ent1.EModOutputs[pin1] or !IsValid(ent1) or !istable(ent1.EModOutputs[pin1]) then return end

		local ent2 = ent1.EModOutputs[pin1].to
		local pin2 = ent1.EModOutputs[pin1].to_pin
		-- PrintTable(tbl[1])
		if not ent2 or not pin2 or !IsValid(ent2) then return end

		EModRemoveWire(ent1,pin1)
		EModRemoveWire(ent2,pin2)

		net.Start("EModGetOutputs")
			net.WriteEntity(ent1)
			net.WriteTable(ent1.EModOutputs)
		net.Send(ply)
		net.Start("EModGetOutputs")
			net.WriteEntity(ent2)
			net.WriteTable(ent2.EModOutputs)
		net.Send(ply)
	end)
end

function TOOL:LeftClick(trace)
	if SERVER then
		if self:GetOwner():KeyDown(IN_SPEED) then
			local node = CreateNode(trace,self)
			return true
		end

		if trace.Entity.EMODable then
			if self:GetStage() == 0 then self:SetStage(1) else self:SetStage(0) end
			return true
		end
	else
		if self:GetOwner():KeyDown(IN_SPEED) then return true end
		if not trace.Entity.EMODable or self.Chatter + 0.1 > CurTime() then return false end
			self.Chatter = CurTime()

		if self:GetStage() == 0 then
			self.WireInfo.ent1 = trace.Entity
			self.WireInfo.out1 = self.SelectedOut
		elseif self:GetStage() == 1 then
			self.WireInfo.ent2 = trace.Entity
			self.WireInfo.out2 = self.SelectedOut

			self.WireInfo.fitto = self:GetClientNumber("fitto")
			self.WireInfo.length = self:GetClientNumber("length") 
			self.WireInfo.material = self:GetClientInfo("ropematerial")

			net.Start("EModCreateWire")
				net.WriteTable(self.WireInfo)
			net.SendToServer()

			self.WireInfo = {}
			GetConVar("emod_wire_lastnode"):SetFloat(0)
			self.LastNode = nil
		end
	end

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then
		if trace.Entity.EMODable and self.Chatter + 0.1 < CurTime() then
			self.Chatter = CurTime()
			self.SelectedOut = self.SelectedOut + 1
		end
	end
	return false
end

function TOOL:Reload(trace)
	if CLIENT then
		if self:GetStage() == 0 then
			if trace.Entity.EMODable then
				net.Start("EModRemoveWire")
					net.WriteTable({trace.Entity,self.SelectedOut})
				net.SendToServer()
			end
		else
			self:Holster()
		end
	else
		-- print(trace.Entity:WorldToLocal(trace.HitPos))
	end
	return true
end

function TOOL:Holster()
	self:SetStage(0)
	self:ClearObjects()
	if CLIENT then
		self.WireInfo = {}
		GetConVar("emod_wire_lastnode"):SetFloat(0)
		self.LastNode = nil
	end
end

function TOOL:DrawHUD()
	local trace = self:GetOwner():GetEyeTrace()
	self:VisualLimits(trace)
end

function TOOL:VisualLimits(trace)
	if IsValid(trace.Entity) and trace.Entity.EMODable then
			local outputs = self:GetOutputs(trace.Entity)
			if outputs and IsValid(outputs[self.SelectedOut].to) and outputs[self.SelectedOut].to.EMODable then
				local outputs2 = self:GetOutputs(outputs[self.SelectedOut].to)
				if outputs2 then
					local pin1,pin2 = outputs[self.SelectedOut].pinPos,outputs2[outputs[self.SelectedOut].to_pin].pinPos
					cam.Start3D()
						render.DrawLine(trace.Entity:LocalToWorld(pin1),outputs[self.SelectedOut].to:LocalToWorld(pin2),Color(0,255,0,math.abs(math.sin(CurTime()*2)*255)),false)
					cam.End3D()
				end
			end
	end
	if IsValid(self.WireInfo.ent1) then
		local pos = self.WireInfo.ent1:GetPos()
		local len = (self:GetClientNumber("fitto") and 500 or self:GetClientNumber("length",100))
		local BoxX,BoxY,BoxZ = pos.x-len,pos.y-len,pos.z-len
		-- if self:GetStage() == 1 and IsValid(self.WireInfo.ent1) and self.WireInfo.ent1 != trace.Entity then
		-- 	local E = util.TraceLine({start=self.WireInfo.ent1:GetPos(),endpos=trace.Entity:GetPos(),filter={self.WireInfo.ent1}}).Entity
		-- 	if IsValid(E) then
		-- 		local EN = E:GetPos()
		-- 		BoxX,BoxY,BoxZ = EN.x-len,EN.y-len,EN.z-len
		-- 	end
		-- end
		local DeltaX,DeltaY,DeltaZ = len*2,len*2,len*2
		local plypos = trace.HitPos
		local BoxColor,LineColor = Color(0,100,0,10),Color(0,100,0,200) 
		if pos:Distance(plypos) > len then BoxColor,LineColor = Color(200,0,0,10),Color(200,0,0,200) end
		cam.Start3D()
			render.SetColorMaterial()
			render.DrawBox(Vector(BoxX,BoxY,BoxZ),Angle(0,0,0),Vector(0,0,0),Vector(DeltaX,DeltaY,DeltaZ),BoxColor,true)
			render.DrawBox(Vector(BoxX+DeltaX,BoxY,BoxZ),Angle(0,0,0),Vector(0,0,0),Vector(-DeltaX,DeltaY,DeltaZ),BoxColor,true)

			render.DrawLine(Vector(BoxX,BoxY,BoxZ),Vector(BoxX+DeltaX,BoxY,BoxZ),LineColor,true)
			render.DrawLine(Vector(BoxX,BoxY,BoxZ),Vector(BoxX,BoxY+DeltaY,BoxZ),LineColor,true)
			render.DrawLine(Vector(BoxX,BoxY,BoxZ),Vector(BoxX,BoxY,BoxZ+DeltaZ),LineColor,true)

			render.DrawLine(Vector(BoxX+DeltaX,BoxY,BoxZ),Vector(BoxX+DeltaX,BoxY+DeltaY,BoxZ),LineColor,true)
			render.DrawLine(Vector(BoxX+DeltaX,BoxY,BoxZ),Vector(BoxX+DeltaX,BoxY,BoxZ+DeltaZ),LineColor,true)

			render.DrawLine(Vector(BoxX,BoxY+DeltaY,BoxZ),Vector(BoxX+DeltaX,BoxY+DeltaY,BoxZ),LineColor,true)
			render.DrawLine(Vector(BoxX,BoxY+DeltaY,BoxZ),Vector(BoxX,BoxY+DeltaY,BoxZ+DeltaZ),LineColor,true)

			render.DrawLine(Vector(BoxX,BoxY,BoxZ+DeltaZ),Vector(BoxX+DeltaX,BoxY,BoxZ+DeltaZ),LineColor,true)
			render.DrawLine(Vector(BoxX,BoxY,BoxZ+DeltaZ),Vector(BoxX,BoxY+DeltaY,BoxZ+DeltaZ),LineColor,true)

			render.DrawLine(Vector(BoxX+DeltaX,BoxY+DeltaY,BoxZ+DeltaZ),Vector(BoxX,BoxY+DeltaY,BoxZ+DeltaZ),LineColor,true)
			render.DrawLine(Vector(BoxX+DeltaX,BoxY+DeltaY,BoxZ+DeltaZ),Vector(BoxX+DeltaX,BoxY,BoxZ+DeltaZ),LineColor,true)
			render.DrawLine(Vector(BoxX+DeltaX,BoxY+DeltaY,BoxZ+DeltaZ),Vector(BoxX+DeltaX,BoxY+DeltaY,BoxZ),LineColor,true)

		cam.End3D()

	end
end

function TOOL:DrawToolScreen(w,t)
	draw.RoundedBox(4,0,0,w,t,Color(238,238,238))
	local trace = self:GetOwner():GetEyeTrace()
	local val = self:GetClientNumber("fitto") == 1 and "Auto" or self:GetClientNumber("length",100)
	draw.SimpleText("Wire Length: "..tostring(val),"DermaLarge",w/2,t*0.1,Color(20,20,20),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	draw.SimpleText(self.SelectedOut,"DermaLarge",w/2,t*0.2,Color(20,20,20),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	if trace.Entity.EMODable then
		local outputs = self:GetOutputs(trace.Entity)
		draw.RoundedBox(4,w*0.05,t*0.25,w*0.9,t*0.7,Color(204,204,204))

		if self:GetStage() == 1 and IsValid(self.WireInfo.ent1) and self.WireInfo.ent1 != trace.Entity then
			-- if not  then
				-- draw.SimpleText("Intersection","DermaLarge",w/2,t*0.25+(t*0.7)/2,Color(20,20,20),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				-- return
			-- end
		end
		if not outputs then
			draw.RoundedBox(8,w*0.3-15,t*0.6-15,30,30,Color(102+102*math.abs(math.sin(CurTime()*2)),102+102*math.abs(math.sin(CurTime()*2)),102+102*math.abs(math.sin(CurTime()*2))))
			draw.RoundedBox(8,w*0.5-15,t*0.6-15,30,30,Color(102+102*math.abs(math.sin(CurTime()*2+math.pi/3)),102+102*math.abs(math.sin(CurTime()*2+math.pi/3)),102+102*math.abs(math.sin(CurTime()*2+math.pi/3))))
			draw.RoundedBox(8,w*0.7-15,t*0.6-15,30,30,Color(102+102*math.abs(math.sin(CurTime()*2+math.pi/2)),102+102*math.abs(math.sin(CurTime()*2+math.pi/2)),102+102*math.abs(math.sin(CurTime()*2+math.pi/2))))
			return
		end


		local out_x,out_y,out_w,out_t = w*0.05,t*0.25,w*0.9,t*0.7
		local keys = {}
		for k,v in pairs(outputs) do
			keys[v.name] = table.Count(keys)
		end
		if self.SelectedOut > table.Count(keys) then self.SelectedOut = 1 end

		for k,INFO in pairs(outputs) do
			draw.RoundedBox(4,out_x+5,out_y+5+keys[INFO.name]*35,out_w-10,30,self.SelectedOut == k and Color(84,84,184) or Color(184,184,184))
			draw.SimpleText(INFO.name,"DermaLarge",out_x+5+(out_w-10)/2,out_y+7+25/2+keys[INFO.name]*35,INFO.to != nil and Color(246,45,45) or (self.SelectedOut == k and Color(200,200,255) or Color(100,100,100)),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	else self.SelectedOut = 1 end
end


if CLIENT then
	local TOOLCache = {}
	local TOOLNextNet = 0
	local Stage = 0

	function TOOL:Think()
		Stage = self:GetStage()
		if self:GetClientNumber("lastnode") != 0 then self.LastNode = Entity(self:GetClientNumber("lastnode")) else self.LastNode = nil end
		if input.IsButtonDown(KEY_LALT) and self:GetClientNumber("fitto") == 0 then
			local val = self:GetClientNumber("length",100)
			local var = GetConVar("emod_wire_length")
			if input.WasMousePressed(MOUSE_WHEEL_UP) then
				var:SetFloat(math.Clamp(val+5,10,500))
			elseif input.WasMousePressed(MOUSE_WHEEL_DOWN) then
				var:SetFloat(math.Clamp(val-5,10,500))
			end
		end
	end

	hook.Add("PlayerBindPress","EMod_Wire_ScrollSuppresor",function(ply, bind, pressed)
		-- if ply:GetToolObject() == "emod_wire" and input.IsKeyDown(KEY_LALT) and (bind == "invprev" or bind == "invnext") then
			-- return true
		-- end
	end)

	net.Receive("EModGetOutputs",function()
		local ent = net.ReadEntity()
		local out = net.ReadTable()

		TOOLCache[ent] = {out,CurTime()}
	end)

	function TOOL:RequestOutputs(ent)
		if TOOLNextNet + 0.5 > CurTime() then return end
		TOOLNextNet = CurTime()
		net.Start("EModGetOutputs")
			net.WriteEntity(ent)
		net.SendToServer()
	end

	function TOOL:GetOutputs(ent)
		if not TOOLCache[ent] then
			self:RequestOutputs(ent)
			return false
		else
			if TOOLCache[ent][2] + 2 < CurTime() then
				self:RequestOutputs(ent)
				return TOOLCache[ent][1] or false
			else
				return TOOLCache[ent][1] or false
			end
		end
	end
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Description = "#tool.emod_wire.desc" } )

	CPanel:MatSelect("emod_wire_ropematerial",List,true,50,80)

	CPanel:AddControl("checkbox",{Label="#tool.emod_wire.auto",Command="emod_wire_fitto",Help=true})
end