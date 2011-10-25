--
-- ResourceBar Module by Grantus
--
-- Registers for Mana, Energy or Power Updates and Displays them
--

local ResourceBar = {}
ResourceBar.__index = ResourceBar

--
-- ResourceBar:new()
--
-- @params
--		unit string: player, player.target, etc
--
function ResourceBar.new( unit )
	local rBar = {}             		-- our new object
	setmetatable(rBar, ResourceBar)    	-- make ResourceBar handle lookup
	
	-- the modules unit
	rBar.unit = unit
	-- the modules enabled status
	rBar.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	rBar.settings = {
		["width"] = 0,
		["height"] = 0,
		["leftText"] = 0,
		["rightText"] = 0,
		["texturePath"] = 0,
		["font"] = 0,
		["fontSize"] = 0,
		["anchor"] = 0,
		["anchorUnit"] = 0,
		["anchorPointThis"] = 0,
		["anchorPointParent"] = 0,
		["anchorXOffset"] = 0,
		["anchorYOffset"] = 0
	}

	
	--
	-- main items of the bar
	--
	rBar.panel = nil
	rBar.textPanel = nil
	rBar.leftText = nil
	rBar.rightText = nil
	
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return rBar
end



--
-- Required Widget Functions: Modules are themselves "widgets" only they also register themselves for event callbacks
--

--
-- SetPoint
--
-- @params
--		anchorSelf string: the point on the Box that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		newParent table: frame this Box anchors on, expects a rift frame
--		anchorParent string: the point on the anchor shall the Box anchor on
--		xOffset number: the x offset
--		yOffset number: the y offset
--
function ResourceBar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	--print ( "ResourceBar set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function ResourceBar:SetVisible ( toggle )
	self.panel:SetVisible( toggle )
end

--
-- GetFrame
--
function ResourceBar:GetFrame()
	return self.panel:GetFrame()
end

--
-- GetHeight 
--
function ResourceBar:GetHeight()
	return self.settings.height
end

--
-- Get Width
--
function ResourceBar:GetWidth()
	return self.settings.width
end

--
-- ResourceBar Functions
--

--
-- Update Mana
--
function ResourceBar:Update( details  )
	if(details)then
	
		if (details.calling) then
			local resource = 0
			local resourceMax = 0
			
			if(details.calling == "mage" or details.calling == "cleric")then
				resource = details.mana
				resourceMax = details.manaMax
			elseif(details.calling == "warrior")then
				resource = details.power
				resourceMax = 100
			elseif(details.calling == "rogue")then
				resource = details.energy
				resourceMax = details.energyMax
			end
			
			local resourcesRatio = resource/resourceMax
			
			--
			-- Update the bar
			--
			self.bar:SetCurrentValue(resourcesRatio)

			--print (details.calling)
			local colors = gUF_Utils:GetResourcesColor(details.calling)
		
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		
			--
			-- now update the left and right text values - this will double check the calling, but it's clean code
			--
			self.leftText:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["leftText"], details ))
			self.rightText:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["rightText"], details ))
		
		-- no calling, no resources
		else
			self:SetVisible(false) 
		end
	else
		self:SetVisible(false)
	end
end



--
-- Required Functions for a Module
--

--
-- Get the Empty Settings Table for this Module
--
function ResourceBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function ResourceBar:Initialise( )
	self.panel = Panel.new( self.settings["width"], self.settings["height"], {r=0,g=0,b=0,a=0}, gUF.context, 1 )
	self.bar = Bar.new( self.settings["width"], self.settings["height"], "horizontal", "right", {r=0,g=0,b=0,a=0}, {r=0,g=0,b=0,a=0}, self.settings["texturePath"], gUF.context, (self.panel:GetLayer()+1)  )
	self.panel:AddItem( self.bar,  "TOPLEFT", "TOPLEFT", 0, 0 )
	
	
	--
	-- create text items
	--
	self.textPanel = Panel.new( self.panel:GetWidth(), self.panel:GetHeight(), {r=0,g=0,b=0,a=0}, gUF.context, (self.bar:GetLayer()+1) )
	self.leftText = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (self.textPanel:GetLayer()+2) )
	self.rightText = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (self.textPanel:GetLayer()+2) )
	self.textPanel:AddItem( self.leftText,  "CENTERLEFT", "CENTERLEFT", 0, 0 )
	self.textPanel:AddItem( self.rightText,  "CENTERRIGHT", "CENTERRIGHT", 0, 0 )
	
	self.panel:AddItem( self.textPanel, "TOPLEFT", "TOPLEFT", 0, 0 )
	
	self.panel:SetVisible( false )
end

--
-- On unit change, or unit available this method will be called by a frame container
-- Or in a "timed" update this should also be called (if I choose to go the timer route rather than event based route)
--
function ResourceBar:Refresh()
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		self:Update( details )
	else
		self:SetVisible(false)
	end
end

--
-- Simualte a Mana Update
--
function ResourceBar:Simulate()
	self:Update( gUF_Utils:GenerateSimulatedUnit() )
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function ResourceBar:CallBack( eventType, value ) -- not using value for now ...
	if ( self.enabled ) then
		if ( eventType == MANA_UPDATE ) then
			self:Refresh()
		elseif ( eventType == POWER_UPDATE ) then
			self:Refresh()
		elseif ( eventType == ENERGY_UPDATE ) then
			self:Refresh()
		-- we need this just in case the module isn't anchored in a UnitFrame XXX: Perhaps have a check or on initialise a value that says "embedded in unit frame" or not.
		elseif ( eventType == UNIT_AVAILABLE ) then
			self:Refresh() 
		elseif ( eventType == UNIT_CHANGED ) then
			self:Refresh() 				
		elseif ( eventType == SIMULATE_UPDATE ) then
			self:Simulate()
		end
	end
end

--
-- Required Function for a Module
--
-- Register Callbacks with gUF
--
function ResourceBar:RegisterCallbacks()
	--print ("ResourceBar:RegisterCallbacks() for unit ", self.unit, " registered events")
	table.insert(gUF_EventHooks, { MANA_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { POWER_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { ENERGY_UPDATE, self.unit, self })
	--table.insert(gUF_EventHooks, { REFRESH_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
	table.insert(gUF_EventHooks, { SIMULATE_UPDATE, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function ResourceBar:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["ResourceBar"] = ResourceBar