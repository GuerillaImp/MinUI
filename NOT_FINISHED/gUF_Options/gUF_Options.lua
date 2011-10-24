--
-- gUF_Options Module by Grantus
--
-- User Interface for grUF configuration / debugging
-- 

--
-- gUF Options Namespace
--
gUF_Options = {}
gUF_Options.visible = false

--
-- Create Frame and it's Drag handler
--
gUF_Options.frame = UI.CreateFrame("RiftWindow", "gUF_Options", gUF.context)
gUF_Options.frame:SetVisible(gUF_Options.visible)
gUF_Options.frame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", 0, 0 )
gUF_Options.frame:SetTitle("Grantus Unit Frames Config")
gUF_Options.frame:SetHeight(900)
gUF_Options.frame:SetWidth(900)
gUF_Options.frame:SetLayer(4)

gUF_Options.drag = UI.CreateFrame("Frame","gUF_Options_Drag", gUF.context) 
gUF_Options.drag:SetVisible(gUF_Options.visible)
gUF_Options.drag:SetPoint("TOPLEFT", gUF_Options.frame, "TOPLEFT", 0, 0 )
gUF_Options.drag:SetHeight(900)
gUF_Options.drag:SetWidth(900)
gUF_Options.drag:SetLayer(5)

gUF_Options.initialised = false

gUF_Options.addonButtons = Box.new( 5, {r=0,g=0,b=0,a=0.0}, "vertical", "down", gUF.context, 6 )
gUF_Options.addonButtons:SetPoint("TOPLEFT", gUF_Options.frame, "TOPLEFT", 30, 60)
								
gUF_Options.configPane = Panel.new( 675, 800, {r=0,g=0,b=0,a=0.0}, gUF.context, 6 )
gUF_Options.configPane:SetPoint("TOPLEFT", gUF_Options.frame, "TOPLEFT", 200, 60)
gUF_Options.configPane:SetTexture(gUF.backgrounds["backdrop"])


gUF_Options.optionsPanes = {}

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
	gUF_Options.frame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", tempX, tempY)
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
		gUF_Options.frame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", newX, newY)
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
-- Load all modules / options for gUF addons
--
function gUF_Options:Initialise()
	for name,f in pairs (gUF_AddOn_Config) do
		local optionsItems = f()
		local triggerButton = optionsItems[1]
		local optionsPane = optionsItems[2]
		gUF_Options.optionsPanes[name] = optionsPane
		
		function triggerButton.Event:LeftPress()
			print ("show options pane for ", name)
			
			gUF_Options.configPane:RemoveItem(1) -- remove any previous panels
			print(optionsPane)
			gUF_Options.configPane:AddItem( optionsPane, "TOPLEFT","TOPLEFT",5,5) -- add this one
			optionsPane:SetVisible(true)
		end
		
		self.addonButtons:AddItem(triggerButton)
	end

	--gUF_Options.addonButtons:SetVisible(true)
	--gUF_Options.configPane:SetVisible(true)
	gUF_Options.initialised = true
end


--
-- Show the gUF_Options Frame, create it if it has not been initialised
--
function  gUF_Options:ToggleOptionsWindow()
	print("gUF_Options: ToggleOptionsWindow")
	
	if ( gUF_Options.visible ) then
		gUF_Options.visible = false
		gUF_Options.frame:SetVisible(gUF_Options.visible)
		gUF_Options.drag:SetVisible(gUF_Options.visible)
		gUF_Options.addonButtons:SetVisible(gUF_Options.visible)
		gUF_Options.configPane:SetVisible(gUF_Options.visible)
	else
		gUF_Options.visible = true
		if not (gUF_Options.initialised) then
			gUF_Options:Initialise()
		end
		print(gUF_Options.visible)
		gUF_Options.frame:SetVisible(gUF_Options.visible)
		gUF_Options.drag:SetVisible(gUF_Options.visible)
		gUF_Options.addonButtons:SetVisible(gUF_Options.visible)
		gUF_Options.configPane:SetVisible(gUF_Options.visible)
	end
end

	
-- Handle User Customisation
table.insert(Command.Slash.Register("guf"), { gUF_Options.ToggleOptionsWindow, "gUF_Options", "gUF_Options Slash Command"})
