--
-- HealthBar Module by Grantus
--
-- Registers for Health Updates and Displays it
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
		["fontSize"] = 0
	}

	
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
	print ( "HealthBar set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	
	print("box = ", self.box)
	
	self.box:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function HealthBar:SetVisible ( toggle )
	self.box:SetVisible( toggle )
end

--
-- GetFrame
--
function HealthBar:GetFrame()
	return self.box:GetFrame()
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
function HealthBar:UpdateHealth( healthValue )
	print ( "HealthBar: new health value", healthValue )
	
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local healthRatio = healthValue/details.healthMax
		local healthPercent = healthRatio*100
		
		self.bar:SetCurrentValue(healthRatio)
		
		local calling = details.calling
		local reaction = details.reaction
		
		-- colorise the bar based on current mode
		if(self.settings["colorMode"] == "health") then
			local colors = gUF_Utils:GetHealthPercentColor(healthPercent)
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		elseif (self.settings["colorMode"] == "calling") then
			local colors = gUF_Utils:GetCallingColor(calling)
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		elseif(self.settings["colorMode"] == "reaction") then
			local colors = gUF_Utils:GetReactionColor(reaction)
			self.bar:SetBarColor(colors.foregroundColor)
			self.bar:SetBGColor(colors.backgroundColor)
		else
			local color = gUF.colors["black"]
			self.bar:SetBarColor(color)
			self.bar:SetBGColor(color)
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
function HealthBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function HealthBar:Initialise( )
	self.box = Box.new(  0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, -1 )
	self.bar = Bar.new( self.settings["width"], self.settings["height"], "horizontal", "right", {r=0,g=0,b=0,a=0}, {r=0,g=0,b=0,a=0}, self.settings["texturePath"], gUF.context, (self.box:GetLayer()+1)  )
	
	self.box:AddItem( self.bar )
	self.box:SetVisible( false )
end

--
-- On unit change, or unit available this method will be called 
-- Or in a "timed" update this can be called with an event firing (if I choose to go the timer route rather than event based route)
--
function HealthBar:Refresh()
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		self:UpdateHealth( details.health )
	else
		self:SetVisible(false)
	end
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
-- Here the health value is sent to the healthBar module
--
function HealthBar:CallBack( eventType, value )
	if ( self.enabled ) then
		if ( eventType == HEALTH_UPDATE ) then
			print("HealthBar health updated!", self.unit)
			self:UpdateHealth ( value ) 
		elseif ( eventType == UNIT_AVAILABLE ) then
			print("HealthBar unit available!", self.unit)
			self:Refresh ( ) 
		elseif ( eventType == UNIT_CHANGED ) then
			print("HealthBar unit changed!", self.unit)
			self:Refresh ( ) 
		end
	end
end

--
-- Required Function for a Module
--
-- Register Callbacks with gUF
--
function HealthBar:RegisterCallbacks()
	print ("HealthBar:RegisterCallbacks() for unit ", self.unit, " registered events")
	table.insert(gUF_EventHooks, { HEALTH_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function HealthBar:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["HealthBar"] = HealthBar