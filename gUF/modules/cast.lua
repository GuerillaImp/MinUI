--
-- CastBar Module by Grantus
--


local CastBar = {}
CastBar.__index = CastBar

--
-- CastBar:new()
--
-- @params
--		unit string: player, player.target, etc
--
function CastBar.new( unit )
	local cBar = {}             		-- our new object
	setmetatable(cBar, CastBar)    	-- make CastBar handle lookup
	
	-- the modules unit
	cBar.unit = unit
	-- the modules enabled status
	cBar.enabled = true
	
	--
	-- Every module must have a settings table, such that it can be configured by AddOns
	--
	cBar.settings = {
		["width"] = 0,
		["height"] = 0,
		["padding"] = 0,
		["frameBGColor"] = 0,
		["barColor"] = 0, -- bar color
		["barBGColor"] = 0, -- bar bg color
		["icon"] = 0, -- left, right, none
		["iconPadding"] = 0,
		["iconSize"] = 0,
		["leftText"] = 0, -- as per gUF_Utils create ability details string paramaters
		["rightText"] = 0,
		--["leftTextTruncate"] -- TODO: options for this
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
	cBar.box = nil
	cBar.bar = nil
	cBar.textPanel = nil
	cBar.leftText = nil
	cBar.rightText = nil
	cBar.iconBox = nil
	cBar.icon = nil
	
	--
	-- current spell things
	--
	cBar.castBar = nil
	cBar.abilityDetails = nil
	cBar.uninteruptable = nil
	cBar.channeled = nil
	cBar.abilityName = nil
	
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
function CastBar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- SetVisibility
--
function CastBar:SetVisible ( toggle )
	self.panel:SetVisible( toggle )
end

--
-- GetFrame
--
function CastBar:GetFrame()
	return self.panel:GetFrame()
end

--
-- GetHeight 
--
function CastBar:GetHeight()
	return (self.settings.height)
end

--
-- Get Width
--
function CastBar:GetWidth()
	return (self.settings.width)
end

--
-- CastBar Functions
--

--
-- Update Health
--
function CastBar:Update( castBar  )
	if ( castBar ) then
		self.castBar = castBar
		self.casting = true
		self.uninterruptible = castBar.uninterruptible
		self.channeled = castBar.channeled
		
		local ability = castBar.ability
		
		if ( ability ) then
			local abilityDetails = Inspect.Ability.Detail( ability )
			-- set icon if we have one
			if ( abilityDetails ) then
				if ( abilityDetails.icon ) then
					self.icon:SetTexture("Rift", abilityDetails.icon) -- use the inbuilt texture setting for this so we can specify a rift core icon
				else
					self.icon:SetTexture("Rift", "banana.dds")
				end
			else
				self.icon:SetTexture("Rift", "banana.dds")
			end
		else
			self.icon:SetTexture("Rift", "banana.dds")
		end
		
		-- make grey if uninterruptible
		if ( self.uninterruptible  ) then
			self.bar:SetBarColor(gUF_Colors["grey_foreground"])
			self.bar:SetBGColor(gUF_Colors["grey_background"])
		else
			self.bar:SetBarColor(self.settings["barColor"])
			self.bar:SetBGColor(self.settings["barBGColor"])
		end
		
		--
		-- Do a visual update (as per animation) (in case we get a castbar half way through a cast)
		--
		local remaining = self.castBar.remaining
		local duration = self.castBar.duration
		
		if( remaining and duration )then
			self.leftText:SetText(gUF_Utils:CreateCastingDetailsString( self.settings["leftText"], self.castBar, self.abilityDetails ))
			self.rightText:SetText(gUF_Utils:CreateCastingDetailsString( self.settings["rightText"], self.castBar, self.abilityDetails ))
			
			-- FILL 
			if not self.channeled then
				local widthMultiplier = (1 - (remaining / duration))
				self.bar:SetCurrentValue(widthMultiplier)
			else
				local widthMultiplier = ((remaining / duration))
				self.bar:SetCurrentValue(widthMultiplier)
			end
		end
		
		self:SetVisible(true)
		self.casting = true
	else
		--print ( self.unit, " not casting.")
		self:SetVisible(false)
		self.casting = false
	end
end

--
-- Animate the castbar
--
function CastBar:Animate()
	if( self.casting )then
		self.castBar = Inspect.Unit.Castbar( self.unit )
		if ( self.castBar ) then
			local remaining = self.castBar.remaining
			local duration = self.castBar.duration
			
			if( remaining and duration )then
				--print ("remaining and duration exist!", remaining, duration)
				
				self.leftText:SetText(gUF_Utils:CreateCastingDetailsString( self.settings["leftText"], self.castBar, self.abilityDetails ))
				self.rightText:SetText(gUF_Utils:CreateCastingDetailsString( self.settings["rightText"], self.castBar, self.abilityDetails ))
				
				-- FILL 
				if not self.channeled then
					local widthMultiplier = (1 - (remaining / duration))
					--print("widthMultiplier -> ", widthMultiplier)
					self.bar:SetCurrentValue(widthMultiplier)
				else
					local widthMultiplier = ((remaining / duration))
					--print("widthMultiplier -> ", widthMultiplier)
					self.bar:SetCurrentValue(widthMultiplier)
				end
			end
		else
			self.casting = false
		end
	end
end


--
-- Required Functions for a Module
--

--
-- Get the Empty Settings Table for this Module
--
function CastBar:GetSettingsTable()
	return self.settings
end

--
-- Initialise the Module
--
function CastBar:Initialise( )
	-- create a panel to hold everything
	self.panel = Panel.new(  self.settings["width"] + (self.settings["padding"]*2), self.settings["height"]+ (self.settings["padding"]*2), self.settings["frameBGColor"], gUF.context, -1 )
	
	-- create the actual cast bar
	self.bar = Bar.new( self.settings["width"], self.settings["height"], "horizontal", "right", {r=0,g=0,b=0,a=0}, {r=0,g=0,b=0,a=0}, self.settings["texturePath"], gUF.context, (self.panel:GetLayer()+1)  )
	
	-- add the cast bar
	self.panel:AddItem( self.bar, "TOPLEFT", "TOPLEFT", self.settings["padding"], self.settings["padding"] )

	-- create text items
	self.textPanel = Panel.new( self.settings["width"], self.settings["height"], {r=0,g=0,b=0,a=0}, gUF.context, (self.bar:GetLayer()+1) )
	-- TODO: Truncate Options for Text
	self.leftText = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "truncate", 33, "shadow", gUF.context, (self.textPanel:GetLayer()+2) )
	self.rightText = Text.new ( self.settings["font"], self.settings["fontSize"], {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (self.textPanel:GetLayer()+2) )
	self.textPanel:AddItem( self.leftText,  "CENTERLEFT", "CENTERLEFT", 0, 0 )
	self.textPanel:AddItem( self.rightText,  "CENTERRIGHT", "CENTERRIGHT", 0, 0 )
	
	-- add text panel inside the castbar panel
	self.panel:AddItem( self.textPanel, "TOPLEFT", "TOPLEFT", self.settings["padding"], self.settings["padding"] )
	
	-- create icon
	self.iconBox = Box.new ( self.settings["iconPadding"], self.settings["frameBGColor"], "horizontal", "right", gUF.context, (self.bar:GetLayer()+1)) 
	self.icon = Panel.new (  self.settings["iconSize"], self.settings["iconSize"], {r=0,g=0,b=0,a=0}, gUF.context, (self.iconBox:GetLayer()+1)) -- todo icon size
	self.iconBox:AddItem(self.icon)
	
	-- attach icon if required
	if ( self.settings["icon"] == "left" ) then
		self.panel:AddItem( self.iconBox, "CENTERRIGHT", "CENTERLEFT", 0, 0 )
	elseif ( self.settings["icon"] == "right" ) then
		self.panel:AddItem( self.iconBox, "CENTERLEFT", "CENTERRIGHT", 0, 0 )
	end
	
	self.panel:SetVisible( false )
end

--
-- On unit change, or unit available this method will be called by a frame container, if the health bar is actually in one
-- Or in a "timed" update this should also be called (if I choose to go the timer route rather than event based route)
--
function CastBar:Refresh()
	local unitID = Inspect.Unit.Lookup(self.unit)

	if ( unitID ) then
		local castBar = Inspect.Unit.Castbar( unitID )
		self:Update( castBar )
	else
		self:SetVisible(false)
	end
end

--
-- Simualte a Health Update
--
function CastBar:Simulate()
	self.simulating = true
	self:Update( gUF_Utils:GenerateSimulatedCastbar() )
end


--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function CastBar:CallBack( eventType, value )
	if ( self.enabled ) then
		if ( eventType == CASTBAR_UPDATE ) then
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
function CastBar:RegisterCallbacks()
	table.insert(gUF_EventHooks, { CASTBAR_UPDATE, self.unit, self })
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
function CastBar:SetEnabled( toggle )
	self.enabled = toggle
end

--
-- *** Register this Module with gUF ***
--
gUF_Modules["CastBar"] = CastBar