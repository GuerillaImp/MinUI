--
-- Options Module by Grantus
--
-- User Interface for grUF configuration / debugging
-- 

local Options = {}

--
-- Create Frame and it's Drag handler
--
Options = UI.CreateFrame("RiftWindow", "grUF Options", grUF_Core.context)
Options.visible = false
Options:SetVisible(Options.visible)
Options:SetPoint("TOPLEFT", grUF_Core.context, "TOPLEFT", 0, 0 )
Options:SetTitle("grUF Options")
Options:SetHeight(500)
Options:SetWidth(500)
Options.drag = UI.CreateFrame("Frame", "grUF Options Drag Handle", Options)
Options.drag:SetPoint("TOPCENTER", Options, "TOPCENTER", 0, 0 )
Options.drag:SetHeight(50)
Options.drag:SetWidth(500)
Options.drag:SetLayer(10)

--
-- Left Button Down
--
function Options.drag.Event:LeftDown()
	self.MouseDown = true
	mouseData = Inspect.Mouse()
	self.MyStartX = self:GetLeft()
	self.MyStartY = self:GetTop()
	self.StartX = mouseData.x - self.MyStartX
	self.StartY = mouseData.y - self.MyStartY
	tempX = self:GetLeft()
	tempY = self:GetTop()
	Options:SetPoint("TOPLEFT", grUF_Core.context, "TOPLEFT", tempX, tempY)
end

--
-- Mouse Move
--
function Options.drag.Event:MouseMove()
	if self.MouseDown then
		local newX, newY
		mouseData = Inspect.Mouse()
		newX = mouseData.x - self.StartX
		newY = mouseData.y - self.StartY
		Options:SetPoint("TOPLEFT", grUF_Core.context, "TOPLEFT", newX, newY)
	end
end

--
-- Left Up
--
function Options.drag.Event:LeftUp()
	if self.MouseDown then
		self.MouseDown = false
	end
end

--
-- Show the Options Frame, create it if it has not been initialised
--
function Options:ToggleOptionsWindow()
	print("Options: toggle Options window")
	
	if(Options.visible)then
		self.visible = false
		self:SetVisible(self.visible)
	else
		self.visible = true
		self:SetVisible(self.visible)
	end
end

--
-- *** Register with grUF Core ***
--
grUF_Core:RegisterModule("Options", Options)