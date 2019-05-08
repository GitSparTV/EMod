AddCSLuaFile()
DEFINE_BASECLASS("emod_base")
ENT.Category = "EMod"
ENT.Spawnable = true
ENT.PrintName = "EMod Meter"

ENT.EMODable = true


if SERVER then

	function ENT:Initialize()
		self:SetModel("models/emod/emod_meter.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()
		self:SetCollisionGroup(COLLISION_GROUP_NONE)

		self.Temperature = 25.0
		self.EModOutputs = {{name="INPUT",pinPos=Vector(-26.922850,15.989843,0.077148)},{name="OUTPUT",pinPos=Vector(-26.922947,-15.988745,0.101563)}}
		self.EModScheme = {
			[1]={[2]={}},
			[2]={[1]={}}
		}
		self:RegisterCallback(1,function(edata,dedata) self:SetVal(math.Clamp(dedata.I,self:GetMinVal(),self:GetMaxVal())) self.LastCurrent = CurTime() end)
		self:RegisterCallback(2,function(edata,dedata) self:SetVal(math.Clamp(-dedata.I,self:GetMinVal(),self:GetMaxVal())) self.LastCurrent = CurTime() end)
		self.LastCurrent = 0
	end

	function ENT:Think()
		if CurTime()-self.LastCurrent > EMODTick then self:SetVal(0) end
		self:NextThink(CurTime() + EMODTick)
		return true
	end
end

if CLIENT then
	ENT.valSys = SysTime()
	ENT.preval = 0
	ENT.moveTo = 0
	ENT.Move = false
	function ENT:Draw()
		self:DrawModel()
		cam.Start3D2D(self:LocalToWorld(Vector(-0.45,-5.6,9.95)),self:LocalToWorldAngles(Angle(0,90,90)),0.1)
			local w,t = 114,56
			local light = GetLightAmount(self:LocalToWorld(Vector(-0.45,-5.65,9.95)))
			if self.preval != self:GetVal() and not self.Move then self.valSys = SysTime() self.Move = true self.moveTo = self:GetVal() end
			if Erp(SysTime()-self.valSys,1,self.preval,self.moveTo) == self.moveTo and self.Move then
				self.preval = self.moveTo
				self.Move = false
			end
			local goval = Erp(SysTime()-self.valSys,1,self.preval,self.moveTo)

			local Val = math.Remap(math.Clamp(goval,self:GetMinVal(),self:GetMaxVal()),self:GetMinVal(),self:GetMaxVal(),0,1)
			local angle = math.Remap(math.Clamp(Val,0,1),0,1,-30,-150)

				draw.NoTexture()
				surface.SetDrawColor(Color(0,0,0,light))
				surface.HalfCircle(w/2-(t*0.8),t*0.3,t*0.8,true)
				draw.SimpleText(self:GetMinVal(),"DermaDefault",w/2-t*0.75,t*0.62,Color(0,0,0,light),1,1)
				draw.SimpleText(self:GetMaxVal(),"DermaDefault",w/2+t*0.75,t*0.62,Color(0,0,0,light),1,1)

				draw.SimpleText(self:GetLetter(),"DermaLarge",w/2,t*0.7,Color(50,0,0,light),1,1)
				surface.SetDrawColor(Color(100,0,0,light))
				surface.DrawTexturedRectRotatedPoint(w/2,t*1.1,t,3,angle,t*0.3,0)
		cam.End3D2D()
	end

	function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )

		local c = math.cos( math.rad( rot ) )
		local s = math.sin( math.rad( rot ) )

		local newx = y0 * s - x0 * c
		local newy = y0 * c + x0 * s

		surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )

	end

	function Erp(t, d, b, c) return (c-b) * (math.pow(math.Clamp(t,0,d) / d - 1, 3) + 1) + b end

	function surface.HalfCircle(x0,y0,r,side)
		x0 = x0+r
		if side then y0 = y0+r end
		local function y(x) return side and y0-math.sqrt((r^2)-((x-x0)^2)) or y0+math.sqrt((r^2)-((x-x0)^2)) end
		local dots = {}

		if side then
			for I=x0-r,x0+r,0.1 do
				table.insert(dots,{x=I,y=y(I)})
			end
		else
			for I=x0+r,x0-r,-0.1 do
				table.insert(dots,{x=I,y=y(I)})
			end
		end

		surface.DrawPoly(dots)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"Val")
	self:NetworkVar("Float",1,"MinVal")
	self:NetworkVar("Float",2,"MaxVal")
	self:NetworkVar("String",0,"Letter")

	if SERVER then
		self:SetVal(0)
		self:SetLetter("A")
		self:SetMinVal(0)
		self:SetMaxVal(1)
	end
end