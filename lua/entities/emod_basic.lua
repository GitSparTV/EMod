AddCSLuaFile()
DEFINE_BASECLASS("emod_base")

EMod.RegisterComponent(ENT,"E-Basic","Demo",true,"Spar")

function ENT:EModSetup()
	
end

function ENT:EModSettings(settings)
	self:SetModel(settings.model)
end