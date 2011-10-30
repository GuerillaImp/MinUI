--
-- WarriorComboBar Module by Grantus
--
-- Registers for Warrior Combo Point Updates
--

local WarriorComboBar = {}
WarriorComboBar.__index = WarriorComboBar

--
-- WarriorComboBar:new()
--
-- @params
--		unit string: player, player.target, etc
--
function WarriorComboBar.new( unit )
	local wBar = {}             		-- our new object
	setmetatable(wBar, WarriorComboBar)    	-- make WarriorComboBar handle lookup
	
	-- the modules unit
	wBar.unit = unit -- Charge bar unit doesnt matter as it will always check "player"
	-- the modules enabled status
	wBar.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	wBar.settings = {
		["width"] = 0,
		["height"] = 0,
		["texturePath"] = 0,
		["padding"] = 0,
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
	wBar.panel = nil
	wBar.comboPointsBars = {}
	wBar.simulating = false
	
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return wBar
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
function WarriorComboBar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function WarriorComboBar:SetVisible ( toggle )
	self.panel:SetVisible( toggle )
end

--
-- GetFrame
--
function WarriorComboBar:GetFrame()
	return self.panel:GetFrame()
end

--
-- GetHeight 
--
function WarriorComboBar:GetHeight()
	return self.settings.height
end

--
-- Get Width
--
function WarriorComboBar:GetWidth()
	return self.settings.width
end

--
-- WarriorComboBar Functions
--

--
-- Update Charge
--
function WarriorComboBar:Update( details  )
	if ( details ) then
		if ( details.calling or self.simulating ) then -- guard against this sometime being nil
			if ( details.calling == "warrior" or self.simulating ) then
				local points = details.combo
				
				-- set bars invisible
				for i=1,3 do
					self.comboPointsBars[i]:SetVisible(false)
				end
				-- for 1->currentPoints make bars visible
				for i=1,points do
					self.comboPointsBars[i]:SetVisible(true)
				end
			else
				-- not a warrior
				self:SetVisible(false) 
			end
		-- no calling
		else
			self:SetVisible(false) 
		end
	-- no details
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
function WarriorComboBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function WarriorComboBar:Initialise( )
	self.panel = Panel.new( self.settings["width"], self.settings["height"], {r=0,g=0,b=0,a=0}, gUF.context, 1 )
	
	for i=1,3 do
		local comboPointBar = Bar.new( ((self.settings["width"]-self.settings["padding"])/3), self.settings["height"], "horizontal", "right", gUF_Colors["warriorCombo_background"], gUF_Colors["warriorCombo_foreground"], self.settings["texturePath"], gUF.context, (self.panel:GetLayer()+1)  )
		self.comboPointsBars[i] = comboPointBar
		self.panel:AddItem( self.comboPointsBars[i], "TOPLEFT", "TOPLEFT", ((i-1)*(self.settings["width"]/3)), 0 )
	end

	self.panel:SetVisible( false )
end

--
-- Charge is only given to player, so we don't need to check self.unit
--
function WarriorComboBar:Refresh()
	local details = Inspect.Unit.Detail("player")
	if(details)then
		self:Update( details )
	else
		self:SetVisible(false)
	end
	
end

--
-- Simualte a Charge Update
--
function WarriorComboBar:Simulate()
	self.simulating = true
	self:Update( gUF_Utils:GenerateSimulatedUnit() )
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function WarriorComboBar:CallBack( eventType, value ) -- not using value for now ...
	if ( self.enabled ) then
		if ( eventType == COMBO_UPDATE ) then
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
function WarriorComboBar:RegisterCallbacks()
	table.insert(gUF_EventHooks, { COMBO_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
	table.insert(gUF_EventHooks, { SIMULATE_UPDATE, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function WarriorComboBar:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["WarriorComboBar"] = WarriorComboBar