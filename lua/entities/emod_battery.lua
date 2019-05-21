AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
EMod.RegisterComponent(ENT, "E-Battery", EMod.ComponentsTypes.Source, "Energy Sources", true, "EMod Official Pack")

function ENT:EModSetup()
	self:AddPin(EMod.Plus, Vector(-4.902077, -6.536953, 1.198760))
	self:AddPin(EMod.Zero, Vector(-4.902195, 6.757458, 1.200500))
	self:AddScheme(1,nil)
	self:AddScheme(2,nil)
	self.State = false

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	self:EModSetModel("models/Items/car_battery01.mdl")
end

function ENT:EModSettings(settings)
	self:EModSetModel(settings.model)
end

function ENT:Use(_, caller)
	self.State = not self.State
	self:EmitSound("buttons/button14.wav", 75, 150)
end
-- if SERVER then
-- 	function ENT:Initialize()
-- 		self:SetModel("models/Items/car_battery01.mdl")
-- 		self:PhysicsInit(SOLID_VPHYSICS)
-- 		self:SetMoveType(MOVETYPE_VPHYSICS)
-- 		self:SetSolid(SOLID_VPHYSICS)
-- 		self:SetUseType(SIMPLE_USE)
-- 		self:PhysWake()
-- 		self:SetCollisionGroup(COLLISION_GROUP_NONE)
-- 		self.Temperature = 25.0
-- 		self:SetCapacity(1000)
-- 		self:SetAvailable(1000)
-- 		self:RegisterCallback(2,function(edata)
-- 			if edata.I == math.huge then
-- 				util.BlastDamage(self:GetPlayer() or self.Player,self:GetPlayer() or self.Player,self:GetPos()+Vector(0,0,100),100,50) self.Think = nil
-- 				local effectdata = EffectData()
-- 				effectdata:SetOrigin(self:GetPos())
-- 				util.Effect( "Explosion", effectdata )
-- 				self:Remove()
-- 				return
-- 			end
-- 		EModPerformDischarge(self,edata.I)
-- 		if self:GetAvailable() == 0 or edata.I == 0 then return end
-- 		self:MakeTick(edata)
-- 	end)
-- 	end
-- 	function ENT:Use(_,caller)
-- 		self:SetState(!self:GetState())
-- 		self:EmitSound("buttons/button14.wav",75,150)
-- 	end
-- 	function ENT:Think()
-- 		if self:GetState() then
-- 			self:FlowCurrent(1,{ChargeOwner=self,ChargeID=SysTime(),Route={},I=math.huge,U=58})
-- 			self:NextThink(CurTime() + EMODTick)
-- 			return true
-- 		end
-- 	end
-- end
-- if CLIENT then
-- 	function ENT:Think()
-- 		if self:GetState() then
-- 			local dlight = DynamicLight(self:EntIndex())
-- 			if ( dlight ) then
-- 				dlight.pos = self:LocalToWorld(Vector(0,0,10))
-- 				dlight.r = self:GetAvailable() == 0 and 100 or 0
-- 				dlight.g = self:GetAvailable() != 0 and 100 or 0
-- 				dlight.b = 0
-- 				dlight.brightness = 1
-- 				dlight.Decay = 0
-- 				dlight.Size = 100
-- 				dlight.DieTime = CurTime() + EMODTick
-- 			end
-- 		end
-- 	end
-- 	function ENT:Draw()
-- 		self:DrawModel()
-- 		cam.Start3D2D(self:LocalToWorld(Vector(-4,5.4,4.7)),self:LocalToWorldAngles(Angle(0,0,0)),0.1)
-- 			local percent = self:GetAvailable()*100/self:GetCapacity()
-- 			local light = GetLightAmount(self:GetPos())
-- 			draw.RoundedBox(2,0,53*(percent/100),35,53-53*(percent/100),Color(255,0,0,light))
-- 			draw.RoundedBox(2,0,0,35,53*(percent/100),Color(0,255,0,light))
-- 			-- draw.SimpleText(math.Round(self:GetAvailable(),3),"DermaLarge",50,50,Color(255,255,255),1,1) |Debug|
-- 		cam.End3D2D()
-- 	end
-- end
-- function ENT:SetupDataTables()
-- 	self:NetworkVar("Bool",0,"State")
-- 	self:NetworkVar("Float",0,"Capacity")
-- 	self:NetworkVar("Float",1,"Available")
-- 	if SERVER then
-- 		self:SetState(false)
-- 	end
-- end