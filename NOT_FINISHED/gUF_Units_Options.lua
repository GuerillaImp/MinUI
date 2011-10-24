
-- FROM UNITS


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
						local moduleInstance = moduleClass.new( unit, unitSettings.barWidth, unitSettings.barHeight )
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
-- Return a settings panel for the given unit
--
function Units:GetUnitSettingsPanel( unitName )
	local unitSettingsPanel = Box.new( 10, {r=0,g=0,b=0,a=0}, "vertical", "down", gUF.context, 9 )

	local unitHeading = Text.new ( gUF.fonts["arial_round"], 14, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	unitHeading:SetText("Configuring \""..unitName.."\": ")
	
	--
	-- Unit Enabled Horizontal Box
	--
	local unitHBox =  Box.new( 0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local enabledHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	enabledHeading:SetText("Enabled: ")

	
	local unitEnabledCheckboxBox = Box.new( 0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, 11 )
	local unitEnabledCheckbox = UI.CreateFrame("RiftCheckbox", "gUF Unit Enabled Checkbox", gUF.context)
	unitEnabledCheckbox:SetLayer(12)
	unitEnabledCheckboxBox:AddItem(unitEnabledCheckbox)
	
	if(gUF_Units_Settings.unitsEnabled[unitName])	then
		unitEnabledCheckbox.checked = true
		unitEnabledCheckbox:SetChecked(true)
	else
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
	unitHBox:AddItem(enabledHeading)
	unitHBox:AddItem(unitEnabledCheckboxBox)
	
	--
	-- Layout and Texture Config
	--
	local coordsHBox =  Box.new( 0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local coordsHeading = Text.new ( gUF.fonts["arial_round"], 14, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	coordsHeading:SetText("Unit Layout: ")
		
	local xCoordHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	local yCoordHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	xCoordHeading:SetText("X: ")
	yCoordHeading:SetText("Y: ")
	local xCoordsBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local xCoords = UI.CreateFrame("RiftTextfield", "X Coords TextField", gUF.context )
	xCoords:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	xCoords:SetLayer(11)
	xCoords:SetWidth(50)
	xCoords:SetText(""..gUF_Units_Settings.unitSettings[unitName].x)
	xCoordsBox:AddItem(xCoords)
	local yCoordsBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local yCoords = UI.CreateFrame("RiftTextfield", "Y Coords TextField", gUF.context )
	yCoords:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	yCoords:SetLayer(11)
	yCoords:SetWidth(50)
	yCoords:SetText(""..gUF_Units_Settings.unitSettings[unitName].y)
	yCoordsBox:AddItem(yCoords)
	
	local anchorHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	anchorHeading:SetText("Anchor: ")
	local anchorBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local anchorField = UI.CreateFrame("RiftTextfield", "Anchor TextField", gUF.context )
	anchorField:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	anchorField:SetLayer(11)
	anchorField:SetWidth(150)
	anchorField:SetText(gUF_Units_Settings.unitSettings[unitName].anchor)
	anchorBox:AddItem(anchorField)
	
	coordsHBox:AddItem(xCoordHeading)
	coordsHBox:AddItem(xCoordsBox)
	coordsHBox:AddItem(yCoordHeading)
	coordsHBox:AddItem(yCoordsBox)
	coordsHBox:AddItem(anchorHeading)
	coordsHBox:AddItem(anchorBox)
	
	local barSettingsHBox1 =  Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barSettingsHBox2 =  Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barSettingsHBox3 =  Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	
	local barSizeHeading = Text.new ( gUF.fonts["arial_round"], 14, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	barSizeHeading:SetText("Bar Settings: ")
	
	local barWidthHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	local barHeightHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	local barTextureHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	local barFontHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	local barFontSizeHeading = Text.new ( gUF.fonts["arial_round"], 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )

	barHeightHeading:SetText("Height: ")
	barWidthHeading:SetText("Width: ")
	barTextureHeading:SetText("Texture: ")
	barFontHeading:SetText("Font: ")
	barFontSizeHeading:SetText("FontSize: ")
	
	local barWidthBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barWidth = UI.CreateFrame("RiftTextfield", "Width TextField", gUF.context )
	barWidth:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	barWidth:SetLayer(11)
	barWidth:SetWidth(50)
	barWidth:SetText(""..gUF_Units_Settings.unitSettings[unitName].barWidth)
	barWidthBox:AddItem(barWidth)
	
	local barHeightBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barHeight = UI.CreateFrame("RiftTextfield", "Height TextField", gUF.context )
	barHeight:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	barHeight:SetLayer(11)
	barHeight:SetWidth(50)
	barHeight:SetText(""..gUF_Units_Settings.unitSettings[unitName].barHeight)
	barHeightBox:AddItem(barHeight)

	local barTextureFieldBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barTextureField = UI.CreateFrame("RiftTextfield", "Height TextField", gUF.context )
	barTextureField:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	barTextureField:SetLayer(11)
	barTextureField:SetWidth(150)
	barTextureField:SetText(""..gUF_Units_Settings.unitSettings[unitName].barTexture)
	barTextureFieldBox:AddItem(barTextureField)
	
	local barFontFieldBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barFontField = UI.CreateFrame("RiftTextfield", "Height TextField", gUF.context )
	barFontField:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	barFontField:SetLayer(11)
	barFontField:SetWidth(150)
	barFontField:SetText(""..gUF_Units_Settings.unitSettings[unitName].barFont)
	barFontFieldBox:AddItem(barFontField)
	
	local barFontSizeFieldBox = Box.new( 0, {r=0,g=1,b=0,a=0}, "horizontal", "right", gUF.context, 10 )
	local barFontSizeField = UI.CreateFrame("RiftTextfield", "Height TextField", gUF.context )
	barFontSizeField:SetBackgroundColor(gUF.colors["black"].r,gUF.colors["black"].g,gUF.colors["black"].b,gUF.colors["black"].a)
	barFontSizeField:SetLayer(11)
	barFontSizeField:SetWidth(50)
	barFontSizeField:SetText(""..gUF_Units_Settings.unitSettings[unitName].barFontSize)
	barFontSizeFieldBox:AddItem(barFontSizeField)
		
		
	barSettingsHBox1:AddItem(barWidthHeading)
	barSettingsHBox1:AddItem(barWidthBox)
	barSettingsHBox1:AddItem(barHeightHeading)
	barSettingsHBox1:AddItem(barHeightBox)
	barSettingsHBox2:AddItem(barTextureHeading)
	barSettingsHBox2:AddItem(barTextureFieldBox)
	barSettingsHBox3:AddItem(barFontHeading)
	barSettingsHBox3:AddItem(barFontFieldBox)
	barSettingsHBox3:AddItem(barFontSizeHeading)
	barSettingsHBox3:AddItem(barFontSizeFieldBox)
	
	
	--
	-- Modules Config
	--
	local modulesConfigHeading = Text.new ( gUF.fonts["arial_round"], 14, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	modulesConfigHeading:SetText("Modules Config:")
	local moduleBox =  Box.new( 0, {r=0,g=0,b=0,a=0}, "vertical", "down", gUF.context, 10 )
	
	for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modulesEnabled) do
		
		
	end
	
	
	--
	-- Add UnitEnabled hbox
	--
	unitSettingsPanel:AddItem(unitHeading)
	unitSettingsPanel:AddItem(unitHBox)
	unitSettingsPanel:AddItem(coordsHeading)
	unitSettingsPanel:AddItem(coordsHBox)
	unitSettingsPanel:AddItem(barSizeHeading)
	unitSettingsPanel:AddItem(barSettingsHBox1)
	unitSettingsPanel:AddItem(barSettingsHBox2)
	unitSettingsPanel:AddItem(barSettingsHBox3)
	unitSettingsPanel:AddItem(modulesConfigHeading)
	
	return unitSettingsPanel
end

--
-- Get Options
--
--
function Units:GetOptions()
	Units:CheckSettings()
	
	local optionsPane = Box.new( 0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, 7 )
	local configButtonBox = Box.new( 0, {r=0,g=0,b=0,a=0}, "vertical", "down", gUF.context, 7 )
	local configPanel = Panel.new( 530, 790, {r=0,g=0,b=0,a=0.5}, gUF.context, 7 )
	configPanel:SetTexture(gUF.backgrounds["backdrop"])
	--
	-- Buttons for Units To Configure
	--
	for _,unitName in pairs (allUnits) do
		local buttonBox = Box.new( 0, {r=0,g=0,b=0,a=0.5}, "horizontal", "right", gUF.context, 8 )
		local unitButton = UI.CreateFrame("RiftButton", "Unit Button", gUF.context)
		unitButton:SetVisible(false)
		unitButton:SetLayer(9)
		unitButton:SetText(unitName)
		buttonBox:AddItem(unitButton)
		
		function unitButton.Event:LeftPress( )	
			print (unitName,"player button pressed")
			configPanel:RemoveItem(1)
			configPanel:AddItem(Units:GetUnitSettingsPanel( unitName ),"TOPLEFT","TOPLEFT",5,5)
			configPanel:SetVisible(true)
		end
	
		configButtonBox:AddItem(buttonBox)
	end
	
	-- Add Items
	optionsPane:AddItem(configButtonBox)
	optionsPane:AddItem(configPanel)
	
	
	local triggerButton = UI.CreateFrame("RiftButton", "gUF_Options", gUF.context)
	triggerButton:SetLayer(7)
	triggerButton:SetText("Units Config")
	
	local optionsItems = { triggerButton, optionsPane }
	
	return optionsItems
end

