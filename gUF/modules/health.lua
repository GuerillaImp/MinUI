--
-- HealthBar Module by Grantus
--
-- Registers for Health Updates and Displays them
--

local HealthBar = {}
HealthBar.__index = HealthBar

--
-- HealthBar:new()
--
-- @params
--		unit string: player, player.target, etc
--
function HealthBar.new( unit )
	local hBar = {}             		-- our new object
	setmetatable(hBar, HealthBar)    	-- make HealthBar handle lookup
	
	-- the modules unit
	hBar.unit = unit
	-- the modules enabled status
	hBar.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	hBar.settings = {
		["width"] = 0,
		["height"] = 0,
		["colorMode"] = 0,
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
	hBar.panel = nil
	hBar.textPanel = nil
	hBar.leftText = nil
	hBar.rightText = nil
	
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return hBar
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
function HealthBar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	--print ( "HealthBar set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	
	self.panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function HealthBar:SetVisible ( toggle )
	self.panel:SetVisible( toggle )
end

--
-- GetFrame
--
function HealthBar:GetFrame()
	return self.panel:GetFrame()
end

--
-- GetHeight 
--
function HealthBar:GetHeight()
	return self.settings.height
end

--
-- Get Width
--
function HealthBar:GetWidth()
	return self.settings.width
end

--
-- HealthBar Functions
--

--
-- Update Health
--
function HealthBar:Update( details  )
	if(details)then
		local healthRatio = details.health/details.healthMax
		local healthPercent = healthRatio*100
		
		--
		-- Update the bar
		--
		self.bar:SetCurrentValue(healthRatio)

		--
		-- Colorise the bar based on current mode
		--	
		local calling = details.calling
		local reaction = details.relation
		
		--print ( calling, reaction )
		
		if(self.settings["colorMode"] == "health") then
			local colors = gUF_Utils:GetHealthPercentColor(healthPercent)
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		elseif (self.settings["colorMode"] == "calling") then
			local colors = gUF_Utils:GetCallingColor(calling)
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		elseif(self.settings["colorMode"] == "relation") then
			local colors = gUF_Utils:GetRelationColor(reaction)
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		else
			self.bar:SetBarColor(gUF_Colors["grey_foreground"])
			self.bar:SetBGColor(gUF_Colors["grey_background"])
		end
		
		--
		-- now update the left and right text values
		--
		self.leftText:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["leftText"], details ))
		self.rightText:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["rightText"], details ))
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
function HealthBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function HealthBar:Initialise( )
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
-- On unit change, or unit available this method will be called by a frame container, if the health bar is actually in one
-- Or in a "timed" update this should also be called (if I choose to go the timer route rather than event based route)
--
function HealthBar:Refresh()
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		self:Update( details )
	else
		self:SetVisible(false)
	end
end

--
-- Simualte a Health Update
--
function HealthBar:Simulate()
	self:Update( gUF_Utils:GenerateSimulatedUnit() )
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function HealthBar:CallBack( eventType, value )
	if ( self.enabled ) then
		if ( eventType == HEALTH_UPDATE ) then
			self:Refresh() -- funnily enough im not even using the value given (maybe dont bother sending it?)
		-- we need this just in case the module isn't anchored in a UnitFrame XXX: Perhaps have a check or on initialise a value that says "embedded in unit frame" or not.
		elseif ( eventType == UNIT_AVAILABLE ) then
			self:Refresh() 
		elseif ( eventType == UNIT_CHANGED ) then
			self:Refresh() 	
		elseif ( eventType == SIMULATE_UPDATE ) then
			self:Simulate()
		end
		--[[if ( eventType == REFRESH_UPDATE ) then
			self:Refresh()
		end]]
	end
end

--
-- Required Function for a Module
--
-- Register Callbacks with gUF
--
function HealthBar:RegisterCallbacks()
	--print ("HealthBar:RegisterCallbacks() for unit ", self.unit, " registered events")
	table.insert(gUF_EventHooks, { HEALTH_UPDATE, self.unit, self })
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
function HealthBar:SetEnabled( toggle )
	self.enabled = toggle
	--print ("health bar setenabled -> ", toggle, self.unit)
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["HealthBar"] = HealthBar