--
-- Simple Text Module by Grantus
--
-- For Displaying Unit Name or Health or Vitality or Level or Guild... or whatever :P
-- 


local TextItem = {}
TextItem.__index = TextItem

--
-- TextItem:new()
--
-- @params
--		unit string: player, player.target, etc
--
function TextItem.new( unit )
	local tItem = {}             		-- our new object
	setmetatable(tItem, TextItem)    	-- make TextItem handle lookup
	
	-- the modules unit
	tItem.unit = unit
	-- the modules enabled status
	tItem.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	-- XXX: is it worth having defaults?
	--
	tItem.settings = {
		["text"] = 0,
		["colorMode"] = 0,
		["color"] = 0,
		["font"] = 0,
		["fontSize"] = 0,
		["anchor"] = 0,
		["anchorUnit"] = 0,
		["anchorPointThis"] = 0,
		["anchorPointParent"] =  0,
		["anchorXOffset"] = 0,
		["anchorYOffset"] = 0
	}

	
	--
	-- main items of the bar
	--
	tItem.text = nil
	tItem.panel = nil
	
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return tItem
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
function TextItem:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	--print ( "TextItem set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function TextItem:SetVisible ( toggle )
	--print ( "TextItem set visible ", toggle )
	self.panel:SetVisible( toggle )
end

--
-- GetFrame
--
function TextItem:GetFrame()
	return self.panel:GetFrame()
end

--
-- GetHeight 
--
function TextItem:GetHeight()
	--print ("text module height ->",self.text:GetHeight())
	return self.panel:GetHeight()
end

--
-- Get Width
--
function TextItem:GetWidth()
	--print ("text module width ->",self.text:GetWidth())
	return self.panel:GetWidth()
end

--
-- TextItem Functions
--

--
-- Update Health
--
function TextItem:Update( details  )
	--print ( "text item update" )
	if(details)then
		--print ( "text -> ",gUF_Utils:CreateUnitDetailsString( self.settings["text"], details ))
		self.text:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["text"], details ))
		self.panel:SetWidth(self.text:GetWidth())
		self.panel:SetHeight(self.text:GetHeight())
		
		-- set text color based on colorMode
		if ( self.settings["colorMode"] == "none" ) then
			self.text:SetColor(self.settings["color"])
		elseif( self.settings["colorMode"] == "relation" ) then
			self.text:SetColor(gUF_Utils:GetRelationColor(details.relation).foregroundColor)
		elseif( self.settings["colorMode"] == "difficulty" ) then
			self.text:SetColor(gUF_Utils:GetDifficultyColor(self.unit))
		elseif( self.settings["colorMode"] == "calling" ) then
			if(details.calling)then
				self.text:SetColor(gUF_Utils:GetCallingColor(details.calling).foregroundColor)
			else
				self.text:SetColor(self.settings["color"])
			end
		end
		
		
		self:SetVisible(true)
	else
		--print ( "no details :(" )
		self:SetVisible(false)
	end
end


--
-- Required Functions for a Module
--

--
-- Get the Empty Settings Table for this Module
--
function TextItem:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function TextItem:Initialise( )
	self.panel = Panel.new(  100, 100, {r=0,g=0,b=0,a=0}, gUF.context, 5 )
	self.text = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, self.panel:GetLayer()+1 )
	self.panel:AddItem(self.text, "TOPLEFT", "TOPLEFT", 0, 0)
end

--
-- On unit change, or unit available this method will be called by a frame container
-- Or in a "timed" update this should also be called (if I choose to go the timer route rather than event based route)
--
function TextItem:Refresh()
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		self:Update( details )
	else
		self:SetVisible(false)
	end
end

--
-- Simualte a Text Update
--
function TextItem:Simulate()
	self:Update( gUF_Utils:GenerateSimulatedUnit() )
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function TextItem:CallBack( eventType, value )
	if ( self.enabled ) then
		if ( eventType == LEVEL_UPDATE ) then
			self:Refresh() 
		elseif ( eventType == GUILD_UPDATE ) then
			self:Refresh() 
		elseif ( eventType == MARK_UPDATE ) then
			self:Refresh() 
		elseif ( eventType == OFFLINE_UPDATE ) then
			self:Refresh() 
		elseif ( eventType == PVP_UPDATE ) then
			self:Refresh() 
		elseif ( eventType == WARFRONT_UPDATE ) then
			self:Refresh() 
		elseif ( eventType == AFK_UPDATE ) then
			self:Refresh() 
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
function TextItem:RegisterCallbacks()
	table.insert(gUF_EventHooks, { LEVEL_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { GUILD_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { MARK_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { OFFLINE_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { PVP_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { WARFRONT_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { AFK_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
	table.insert(gUF_EventHooks, { SIMULATE_UPDATE, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function TextItem:SetEnabled( toggle )
	self.enabled = toggle
	----print ("health bar setenabled -> ", toggle, self.unit)
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["TextItem"] = TextItem