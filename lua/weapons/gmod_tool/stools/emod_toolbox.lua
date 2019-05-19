TOOL.Category = "EMod Tools"
TOOL.Name = "E-ToolBox"
TOOL.Tab = "EMod"

TOOL.Information = {
	{
		name = "left"
	},
	{
		name = "right"
	}
}

function TOOL:LeftClick(trace)
	if (IsValid(trace.Entity) and trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return true end
	if (not util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone)) then return false end
	local ply = self:GetOwner()
	-- Get ToolBox Data here --
	-- if ( !data ) then return false end
	-- If HitEntity is the same type then update here --
	-- CheckLimit here
	-- if ( IsValid( pl ) && !pl:CheckLimit( "balloons" ) ) then return end
	local ent = ents.Create("emod_light")
	if (not IsValid(ent)) then return end
	ent:Spawn()
	ent:SetPlayer(pl)
	ent.Player = pl

	if (IsValid(pl)) then
		pl:AddCount("emod_highload", ent)
		pl:AddCleanup("emod_highload", ent)
	end

	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos - trace.HitNormal * min.z)
	undo.Create("ToolBox")
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	undo.Finish()

	return true
end

function TOOL:RightClick(trace)
	return self:LeftClick(trace, false)
end

if (SERVER) then
	function MakeBalloon(pl, r, g, b, force, Data)
		if (IsValid(pl) and not pl:CheckLimit("balloons")) then return end
		local balloon = ents.Create("gmod_balloon")
		if (not IsValid(balloon)) then return end
		duplicator.DoGeneric(balloon, Data)
		balloon:Spawn()
		duplicator.DoGenericPhysics(balloon, pl, Data)
		force = math.Clamp(force, -1E34, 1E34)
		balloon:SetColor(Color(r, g, b, 255))
		balloon:SetForce(force)
		balloon:SetPlayer(pl)
		balloon.Player = pl
		balloon.r = r
		balloon.g = g
		balloon.b = b
		balloon.force = force

		if (IsValid(pl)) then
			pl:AddCount("balloons", balloon)
			pl:AddCleanup("balloons", balloon)
		end

		return balloon
	end

	duplicator.RegisterEntityClass("gmod_balloon", MakeBalloon, "r", "g", "b", "force", "Data")
end

function TOOL:UpdateGhostBalloon(ent, ply)
	if (not IsValid(ent)) then return end
	local trace = ply:GetEyeTrace()

	if (not trace.Hit or IsValid(trace.Entity) and (trace.Entity:IsPlayer() or trace.Entity:GetClass() == "gmod_balloon")) then
		ent:SetNoDraw(true)

		return
	end

	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint(CurPos - (trace.HitNormal * 512))
	local Offset = CurPos - NearestPoint
	local pos = trace.HitPos + Offset
	local modeltable = list.Get("BalloonModels")[self:GetClientInfo("model")]

	if (modeltable.skin) then
		ent:SetSkin(modeltable.skin)
	end

	ent:SetPos(pos)
	ent:SetAngles(Angle(0, 0, 0))
	ent:SetNoDraw(false)
end

function TOOL:Think()
	-- if ( !IsValid( self.GhostEntity ) || self.GhostEntity.model != self:GetClientInfo( "model" ) ) then
	-- 	local modeltable = list.Get( "BalloonModels" )[ self:GetClientInfo( "model" ) ]
	-- 	if ( !modeltable ) then self:ReleaseGhostEntity() return end
	-- 	self:MakeGhostEntity( modeltable.model, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	-- 	if ( IsValid( self.GhostEntity ) ) then self.GhostEntity.model = self:GetClientInfo( "model" ) end
	-- end
	-- self:UpdateGhostBalloon( self.GhostEntity, self:GetOwner() )
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Description = "#tool.balloon.help"
	})
end