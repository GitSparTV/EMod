AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
EMod.RegisterComponent(ENT, "E-Basic", "Demo", true, "Spar")

function ENT:EModSetup()
	self:SetTemperature(EMODTemp)
	self:AddPin("PIN_1")
	self:AddPin("PIN_2")
	self:AddScheme(1, EMod.Scheme(2))
	self:AddScheme(2, EMod.Scheme(1))
end

function ENT:EModSettings(settings)
	self:SetModel(settings.model)
end