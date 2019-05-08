AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Switch"

ENT.EMODable = true


if SERVER then

	function ENT:Initialize()
		self:SetModel("models/emod/lightswitch.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()
		self:SetCollisionGroup(COLLISION_GROUP_NONE)

		self.Temperature = 25.0
		self.EModOutputs = {{name="PIN_1",pinPos=Vector(6.574390,0,3.982300)},{name="PIN_2",pinPos=Vector(6.533550,0,-3.518982)}}
		self.EModScheme = {
			[1]={[2]={}},
			[2]={[1]={}}
		}
	end

	function ENT:Use(_,caller)
		self:SetState(!self:GetState())
		self:EmitSound("buttons/lightswitch2.wav")
	end

	function ENT:Think()
		self.EModScheme[1][2].disabled = !self:GetState()
		self.EModScheme[2][1].disabled = !self:GetState()
	end
end

if CLIENT then
	local ent
	local haloColor,haloBlur

	function ENT:Draw()
		self:DrawModel()
		if LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512 then
			if self:GetState() then
				haloColor = Color(255,100,100) haloBlur = 3 + math.sin(CurTime()*5)*2
			else
				haloColor = Color(100,100,255) haloBlur = 3
			end
			ent = self
		end
	end

	hook.Add("PreDrawHalos", "EModDrawHalos", function()
		if ent then
			halo.Add({ent}, haloColor, haloBlur, haloBlur, 1, true, true)
			ent = nil
			haloColor = nil
			haloBlur = nil
		end
	end)
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool",1,"State")

	if SERVER then
		self:SetState(false)
	end
end