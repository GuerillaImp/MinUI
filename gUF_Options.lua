--
-- gUF_Options Module by Grantus
--
-- User Interface for grUF configuration / debugging
-- 

gUF_Options = {}

--
-- Create Frame and it's Drag handler
--
gUF_Options = UI.CreateFrame("RiftWindow", "grUF gUF_Options", gUF.context)
gUF_Options.visible = false
gUF_Options:SetVisible(gUF_Options.visible)
gUF_Options:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", 0, 0 )
gUF_Options:SetTitle("grUF gUF_Options")
gUF_Options:SetHeight(500)
gUF_Options:SetWidth(500)
gUF_Options.drag = UI.CreateFrame("Frame", "grUF gUF_Options Drag Handle", gUF_Options)
gUF_Options.drag:SetPoint("TOPCENTER", gUF_Options, "TOPCENTER", 0, 0 )
gUF_Options.drag:SetHeight(50)
gUF_Options.drag:SetWidth(500)
gUF_Options.drag:SetLayer(10)

--
-- Left Button Down
--
function gUF_Options.drag.Event:LeftDown()
	self.MouseDown = true
	mouseData = Inspect.Mouse()
	self.MyStartX = self:GetLeft()
	self.MyStartY = self:GetTop()
	self.StartX = mouseData.x - self.MyStartX
	self.StartY = mouseData.y - self.MyStartY
	tempX = self:GetLeft()
	tempY = self:GetTop()
	gUF_Options:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", tempX, tempY)
end

--
-- Mouse Move
--
function gUF_Options.drag.Event:MouseMove()
	if self.MouseDown then
		local newX, newY
		mouseData = Inspect.Mouse()
		newX = mouseData.x - self.StartX
		newY = mouseData.y - self.StartY
		gUF_Options:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", newX, newY)
	end
end

--
-- Left Up
--
function gUF_Options.drag.Event:LeftUp()
	if self.MouseDown then
		self.MouseDown = false
	end
end

--
-- Show the gUF_Options Frame, create it if it has not been initialised
--
function gUF_Options:TogglegOptionsWindow()
	print("gUF_Options: toggle gUF_Options window")
	
	if(gUF_Options.visible)then
		self.visible = false
		self:SetVisible(self.visible)
	else
		self.visible = true
		self:SetVisible(self.visible)
	end
end