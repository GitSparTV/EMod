AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Solar Panel"

ENT.EMODable = true


if SERVER then

	function ENT:Initialize()
		self:SetModel("models/emod/emod_solar.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()
		self:SetCollisionGroup(COLLISION_GROUP_NONE)

		self.Temperature = 25.0
		self.EModOutputs = {{name="ANODE",pinPos=Vector(6.574390,0,3.982300)},{name="KATHODE",pinPos=Vector(6.533550,0,-3.518982)}}
		self.EModScheme = {
			[1]={[2]={}},
			[2]={[1]={}}
		}
	end

	function ENT:Think()
		trace = util.QuickTrace(self:GetPos(),self:LocalToWorld(Vector(0,0,32768)),{self})
		if trace.HitSky then
			local angle = self:GetAngles()
			local d = math.Round(math.Remap(math.Clamp(math.floor(math.abs(angle.p)),0,90),0,90,1,0),2)
			self:SetSunAmount(d)
		else
			self:SetSunAmount(self:GetSunAmount()-0.1)
		end
		self:NextThink(CurTime() + EMODTick)
		return true
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		cam.Start3D2D(self:LocalToWorld(Vector(-24.5,0,5.1)),self:LocalToWorldAngles(Angle(0,-90,0)),0.05)
			draw.RoundedBox(4,-25,0,50,8,Color(0,0,self:GetSunAmount()*255,self:GetSunAmount()*100))
		cam.End3D2D()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"SunAmount")

	if SERVER then
		self:SetSunAmount(0)
	end
end