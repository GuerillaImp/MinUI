--
-- gUF_Units_Settings by Grantus
--
-- This AddOn creates and manages the standard unit frames for gUF (player, target, focus, etc)
--
--


local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--
-- Unit Settings Var
--
gUF_Units_Settings = nil

-- defaults
gUF_Units_Defaults = {
	unitsEnabled = {["player"] = true, ["player.pet"] = false, ["player.target"] = false,["player.target.target"] = false,["focus"] = false},
	unitSettings = {
		["player"] = {
			x = 500,
			y = 500,
			barWidth = 200,
			barHeight = 30,
			barTexture = "otravi",
			modulesEnabled =  {
				[1] = "HealthBar", [2] = "HealthBar"
			},
			moduleSettings = {} 
		},
		["player.pet"] = {
			x = 200,
			y = 500,
			barWidth = 200,
			barHeight = 30,
			barTexture = "otravi",
			modulesEnabled =  {
				[1] = "HealthBar", [2] = "HealthBar"
			},
			moduleSettings = {} 
		},
		["player.target"] = {
			x = 1000,
			y = 500,
			barWidth = 200,
			barHeight = 30,
			barTexture = "otravi",
			modulesEnabled =  {
				[1] = "HealthBar", [2] = "HealthBar"
			},
			moduleSettings = {} 
		},
		["player.target.target"] = {
			x = 1300,
			y = 500,
			barWidth = 200,
			barHeight = 30,
			barTexture = "otravi",
			modulesEnabled =  {
				[1] = "HealthBar", [2] = "HealthBar"
			},
			moduleSettings = {} 
		},
		["focus"] = {
			x = 1600,
			y = 500,
			barWidth = 200,
			barHeight = 30,
			barTexture = "otravi",
			modulesEnabled =  {
				[1] = "HealthBar", [2] = "HealthBar"
			},
			moduleSettings = {} 
		}
	}
}



--
-- Units Namespace
--

Units = {}
Units.initialisedUnits = {}

--
--
--
function Units:CheckSettings()
	if ( gUF_Units_Settings ) then
		print "units settings exists"
		-- check that the settings are valid
	else
		print "units settings does not exist, setting to default"
		gUF_Units_Settings = gUF_Units_Defaults
	end
end

--
--
--
function Units:Initialise()
	Units:CheckSettings()
	
	-- for each enabled unit
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
			print ( "creating enabled unit ", unit)
			local unitSettings = gUF_Units_Settings.unitSettings[unit]
			local unitFrame = Box.new( 5, {r=0,g=0,b=0,a=0.3}, "vertical", "down", gUF.context, -1 )
			
			-- for each enabled module on the unit
			for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modulesEnabled) do
				--print ( "creating enabled module ", index, "=>", module, " in unit ", unit)
				local moduleClass = gUF_Modules[module]
				if(moduleClass)then
					--print "module exists, creating"
					local moduleInstance = moduleClass.new( unit )
					moduleInstance:RegisterCallbacks()
					unitFrame:AddItem(moduleInstance)
					--
					-- TODO: Module Settings
					--
				else
					print "module does not exist"
				end
			end
			
			
			-- store the fact that this unit has been initialised (such that if we change enabled units settings later, we know not to recreate this frame)
			unitFrame.initialised = true
			Units.initialisedUnits[unit] = unitFrame
			unitFrame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", unitSettings.x, unitSettings.y )
			unitFrame:SetVisible(true)
		end
	end
end

--
--
--
function Units:ReInitialise()
	Units:CheckSettings()
	
	-- for each enabled unit
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
			local unitSettings = gUF_Units_Settings.unitSettings[unit]
			
			if not (Units.initialisedUnits[unit]) then
				-- if we haven't already create this frame this session, or we have disabled it in this session
				print ( "creating new enabled unit ", unit)
				local unitFrame = Box.new( 5, {r=0,g=0,b=0,a=0.3}, "vertical", "down", gUF.context, -1 )
				
				-- for each enabled module on the unit
				for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modulesEnabled) do
					print ( "creating enabled module ", index, "=>", module, " in unit ", unit)
					local moduleClass = gUF_Modules[module]
					if(moduleClass)then
						print "module exists, creating"
						local moduleInstance = moduleClass.new( unit )
						moduleInstance:RegisterCallbacks()
						unitFrame:AddItem(moduleInstance)
						--
						-- TODO: Module Settings
						--
					else
						print "module does not exist"
					end
				end
				
				
				-- store the fact that this unit has been initialised (such that if we change enabled units settings later, we know not to recreate this frame)
				unitFrame.initialised = true
				Units.initialisedUnits[unit] = unitFrame
				unitFrame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", unitSettings.x, unitSettings.y )
				unitFrame:SetVisible(true)
			elseif (Units.initialisedUnits[unit] and Units.initialisedUnits[unit].initialised == false) then
				print ("previously disabled, but will now reenable ",unit)
				Units.initialisedUnits[unit].initialised = true
				Units.initialisedUnits[unit]:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", unitSettings.x, unitSettings.y )
				Units.initialisedUnits[unit]:SetVisible(true)
			end
		else
			-- was this frame previously enabled?
			if(Units.initialisedUnits[unit])then
				print ("previously enabled, but will now disable ",unit)
				Units.initialisedUnits[unit]:SetVisible(false)
				Units.initialisedUnits[unit].initialised = false
				
				--
				-- TODO: Go through modules and stop them listening for callbacks
				--
				
			end
		end
	end
end

--
-- Get Options
--
--
function Units:GetOptions()
	Units:CheckSettings()
	
	local optionsPane = Box.new( 0, {r=0,g=0,b=0,a=0}, "vertical", "down", gUF.context, 7 )
	local spacer = Box.new( 10, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, 7 )
	local optionsHeading = Text.new ( "media/fonts/arial_round.ttf", 14, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 8 )
	optionsHeading:SetText("Unit Frames Configuration:")
	
	-- create checkboxes for enabled/disabled units
	local enabledHeading = Text.new ( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 8 )
	enabledHeading:SetText("Units Enabled:")
	
	local hBoxEnabled = Box.new( 0, {r=0,g=0,b=0,a=0.5}, "horizontal", "right", gUF.context, 7 )
	hBoxEnabled:AddItem(enabledHeading)

	-- for each possible unit - check if enabled and tick if it is, else untick, set callbacks to enabled/disable
	for _,unitName in pairs (allUnits) do
		print ("unit name", unitName)
		local unitHBox =  Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 8 )
		local unitHeading = Text.new ( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 9 )
		unitHeading:SetText(unitName..": ")
		local unitEnabledCheckbox = UI.CreateFrame("RiftCheckbox", "gUF_Options", gUF.context)
		unitEnabledCheckbox:SetLayer(9)
		unitEnabledCheckbox:SetVisible(false)
		
		if(gUF_Units_Settings.unitsEnabled[unitName])	then
			print ("unit enabled ", unitName)
			unitEnabledCheckbox.checked = true
			unitEnabledCheckbox:SetChecked(true)
		else
			print ("unit disabled ", unitName)
			unitEnabledCheckbox.checked = false
			unitEnabledCheckbox:SetChecked(false)
		end
		
		--
		-- Update Unit Enabled Status and ReInitialise Frames
		--
		function unitEnabledCheckbox.Event:CheckboxChange()
			-- the box was previously checked, so uncheck it
			if ( self.checked ) then
				self.checked = false
				gUF_Units_Settings.unitsEnabled[unitName] = false
			-- the box was not previously checked, so check it
			else
				self.checked = true
				gUF_Units_Settings.unitsEnabled[unitName] = true
			end
			
			print ( "unit enabled ", unitName, self.checked )
			
			-- re initialise the units
			Units:ReInitialise()
		end
		
		-- add items
		unitHBox:AddItem(unitHeading)
		unitHBox:AddItem(unitEnabledCheckbox)
		hBoxEnabled:AddItem(unitHBox)
	end
	
	
	optionsPane:AddItem(optionsHeading)
	optionsPane:AddItem(spacer)
	optionsPane:AddItem(hBoxEnabled)
	
	local triggerButton = UI.CreateFrame("RiftButton", "gUF_Options", gUF.context)
	triggerButton:SetLayer(7)
	triggerButton:SetText("Units Config")
	
	local optionsItems = { triggerButton, optionsPane }
	
	return optionsItems
end



-- Create the UnitFrames
table.insert(Event.Addon.SavedVariables.Load.End, { Units.Initialise, "gUF_Units", "gUF_Units Variables Loaded" })


-- Register with gUF for options
gUF_AddOn_Config["Units"] = Units.GetOptions
