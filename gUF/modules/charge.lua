--
-- ChargeBar Module by Grantus
--
-- Registers for Mage Charge Updates
--

local ChargeBar = {}
ChargeBar.__index = ChargeBar

--
-- ChargeBar:new()
--
-- @params
--		unit string: player, player.target, etc
--
function ChargeBar.new( unit )
	local cBar = {}             		-- our new object
	setmetatable(cBar, ChargeBar)    	-- make ChargeBar handle lookup
	
	-- the modules unit
	cBar.unit = unit -- Charge bar unit doesnt matter as it will always check "player"
	-- the modules enabled status
	cBar.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	cBar.settings = {
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
	cBar.panel = nil
	cBar.textPanel = nil
	cBar.leftText = nil
	cBar.rightText = nil
	
	cBar.simulating = false
	
	--
	-- Note: nothing is actually created here, that occurs in the Initialise function, which
	-- should be called after the settings above have been filled out by an AddOn
	--

	return cBar
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
function ChargeBar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function ChargeBar:SetVisible ( toggle )
	self.panel:SetVisible( toggle )
end

--
-- GetFrame
--
function ChargeBar:GetFrame()
	return self.panel:GetFrame()
end

--
-- GetHeight 
--
function ChargeBar:GetHeight()
	return self.settings.height
end

--
-- Get Width
--
function ChargeBar:GetWidth()
	return self.settings.width
end

--
-- ChargeBar Functions
--

--
-- Update Charge
--
function ChargeBar:Update( details  )
	if ( details ) then
		if ( details.calling ) then
			if ( details.calling == "mage" or self.simulating ) then
				local resource = 0
				local resourceMax = 0
				

				if ( details.charge ) then
					resource = details.charge		
					resourceMax = 100
				end
				
				
				local resourcesRatio = resource/resourceMax
				
				--
				-- Update the bar
				--
				self.bar:SetCurrentValue(resourcesRatio)

			
				--
				-- now update the left and right text values - this will double check the calling, but it's clean code
				--
				self.leftText:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["leftText"], details ))
				self.rightText:SetText(gUF_Utils:CreateUnitDetailsString( self.settings["rightText"], details ))
			
				self:SetVisible(true)
			else
				-- not a mage
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
function ChargeBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function ChargeBar:Initialise( )
	self.panel = Panel.new( self.settings["width"], self.settings["height"], {r=0,g=0,b=0,a=0}, gUF.context, 1 )
	self.bar = Bar.new( self.settings["width"], self.settings["height"], "horizontal", "right",gUF_Colors["mageCharge_background"], gUF_Colors["mageCharge_foreground"], self.settings["texturePath"], gUF.context, (self.panel:GetLayer()+1)  )
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
-- Charge is only given to player, so we don't need to check self.unit
--
function ChargeBar:Refresh()
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
function ChargeBar:Simulate()
	self.simulating = true
	self:Update( gUF_Utils:GenerateSimulatedUnit() )
end

--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function ChargeBar:CallBack( eventType, value ) -- not using value for now ...
	if ( self.enabled ) then
		if ( eventType == CHARGE_UPDATE ) then
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
function ChargeBar:RegisterCallbacks()
	table.insert(gUF_EventHooks, { CHARGE_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_CHANGED, self.unit, self })
	table.insert(gUF_EventHooks, { SIMULATE_UPDATE, self.unit, self })
end

--
-- Required Function for a Module
--
-- Starts/Stops this module from reacting to events
--
function ChargeBar:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["ChargeBar"] = ChargeBar