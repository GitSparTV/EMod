AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Node"
ENT.Author = "Spar"
ENT.Contact = "developspartv@gmail.com"

ENT.EMODable = true

	if SERVER then

		function ENT:Initialize()
			self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
			self:SetMaterial("models/debug/debugwhite")
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)

			self:PhysWake()
			self:SetCollisionGroup( COLLISION_GROUP_WORLD )
			
			self.EModOutputs = {{name="PIN_1",pinPos=Vector(0,5.937500,0)},{name="PIN_2",pinPos=Vector(-5.937504,0,0)},{name="PIN_3",pinPos=Vector(5.937500,0,0)}}
			self.EModScheme = {
				[1]={[2]={},[3]={}},
				[2]={[1]={},[3]={}},
				[3]={[1]={},[2]={}}
			}
		end

		function EModGetAllConnections(ent,lastent)
			local tbl = {}
			table.insert(tbl,ent)
			for k,v in pairs(ent.ConnectedTo) do
				if lastent == v.to then continue end
				table.Add(tbl,EModGetAllConnections(v.to,ent))
			end

			return tbl
		end

	end