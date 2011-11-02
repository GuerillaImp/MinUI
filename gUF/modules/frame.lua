--
-- UnitFrame Module by Grantus
--
-- This "UnitFrame" acts as a container that will check unit details on unit change and hide itself and it's contents if
-- the details are not available or non existant (i.e. changing to a non-target)
--
-- It will call "SetEnabled(false)" on all of its items when it is not visible, and SetEnabled(true) when it is.
--
-- The UnitFrame can obviously be used to make a unit frame :D, but also castbars,buff icons, anything that need to not show
-- when the target is no longer available.
--

local UnitFrame = {}
UnitFrame.__index = UnitFrame

--
-- UnitFrame:new()
--
-- @params
--		unit string: player, player.target, etc
--
function UnitFrame.new( unit, addOn )
	local uFrame = {}             		-- our new object
	setmetatable(uFrame, UnitFrame)    	-- make UnitFrame handle lookup
	
	-- the modules unit
	uFrame.unit = unit
	uFrame.addOn = addOn
	uFrame.locked = true
	
	-- the modules enabled status
	uFrame.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	uFrame.settings = {
		["padding"] = 0,
		["bgColor"] = 0,
		["anchor"] = 0,
		["anchorUnit"] = 0,
		["anchorPointThis"] = 0,
		["anchorPointParent"] = 0,
		["anchorXOffset"] = 0,
		["anchorYOffset"] = 0
	}

	-- box that will fill with items that are added to it
	uFrame.box = nil
	uFrame.modules = {}
	uFrame.draggable = nil
	uFrame.draggableText = nil
	
	
	uFrame.simulating = false
	
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return uFrame
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
function UnitFrame:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.box:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
	self.draggable:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function UnitFrame:SetVisible ( toggle )
	self.box:SetVisible( toggle )
end

--
-- GetFrame
--
function UnitFrame:GetFrame()
	return self.box:GetFrame()
end

--
-- GetHeight 
--
function UnitFrame:GetHeight()
	return self.box:GetHeight()
end

--
-- Get Width
--
function UnitFrame:GetWidth()
	return self.box:GetWidth()
end


--
-- Unit Frame Functions
--

--
-- Add a gUF Module to this UnitFrame
--
function UnitFrame:AddModule( moduleToAdd )
	self.box:AddItem( moduleToAdd )
	table.insert(self.modules, moduleToAdd)
	
	self.draggable:SetWidth(self.box:GetWidth())
	self.draggable:SetHeight(self.box:GetHeight())
end

--
-- Lock/Unlock the Draggable Frame
--
function UnitFrame:ToggleLocked ( )
	if ( self.locked ) then
		self.locked = false
		self.draggable:SetVisible(true)
	else
		self.locked = true
		self.draggable:SetVisible(false)
	end
end

--
-- The frame doesn't simualte anything (as it is just a smart container)
--
function UnitFrame:Simulate ( )
	self.simulating = true
end

--
-- Enable/Disable Modules within this UnitFrame
--
function UnitFrame:EnableModules ( toggle )
	for _,module in pairs (self.modules) do
		module:SetEnabled( toggle )
		-- if enabled, refresh the module
		if( toggle )then
			module:Refresh()
		end
	end
end

--
-- Required Functions for a Module
--

--
-- Get the Empty Settings Table for this Module
--
function UnitFrame:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function UnitFrame:Initialise( )
	--if( self.settings["padding"] == 0 )then
	--	self.settings["padding"] = 1
	--end
	
	self.box = Box.new(  self.settings["padding"], self.settings["bgColor"], "vertical", "down", gUF.context, -1 )
	self.draggable = Panel.new (  self.settings["padding"], self.settings["padding"], gUF_Colors["red_foreground"], gUF.context, 10 )
	self.draggableText = Text.new ( gUF_Fonts["arial_round"], 16, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (self.draggable:GetLayer()+1) )
	self.draggableText:SetText ( "["..self.unit.."]".. " ".. self.addOn )
	self.draggable:AddItem( self.draggableText,  "CENTER", "CENTER", 0, 0 )	
end

--
-- On unit change, or unit available this method will be called 
-- Or in a "timed" update this can be called with an event firing (if I choose to go the timer route rather than event based route)
--
function UnitFrame:Refresh()
	local details = Inspect.Unit.Detail(self.unit)
	
	if ( details ) then
		self:SetVisible( true )
		self:EnableModules( true )
	else
		self:SetVisible( false )
		self:EnableModules( false )
	end
end

--
-- The unitName this unit is registered to has changed ID
--
-- @params
--		unitID table: a unitID number or false if the unit no longer exists, or there is no target for the self.unit value
--
function UnitFrame:UnitChanged( )
	self:Refresh()
end

--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
-- Here the health value is sent to the healthBar module
--
function UnitFrame:CallBack( eventType, value )
	if ( self.enabled ) then
		if ( eventType == UNIT_AVAILABLE ) then
			if not self.simulating then
				self:Refresh()
			end
		elseif ( eventType == UNIT_CHANGED ) then
			if not self.simulating then
				self:UnitChanged() 	
			end
		elseif ( eventType == SIMULATE_UPDATE ) then
			self:Simulate( )
		elseif ( eventType == TOGGLE_FRAME_LOCK ) then
			if not self.simulating then
				self:ToggleLocked()
			end
		end
	end
end

--
-- Required Function for a Module
--
-- Register Callbacks with gUF
--
function UnitFrame:RegisterCallbacks()
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
	table.insert(gUF_EventHooks, { SIMULATE_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { TOGGLE_FRAME_LOCK, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function UnitFrame:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["UnitFrame"] = UnitFrame
