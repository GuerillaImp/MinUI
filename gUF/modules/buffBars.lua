--
-- BuffBar Module by Grantus
--
-- This buff bar module monitors for buff changes and updates a list of buffs based on user preferences 
--


local BuffBar = {}
BuffBar.__index = BuffBar

--
-- BuffBar:new()
--
-- @params
--		unit string: player, player.target, etc
--
function BuffBar.new( unit )
	local bBar = {}             		-- our new object
	setmetatable(bBar, BuffBar)    	-- make BuffBar handle lookup
	
	-- the modules unit
	bBar.unit = unit
	-- the modules enabled status
	bBar.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	bBar.settings = {
		["width"] = 0,
		["height"] = 0,
		["padding"] = 0,
		["leftText"] = 0,
		["rightText"] = 0,
		["texturePath"] = 0,
		["whitelist"] = 0,
		["blacklist"] = 0,
		["maxBuffs"] = 0,
		["growthDirection"] = 0, --up/down
		["filterMode"] = 0, -- whitelist/blacklist
		["buffMode"] = 0, -- buff/debuff/all
		["visibilityOptions"] = 0, -- player/all
		["timeThreshold"] = 0, -- max seconds of buff to show
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
	bBar.box = nil
	bBar.bars = {} -- stored as {bar,leftText,rightText}
	bBar.buffList = {}
	bBar.simulating = false
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return bBar
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
function BuffBar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.box:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function BuffBar:SetVisible ( toggle )
	self.box:SetVisible( toggle )
end

--
-- GetFrame
--
function BuffBar:GetFrame()
	return self.box:GetFrame()
end

--
-- GetHeight 
--
function BuffBar:GetHeight()
	return self.settings.height
end

--
-- Get Width
--
function BuffBar:GetWidth()
	return self.settings.width
end

--
-- BuffBar Functions
--

function BuffBar:SortBuffList ( buffListToSort )
	table.sort (
		buffListToSort,
		function (a, b)
			if (a.debuff ~= b.debuff) then
				return b.debuff
			end
			if a.duration and b.duration then return a.remaining < b.remaining end
			if not a.duration and not b.duration then return false end
			return not a.duration
		end
	)
end


--
-- Update Buffs
--
function BuffBar:Update( buffList  )
	local changesOccured = false
	if( buffList )then
		local newBuffList = {}
		local newBuffIndex = 1
		
		if not self.simulating then
			--
			-- iterate accross the new buffs and store in a temporary list
			--
			for buffID,_ in pairs(buffList) do
				-- Get the details table of the given buffID (for this unit)
				local buffDetails = Inspect.Buff.Detail(self.unit, buffID)
				-- store the buffID
				buffDetails.buffID = buffID
				-- store buff in list
				newBuffList[newBuffIndex] = buffDetails
				newBuffIndex = newBuffIndex + 1
			end
		else
			newBuffList = buffList --the simulated buff list is just a list of fake buffDetails
		end
		
		-- sort new buff list
		self:SortBuffList( newBuffList )
		self.buffList = newBuffList
		
		--
		-- reset existing
		--
		for i=1,self.settings["maxBuffs"] do
			local buffBar = self.bars[i]
			local barPanel = buffBar["barPanel"]
			barPanel:SetVisible(false)
			local barTextPanel = buffBar["barTextPanel"]
			barTextPanel:SetVisible(false)
		end
		
		--
		-- add new
		--
		local index = 1
		for _, buffDetails in pairs(newBuffList) do
			if ( index <= self.settings["maxBuffs"] ) then
				local buffBar = self.bars[index]
				local bar = buffBar["bar"]
				local leftText = buffBar["leftText"]
				local rightText = buffBar["rightText"]
				
				bar:SetBarColor(gUF_Colors["red_foreground"])
				bar:SetBGColor(gUF_Colors["red_background"])
				
				leftText:SetText(gUF_Utils:CreateBuffDetailsString(self.settings["leftText"], buffDetails))
				
				if(buffDetails.remaining and buffDetails.duration) then
					local remainingRatio = buffDetails.remaining/buffDetails.duration
					bar:SetCurrentValue(remainingRatio)
					rightText:SetText(gUF_Utils:CreateBuffDetailsString(self.settings["rightText"], buffDetails))
				end
				
				bar:SetVisible(true)
				leftText:SetVisible(true)
				rightText:SetVisible(true)
				index = index+1
			end
		end
	else
		self:SetVisible(false)
	end
end

--
-- Animate the buff's duration
--
function BuffBar:Animate()
	local index = 1
	for _, buffDetails in pairs( self.buffList ) do
		if ( index <= self.settings["maxBuffs"] ) then
			local buffBar = self.bars[index]
			local bar = buffBar["bar"]
			local rightText = buffBar["rightText"]

			if(buffDetails.remaining and buffDetails.duration) then
				local remainingRatio = buffDetails.remaining/buffDetails.duration
				bar:SetCurrentValue(remainingRatio)
				rightText:SetText(gUF_Utils:CreateBuffDetailsString(self.settings["rightText"], buffDetails))
			end
			
			index = index + 1
		end
	end
end

--
-- Required Functions for a Module
--

--
-- Get the Empty Settings Table for this Module
--
function BuffBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function BuffBar:Initialise( )
	-- buff box
	self.box = Box.new( self.settings["padding"], {r=0,g=0,b=0,a=0}, "vertical", self.settings["growthDirection"], gUF.context, 1 )
	self.box:SetVisible( false )

	for i=1,self.settings["maxBuffs"] do
		local barPanel = Panel.new( self.settings["width"], self.settings["height"], {r=0,g=0,b=0,a=0}, gUF.context, (self.box:GetLayer()+1) )
		
		local bar = Bar.new( self.settings["width"], self.settings["height"], "horizontal", "right", {r=0,g=0,b=0,a=0}, {r=0,g=0,b=0,a=0}, self.settings["texturePath"], gUF.context, (barPanel:GetLayer()+1)  )
		
		local barTextPanel = Panel.new( self.settings["width"], self.settings["height"], {r=0,g=0,b=0,a=0}, gUF.context, (bar:GetLayer()+1) )
		local leftText = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (barTextPanel:GetLayer()+2) )
		local rightText = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (barTextPanel:GetLayer()+2) )
		
		barTextPanel:AddItem( leftText, "CENTERLEFT", "CENTERLEFT", 0, 0 )
		barTextPanel:AddItem( rightText, "CENTERRIGHT", "CENTERRIGHT", 0, 0 )
		
		barPanel:AddItem( bar, "TOPLEFT", "TOPLEFT", 0, 0 )
		barPanel:AddItem( barTextPanel, "TOPLEFT", "TOPLEFT", 0, 0 )
		
		-- store bar and add to vertical box
		self.bars[i] = { ["barPanel"] = barPanel, ["barTextPanel"] = barTextPanel, ["bar"] = bar, ["leftText"] = leftText, ["rightText"] = rightText }
		self.box:AddItem( barPanel )
	end
end

--
-- On unit change, or unit available this method will be called by a frame container, if the BuffBar is actually in one
--
function BuffBar:Refresh()
	-- inspect buffs for unit
	local buffList = Inspect.Buff.List(self.unit)

	if( buffList )then
		self:Update( buffList )
	else
		self:SetVisible(false)
	end
end

--
-- Simualte a Buff Update
--
function BuffBar:Simulate()
	self.simulating = true
	self:Update( gUF_Utils:GenerateSimulatedBuffDetailsTable() )
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function BuffBar:CallBack( eventType, value )
	if ( self.enabled ) then
		if ( eventType == REFRESH_UPDATE ) then
			if not ( self.simulating ) then
				self:Refresh()
			end
		elseif ( eventType == ANIMATION_UPDATE ) then
			if not ( self.simulating ) then
				self:Animate()
			end
		elseif ( eventType == UNIT_AVAILABLE ) then
			if not ( self.simulating ) then
				self:Refresh() 
			end
		elseif ( eventType == UNIT_CHANGED ) then
			if not ( self.simulating ) then
				self:Refresh() 	
			end
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
function BuffBar:RegisterCallbacks()
	table.insert(gUF_EventHooks, { REFRESH_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { ANIMATION_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
	table.insert(gUF_EventHooks, { SIMULATE_UPDATE, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function BuffBar:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["BuffBar"] = BuffBar