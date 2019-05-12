function EMod.Menu()
	local frame = vgui.Create("DFrame",nil,"EModMenu")
	frame:SetSize(math.floor(ScrW()*0.9),math.floor(ScrH()*0.9))
	frame:Center()
	frame:MakePopup()
	frame:DockPadding( 5, 48 + 5, 5, 5 )
	frame:SetTitle("")

	function frame:Paint(w,t)
		draw.RoundedBox(8,0,0,w,t,Color(50,50,50))
		draw.RoundedBoxEx(8,0,0,w,48,Color(100,100,100),true,true,false,false)
	end

	function frame:Think()

		local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
		local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )

		if ( self.Dragging ) then

			local x = mousex - self.Dragging[1]
			local y = mousey - self.Dragging[2]

			-- Lock to screen bounds if screenlock is enabled
			if ( self:GetScreenLock() ) then

				x = math.Clamp( x, 0, ScrW() - self:GetWide() )
				y = math.Clamp( y, 0, ScrH() - self:GetTall() )

			end

			self:SetPos( x, y )

		end

		if ( self.Hovered && self.m_bSizable && mousex > ( self.x + self:GetWide() - 46 ) && mousey > ( self.y + self:GetTall() - 46 ) ) then

			self:SetCursor( "sizenwse" )
			return

		end

		if ( self.Hovered && self:GetDraggable() && mousey < ( self.y + 48 ) ) then
			self:SetCursor( "sizeall" )
			return
		end

		self:SetCursor( "arrow" )

		-- Don't allow the frame to go higher than 0
		if ( self.y < 0 ) then
			self:SetPos( self.x, 0 )
		end

	end

	function frame:OnMousePressed()
		if ( self:GetDraggable() && gui.MouseY() < (self.y + 48) ) then
			self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
			self:MouseCapture( true )
			return
		end
	end

	local 


end