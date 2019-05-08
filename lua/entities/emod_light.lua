AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Office Light 1"

ENT.EMODable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/emod/officelight_1.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		
		self.Temperature = 25.0
		self.LastCurrent = 0
		self.EModOutputs = {{name="ANODE",pinPos=Vector(13.844569,7.978677,1.031252)},{name="KATHODE",pinPos=Vector(13.900087,-7.974960,1.031258)}}
		self.EModScheme = {
			[1]={[2]={ChargeSettings={I={tomA(0.3),false}}}},
			[2]={},
		}
		self:RegisterCallback(1,function(edata) self:SetPower(edata.P) self.LastCurrent = CurTime() end,function(edata) EModApplyData(edata,{I={tomA(0.3),false}}) return edata end)
	end

end

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"State")
	self:NetworkVar("Float",0,"Power")

	if SERVER then
		self:SetState(false)
		self:SetPower(0)
	end
end

function ENT:Think()

	if SERVER then
		self:NextThink( CurTime() + EMODTick )
		if self:GetState() then
			self:SetMaterial("models/emod/officelight_1_on")
		else
			self:SetMaterial("models/emod/officelight_1")
		end
		if self.LastCurrent + EMODTick > CurTime() then self:SetState(true) return true else self:SetState(false) return true end
	end
	if not self:GetState() or self:GetPower() < 15 then return end
	local dlight = DynamicLight(self:EntIndex())
	if ( dlight ) then
		dlight.pos = self:LocalToWorld(Vector(0,0,-16))
		dlight.r = 200+math.random(-5,5)
		dlight.g = 200+math.random(-5,5)
		dlight.b = 200
		dlight.brightness = 0
		dlight.Decay = 1000
		dlight.Size = 1024
		dlight.DieTime = CurTime() + EMODTick
	end
end