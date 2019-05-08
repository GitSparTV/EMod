AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Wind Turbine"
ENT.Author = "Spar"
ENT.Contact = "developspartv@gmail.com"
ENT.AutomaticFrameAdvance = true

ENT.EMODable = true

	if SERVER then

		function ENT:Initialize()
			self:SetModel("models/emod/emod_windturbine.mdl")
			self:SetMaterial("models/debug/debugwhite")
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
			timer.Simple(1,function()
				self:ResetSequence("rotate")
				self:SetPlaybackRate(-1)
			end)
			self:PhysWake()
			self:SetCollisionGroup( COLLISION_GROUP_WORLD )
			
			self.EModOutputs = {{name="PIN_1",pinPos=Vector(0,5.937500,0)},{name="PIN_2",pinPos=Vector(-5.937504,0,0)}}
			self.EModScheme = {
				[1]={[2]={}},
				[2]={[1]={}},
			}
		end

		function ENT:Think()
			self:NextThink(CurTime() + EMODTick)
			return true
		end

	end