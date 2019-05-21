AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
EMod.RegisterComponent(ENT, "E-Light",EMod.ComponentsTypes.Output,"Light", true, "EMod Official Pack")

function ENT:EModSetup()
	self:AddPin(EMod.Plus,Vector(13.844569,7.978677,1.031252))
	self:AddPin(EMod.Minus,Vector(13.900087,-7.974960,1.031258))
	self:AddScheme(1, EMod.Scheme(2))
	self:AddScheme(2, EMod.Scheme(1))

	self:EModSetModel("models/emod/officelight_1.mdl")
end

function ENT:EModSettings(settings)
	self:EModSetModel(settings.model)
end

-- if SERVER then
-- 	function ENT:Initialize()
		
		
-- 		self.LastCurrent = 0
-- 		self.EModScheme = {
-- 			[1]={[2]={ChargeSettings={I={tomA(0.3),false}}}},
-- 			[2]={},
-- 		}
-- 		self:RegisterCallback(1,function(edata) self:SetPower(edata.P) self.LastCurrent = CurTime() end,function(edata) EModApplyData(edata,{I={tomA(0.3),false}}) return edata end)
-- 	end

-- end

-- function ENT:SetupDataTables()
-- 	self:NetworkVar("Bool",0,"State")
-- 	self:NetworkVar("Float",0,"Power")

-- 	if SERVER then
-- 		self:SetState(false)
-- 		self:SetPower(0)
-- 	end
-- end

function ENT:Think()

	-- if SERVER then
		-- self:NextThink( CurTime() + EMODTick )
		-- if self:GetState() then
		-- 	self:SetMaterial("models/emod/officelight_1_on")
		-- else
		-- 	self:SetMaterial("models/emod/officelight_1")
		-- end
		-- if self.LastCurrent + EMODTick > CurTime() then self:SetState(true) return true else self:SetState(false) return true end
	-- end
	-- if not self:GetState() or self:GetPower() < 15 then return end
	if SERVER then return end
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