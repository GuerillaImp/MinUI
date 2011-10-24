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
function HealthBar.new( unit, width, height )
	local hBar = {}             		-- our new object
	setmetatable(hBar, HealthBar)    	-- make HealthBar handle lookup
	
	print ("health bar new")
	
	--
	-- Store vars
	--
	hBar.unit = unit
	hBar.enabled = true
	
	--
	-- Create HealthBar Module Widgets
	--
	hBar.bgColor = {r=0,g=0,b=0,a=0}
	hBar.hb_bgColor = {r=1,g=0,b=0,a=0.3}
	hBar.hb_barColor = {r=1,g=0,b=0,a=0.6}
	hBar.box = Box.new(  0, hBar.bgColor, "horizontal", "left", gUF.context, -1 )
	hBar.bar = Bar.new( width, height, "horizontal", "right", hBar.hb_bgColor, hBar.hb_barColor, "media/bars/otravi.tga", gUF.context, (hBar.box:GetLayer()+1)  )
	
	hBar.box:AddItem( hBar.bar )
	hBar.box:SetVisible( false )


	return hBar
end

--
-- Get health colors for when the bar is in "health" deficit mode
--
-- @params
--		percentLife numbeR: the percentage of the unit's health that is left
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function HealthBar:GetHealthBarColor ( percentLife )
	local colors = {}
	
	if (percentLife >= 66) then
		colors.backgroundColor = { r=0.0, g=0.7, b=0.0, a=0.3 }
		colors.foregroundColor = { r=0.0, g=0.7, b=0.0, a=0.6 }
	elseif(percentLife >= 33 and percentage <= 66) then
		colors.backgroundColor = { r=0.7, g=0.7, b=0.0, a=0.3 }
		colors.foregroundColor = { r=0.7, g=0.7, b=0.0, a=0.6 }
	elseif(percentLife >= 1 and percentage <= 33) then
		colors.backgroundColor = { r=0.7, g=0.0, b=0.0, a=0.3 }
		colors.foregroundColor = { r=0.7, g=0.0, b=0.0, a=0.6 }
	else
		colors.backgroundColor = { r=0.0, g=0.0, b=0.0, a=0.3 }
	end
	
	return colors
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
		self.bar:SetCurrentValue(healthRatio)
	else
		self:SetVisible(false)
	end
end


--
-- Required Functions for a Module
--

--
-- On unit change, or unit available this method will be called 
-- Or in a "timed" update this can be called with an event firing (if I choose to go the timer route rather than event based route)
--
function HealthBar:Refresh()
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local healthRatio = details.health/details.healthMax
		self.bar:SetCurrentValue(healthRatio)
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