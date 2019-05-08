TOOL.Category = "I/O"
TOOL.Name = "E-Light"
TOOL.Tab = "EMod"

local ModelList = {
	["models/emod/officelight_1.mdl"]={}
}

TOOL.ClientConVar = {
	model="mmodels/emod/officelight_1.mdl"
}

TOOL.LastMessage = CurTime()
if CLIENT then
	language.Add("tool.emod_light.name","E-Light")
	language.Add("tool.emod_light.desc","Creates light")
	language.Add("tool.emod_light.left","Create/Update Light")
	language.Add("Undone_emod_light","Undone E-Light")
end

TOOL.Information = {
	{ name = "left", stage = 0},
}

function TOOL:IsValidModelForTool(model)
	for mdl, _ in pairs(ModelList) do
		if ( mdl:lower() == model:lower() ) then return true end
	end
	return false
end


local function Create(trace,self,model)
	local obj = ents.Create("emod_light")
	if ( !IsValid( obj ) ) then return false end
	obj:SetModel(model)
	obj:Spawn()
	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch - 90
	local min = obj:OBBMins()
	obj:SetPos( trace.HitPos - trace.HitNormal * min.z * 5 )
	obj:SetAngles( ang )
	obj:SetPlayer(self:GetOwner())

	constraint.Weld(obj,trace.Entity,0,trace.PhysicsBone,0,1,true)
	DoPropSpawnedEffect(obj)
	local physobj = obj:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:EnableMotion(false)
		self:GetOwner():AddFrozenPhysicsObject(obj,physobj)
	end

	undo.Create( "emod_light" )
		undo.AddEntity(obj)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()

	return obj
end

function TOOL:LeftClick(trace)
	if ( IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	if ( CLIENT ) then return true end
		local model = self:GetClientInfo( "model" )
	if ( !util.IsValidModel( model ) || !util.IsValidProp( model ) || !self:IsValidModelForTool( model ) ) then return false end
		local obj = Create(trace,self,model)
	return true
end

function TOOL:UpdateGhostButton( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || IsValid( trace.Entity ) && ( trace.Entity:GetClass() == "emod_light" || trace.Entity:IsPlayer() ) ) then
		ent:SetNoDraw( true )
		return
	end

	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch - 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z*4 )
	ent:SetAngles( ang )

	ent:SetNoDraw( false )

end

if SERVER then
	function TOOL:Think()
		local mdl = self:GetClientInfo( "model" )
		if ( !self:IsValidModelForTool( mdl ) ) then self:ReleaseGhostEntity() return end

		if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
			self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
		end

		self:UpdateGhostButton( self.GhostEntity, self:GetOwner() )
	end
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Description = "#tool.emod_light.desc" } )

	CPanel:AddControl( "PropSelect", { Label = "#tool.emod_light.model", ConVar = "emod_light_model", Height = 0, Models = ModelList } )
end