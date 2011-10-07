--
-- MinUI UnitFrames by Grantus
--


-----------------------------------------------------------------------------------------------------------------------------
--
-- MinUI Global Settings/Values
--
----------------------------------------------------------------------------------------------------------------------------- 
MinUI = {}

MinUI.context = UI.CreateContext("MinUIContext")

-- Unit Frames
MinUI.unitFrames = {}

-- Buff Control
MinUI.resyncBuffs = false

-- Player Calling / Initialisation
MinUI.playerCalling = "unknown"
MinUI.playerCallingKnown = false
MinUI.initialised = false

-----------------------------------------------------------------------------------------------------------------------------
--
-- Core Functions
--
-----------------------------------------------------------------------------------------------------------------------------


--
-- Help Text
--
local function printHelpText()
	print("Mui Commands:")
	print("\'/mui lock\' lock the frames in position.")
	print("\'/mui unlock\' unlock the frames.")
	print("\'/mui reset\' reset the frames to the defaults in MinUIConfig.lua.")
	print("---")
	print("Mui Frame Commands (all require \'/reloadui\'")
	print("Allowed Frames: player, focus, player.pet, player.target, player.target.target")
	print("Number: must be positive")
	print("\'/mui enabe [frame]\' enables a frame.")
	print("\'/mui disable [frame]\' disables a frame.")
	print("\'/mui barWidth [frame] [number]\' sets the frame bar width.")
	print("\'/mui barHeight [frame] [number]\' sets the frame bar width.")
	print("\'/mui barFontSize [frame] [number]\' sets the frame font size.")
	print("\'/mui buffFontSize [frame] [number]\' sets the frame\'s buff bar font size.")
	print("\'/mui unitTextFontSize [frame] [number]\' sets the frame\'s unit text font size.")
	print("\'/mui comboPointsBarHeight [frame] [number]\' sets the frame\'s combo points bar height.")
	print("\'/mui mageChargeBarHeight [frame] [number]\' sets the frame\'s mage charge bar height.")
	print("\'/mui mageChargeFontSize [frame] [number]\' sets the frame\'s mage charge bar\'s font size .")
	print("\'/mui itemOffset [frame] [number]\' sets the frame offset used to space items appart.")
	print("\'/mui buffsEnabled [frame] [true/false]\' enable or disable buffs on the frame.")
	print("\'/mui debuffsEnabled [frame] [true/false]\' enable or disable debuffs on the frame.")
	print("\'/mui buffLocation [frame] [above/below]\' set the location of the buffs on the frame.")
	print("\'/mui debuffLocation [frame] [above/below]\' set the location of the debuffs on the frame.")
	print("\'/mui buffVisibilityOptions [frame] [all/player]\' set the visibility option of the buffs on the frame.")
	print("\'/mui debuffVisibilityOptions [frame] [all/player]\' set the visibility option of the debuffs on the frame.")
	print("\'/mui buffThreshold [frame] [number]\' set the time threshold of the buffs on the frame.")
	print("\'/mui debuffThreshold [frame] [number]\' set the time threshold of the debuffs on the frame.")
	print("---")
	print("Allowed Bars: health,resources,warriorComboPointsBar,rogueComboPointsBar,charge,text")
	print("Allowed Texts: name,level,guild,vitality,planar")
	print("\'/mui bars [frame] [comma,separated,bar,list]\' set the bars shown on the frame to those in the list.")
	print("\'/mui texts [frame] [comma,separated,text,list]\' set the texts shown on the frame \'s unit text bar to those in the list.")
	print("---")
	print("\'/mui globalTextFont [fontName (do not add .ttf)]\' set the font used globally to the one provided, exlude the .ttf.\nWARNING: if the font isn't in the addon folder this makes things go crazy.")
end

--
-- Configuration Interface
--
local function muiCommandInterface(commandline)
	local tokenCount = 0
	local command = nil
	local frameToConfig = nil
	local refreshRequired = false
	local barsToken = nil
	local textsToken = nil
	
	--
	-- Iterate tokens in command line
	--
	for token in string.gmatch(commandline, "[^%s]+") do
		tokenCount = tokenCount + 1
		
		--
		-- Command (First Token)
		--
		if(tokenCount == 1) then
			--
			-- Single Token Commands
			--
			-- lock all frames
			if(token == "lock") then
				lockFrames()
			-- unlock all frames
			elseif(token == "unlock") then
				unlockFrames()
			-- reset all settings to defaults
			elseif(token == "reset") then
				reset()
				refreshRequired = true
			--
			-- Multi Token Commands
			--
			-- enable, disable, barWidth, barHeight, ... (one for each of the MinUIConfig items)
			elseif(	token == "enable" or token == "disable" or token == "barWidth" or token == "barHeight" or token == "barFontSize" 
					or token == "buffFontSize" or token == "unitTextFontSize" or token == "comboPointsBarHeight" or token == "mageChargeBarHeight" 
					or token == "mageChargeFontSize" or token == "itemOffset" or token == "bars" or token == "texts" 
					or token == "buffsEnabled" or token == "debuffsEnabled" or token == "buffLocation" or token == "debuffLocation"
					or token == "buffVisibilityOptions" or token == "debuffVisibilityOptions" or token == "buffThreshold" 
					or token == "debuffThreshold" or token == "globalTextFont") then
				command = token 
				print("command given ", command)
			-- unknown command
			else
				print ("Unknown command, type \'/mui\' for help")
			end
		end
		
		--
		-- Frame Name or Font Second Token) 
		--
		if (command and tokenCount == 2) then
			-- Set Global Font 
			if (command == "globalTextFont") then
				if(token)then
					print("Setting global font to ", token)
					MinUIConfig.globalTextFont = token
					refreshRequired = true
				end
			-- Configure Frame
			elseif(MinUIConfig.frames[token])then
				--
				-- Commands without Parameters
				--
				-- enable a frame
				if (command == "enable") then
					print("Enabling ", token)
					MinUIConfig.frames[token].frameEnabled = true
					refreshRequired = true
				-- disable a frame
				elseif (command == "disable") then
					print("Disabling ", token)
					MinUIConfig.frames[token].frameEnabled = false
					refreshRequired = true
				--
				-- Commands with Parameters
				--
				-- set barWidth, barHeight, barFontSize, buffFontSize, buffFontSize, unitTextFontSize
				elseif (command == "barWidth" or command == "barHeight" or command == "barFontSize" or command == "buffFontSize" 
						or command == "unitTextFontSize" or command == "comboPointsBarHeight" or command == "mageChargeBarHeight"
						or command == "mageChargeFontSize" or command == "itemOffset" or command == "bars"  or command == "texts" 
						or command == "buffsEnabled" or command == "debuffsEnabled" or command == "buffLocation" or command == "debuffLocation"
						or command == "buffVisibilityOptions" or command == "debuffVisibilityOptions" or command == "buffThreshold" 
						or command == "debuffThreshold" ) then
					frameToConfig = token
					--print("configuring frame", frameToConfig)
				end
			else
				print("Error in command, type \'/mui\' for help")	
			end
		end
		
		--
		-- Parameters for Frame
		--
		if (command and frameToConfig and tokenCount == 3) then
			-- set bar width
			if (command == "barWidth") then
				local barWidth = tonumber(token)
				print ("Setting bar width to ", barWidth, " on ", frameToConfig)
				if(barWidth > 0)then
					MinUIConfig.frames[frameToConfig].barWidth = barWidth
					refreshRequired = true
				end
			-- set bar height
			elseif (command == "barHeight") then
				local barHeight = tonumber(token)
				print ("Setting bar height to ", barHeight, " on ", frameToConfig)
				if(barHeight > 0)then
					MinUIConfig.frames[frameToConfig].barHeight = barHeight
					refreshRequired = true
				end
			-- set bar fontSize
			elseif (command == "barFontSize") then
				local barFontSize = tonumber(token)
				print ("Setting bar font size to ", barFontSize, " on ", frameToConfig)
				if(barFontSize > 0)then
					MinUIConfig.frames[frameToConfig].barFontSize = barFontSize
					refreshRequired = true
				end
			-- set buff fontSize
			elseif (command == "buffFontSize") then
				local buffFontSize = tonumber(token)
				print ("Setting buff font size to ", buffFontSize, " on ", frameToConfig)
				if(buffFontSize > 0)then
					MinUIConfig.frames[frameToConfig].buffFontSize = buffFontSize
					refreshRequired = true
				end
			-- set unit text fontSize
			elseif (command == "unitTextFontSize") then
				local unitTextFontSize = tonumber(token)
				print ("Setting Unit Text Font Size", unitTextFontSize, " on ", frameToConfig)
				if(unitTextFontSize > 0)then
					MinUIConfig.frames[frameToConfig].unitTextFontSize = unitTextFontSize
					refreshRequired = true
				end
			-- set combo bar height
			elseif (command == "comboPointsBarHeight") then
				local comboPointsBarHeight = tonumber(token)
				print ("Setting combo bar height to ", comboPointsBarHeight, " on ", frameToConfig)
				if(comboPointsBarHeight > 0)then
					MinUIConfig.frames[frameToConfig].comboPointsBarHeight = comboPointsBarHeight
					refreshRequired = true
				end
			-- set mage charge bar height
			elseif (command == "mageChargeBarHeight") then
				local mageChargeBarHeight = tonumber(token)
				print ("Setting mage charge bar height to ", mageChargeBarHeight, " on ", frameToConfig)
				if(mageChargeBarHeight > 0)then
					MinUIConfig.frames[frameToConfig].mageChargeBarHeight = mageChargeBarHeight
					refreshRequired = true
				end
			-- set mage charge bar font size
			elseif (command == "mageChargeFontSize") then
				local mageChargeFontSize = tonumber(token)
				print ("Setting mage charge bar font size to ", mageChargeFontSize, " on ", frameToConfig)
				if(mageChargeFontSize > 0)then
					MinUIConfig.frames[frameToConfig].mageChargeFontSize = mageChargeFontSize
					refreshRequired = true
				end
			-- set item offset for frame
			elseif (command == "itemOffset") then
				local itemOffset = tonumber(token)
				print ("Setting item offset to ", itemOffset, " on ", frameToConfig)
				if(itemOffset > 0)then
					MinUIConfig.frames[frameToConfig].itemOffset = itemOffset
					refreshRequired = true
				end	
			-- set buffs enabled/disabled
			elseif (command == "buffsEnabled") then
				local buffsEnabled = false
				if(token == "true") then 
					buffsEnabled = true
				else
					buffsEnabled = false
				end
				print ("Setting buffs enabled to ", buffsEnabled, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].buffsEnabled = buffsEnabled
				refreshRequired = true
			-- set debuffs enabled/disabled
			elseif (command == "debuffsEnabled") then
				local debuffsEnabled = false
				if(token == "true") then 
					debuffsEnabled = true
				else
					debuffsEnabled = false
				end
				print ("Setting debuffs enabled to ", debuffsEnabled, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].debuffsEnabled = debuffsEnabled
				refreshRequired = true			
			-- set buff location
			elseif (command == "buffLocation") then
				local buffLocation = token
				print ("Setting buffs location to ", buffLocation, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].buffLocation = buffLocation
				refreshRequired = true	
			-- set debuff location
			elseif (command == "debuffLocation") then
				local debuffLocation = token
				print ("Setting debuffs location to ", debuffLocation, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].debuffLocation = debuffLocation
				refreshRequired = true					
			-- set buff visibility options
			elseif (command == "buffVisibilityOptions") then
				local buffVisibilityOptions = token
				print ("Setting buffs visibility options to ", buffVisibilityOptions, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].buffVisibilityOptions = buffVisibilityOptions
				refreshRequired = true					
			-- set debuff visibility options
			elseif (command == "debuffVisibilityOptions") then
				local debuffVisibilityOptions = token
				print ("Setting debuffs visibility options to ", debuffVisibilityOptions, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].debuffVisibilityOptions = debuffVisibilityOptions
				refreshRequired = true						
			-- set buff threshold options
			elseif (command == "buffThreshold") then
				local buffThreshold = tonumber(token)
				if(buffThreshold > 0) then
					print ("Setting buffs threshold to ", buffThreshold, " on ", frameToConfig)
					MinUIConfig.frames[frameToConfig].buffThreshold = buffThreshold
					refreshRequired = true
				end				
			-- set buff threshold options
			elseif (command == "debuffThreshold") then
				local debuffThreshold = tonumber(token)
				if(debuffThreshold > 0) then
					print ("Setting debuffs threshold to ", debuffThreshold, " on ", frameToConfig)
					MinUIConfig.frames[frameToConfig].debuffThreshold = debuffThreshold
					refreshRequired = true
				end				
			-- bars requires a comma separated list of items afterwards (health,resource,charge,text,comboPointsBar)
			elseif (command == "bars") then
				barsToken = token
			-- texts requires a comma separated list of items afterwards (name,level,vitality,planar,guild)
			elseif (command == "texts") then
				textsToken = token
			end
		end
	end

	
	--
	-- Add Bars to the Given Frame
	--
	if (command and frameToConfig and barsToken) then
		local barsToAdd = {}
		local index = 1
		for bar in string.gmatch(barsToken, "[^%s,]+") do
			barsToAdd[index] = bar
			index = index+1
		end
		-- echo the bars to the user
		for index, barType in ipairs(barsToAdd) do
			print ("Adding bar ", barType," to ", frameToConfig, " in position ", index)
		end
		MinUIConfig.frames[frameToConfig].bars = barsToAdd
		refreshRequired = true
	end
	
	--
	-- Add Texts to the Given Frame
	--
	if (command and frameToConfig and textsToken) then
		local textsToAdd = {}
		local index = 1
		for text in string.gmatch(textsToken, "[^%s,]+") do
			textsToAdd[index] = text
			index = index+1
		end
		-- echo the bars to the user
		for index, textType in ipairs(textsToAdd) do
			print ("Adding text ", textType," to ", frameToConfig ) -- todo make positioning matter
		end
		print("note these will only show if you have the \'text\' bar enabled")
		MinUIConfig.frames[frameToConfig].texts = textsToAdd
		refreshRequired = true
	end
	
	--
	-- if the user typed /mui
	--
	if (tokenCount == 0) then
		printHelpText()
	end
		
	if(refreshRequired)then
		-- TODO: somehow automatically recreate the frames?
		-- although, we can't delete frames at the moment so this wont  work ;/
		print("***To see changes \'/reloadui\' (this will ensure they are saved properly)***")
	end
end


--
-- Inspect player for calling, sometimes this returns nil (when loading or porting)
--
local function getPlayerDetails()
	debugPrint("Get Player Details")
	
	-- based on player class some things are different
	local playerDetails = Inspect.Unit.Detail("player")
	if (playerDetails) then
		MinUI.playerCalling = playerDetails.calling
	end
	
	-- did we get it yet?
	if (MinUI.playerCalling == "unknown") then
		MinUI.playerCallingKnown = false
	else
		MinUI.playerCallingKnown = true
	end
end


--
-- Based on Config Create desired unitFrames
--
local function createUnitFrames()
	-- Create Unit Frames based on MinUIConfig Saved Settings
	for unitName, unitSavedValues in pairs(MinUIConfig.frames) do
		-- if the frame is enabled
		if(unitSavedValues.frameEnabled) then
			print("Creating ", unitName)
			-- create new unitframe
			local newFrame = UnitFrame.new( unitName, unitSavedValues.barWidth + (unitSavedValues.itemOffset*2), unitSavedValues.barHeight, MinUI.context, unitSavedValues.x, unitSavedValues.y )
			
			local enabledBars = unitSavedValues.bars
			local enabledTexts = unitSavedValues.texts
			
			-- add enabled bars
			for position,barType in ipairs(enabledBars) do
				-- Check player is a calling that has combo points
				if ( barType == "warriorComboPoints" ) then
					if ( MinUI.playerCalling  == "warrior" ) then
						newFrame:enableBar(position, "comboPointsBar")
					end
				elseif ( barType == "rogueComboPoints" ) then
					if ( MinUI.playerCalling  == "rogue" ) then
						newFrame:enableBar(position, "comboPointsBar")
					end
				-- Check player is a calling that has charge
				elseif ( barType == "charge" ) then
					if ( MinUI.playerCalling  == "mage" ) then
						newFrame:enableBar(position, barType)
					end
				else
					newFrame:enableBar(position, barType)
				end
			end
			newFrame:createEnabledBars()
			
			-- add enabled texts
			for _, text in ipairs(enabledTexts) do
				newFrame:showText (text)
			end
			
			
			-- check if both buff/debuff are on the same side and we need to make a "merged" buff bar
			local mergedBuffBar = false
			if ( unitSavedValues.buffsEnabled == true and unitSavedValues.debuffsEnabled == true ) then
				if ( unitSavedValues.buffLocation == unitSavedValues.debuffLocation ) then
					mergedBuffBar = true
				end
			end
			
			-- if we do have a merged buff bar then create it
			if ( mergedBuffBar ) then
				--print ( "Note: Buffs/debufs are on the same side of the unit frame ", unitSavedValues.buffLocation, " so will merge" )
				-- NOTE: in merged bars the threshold and visibility options provided here are ignored (and read out of MinUI Config)
				newFrame:addBuffBars( "merged", unitSavedValues.buffVisibilityOptions, unitSavedValues.buffThreshold, unitSavedValues.buffLocation)
			-- else create bars as normal
			else
				-- create buff bars
				if ( unitSavedValues.buffsEnabled == true ) then
					newFrame:addBuffBars( "buffs", unitSavedValues.buffVisibilityOptions, unitSavedValues.buffThreshold, unitSavedValues.buffLocation)
				end
				
				-- create debuff bars
				if ( unitSavedValues.debuffsEnabled == true ) then
					newFrame:addBuffBars( "debuffs", unitSavedValues.debuffVisibilityOptions, unitSavedValues.debuffThreshold, unitSavedValues.debuffLocation)
				end
			end
			
			-- store the unitframe
			MinUI.unitFrames[unitName] = newFrame
		end
	end
end

--
-- Main Update Loop (For Buffs)
--
local function update()
	-- Poll for player calling until we get one
	if (MinUI.playerCallingKnown == false) then
		getPlayerDetails()
	else
		-- Once we get the player's calling initialise the unitFrames
		if (MinUI.initialised == false) then
		
			-- Create the Unit Frames
			createUnitFrames()
			
			-- Initialise the Unit Frames
			for unitName, unitFrame in pairs(MinUI.unitFrames) do
				unitFrame:refresh()
			end
			
			MinUI.resyncBuffs = true
			MinUI.initialised = true
		end
				
		-- A buff recalculation has been queued, so go ahead and recalculate.
		if MinUI.resyncBuffs then
			for unitName, unitFrame in pairs(MinUI.unitFrames) do
				unitFrame:refreshBuffBars(Inspect.Time.Frame())
			end
			MinUI.resyncBuffs = false
		-- else just tick the buff bars along
		else
			for unitName, unitFrame in pairs(MinUI.unitFrames) do
				unitFrame:tickBuffBars(Inspect.Time.Frame())
			end
		end
		
		
				
		-- update cause the unit unitFrames to ensure they are all up to date every frame
		-- this isn't the best way of doing this but for now it will do
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			unitFrame:refresh()
			unitFrame:tickBuffBars(Inspect.Time.Frame())
		end
		
		
	end
end

local function enterSecureMode()
	print("+++ entering combat")
end

local function leaveSecureMode()
	print("--- leaving combat")
end


--
-- I attempted to be smart, and not poll the unit's every frame, but ...
-- It's a bit of a waste of time since tab targetting doesnt give unitDetails, and events don't fire for 
-- target of target - making the entire excersize a waste of time
--

--
-- Refresh ToT
--
--[[
local function refreshToT()
	if(MinUI.unitFrames["player.target.target"])then
		MinUI.unitFrames["player.target.target"]:refresh()
		MinUI.unitFrames["player.target.target"]:resetBuffBars()
	end
end

--
-- Refresh Target
--
local function refreshTarget()
	if(MinUI.unitFrames["player.target"])then
		MinUI.unitFrames["player.target"]:refresh()
		MinUI.unitFrames["player.target"]:resetBuffBars()
	end
end
--
-- If our target changes, refresh the target/tot frames and resync buffs
--
local function refreshTargets ( units )

	MinUI.resyncBuffs = true
	
	--
	-- Update Target/TOT
	--
	refreshTarget()
	refreshToT()
end



--
-- Update Unit's Health Values
--
local function unitHealthChanged( units )
	for unitID,_ in pairs(units) do
		local unitChanged = Inspect.Unit.Lookup (unitID)
		--print("health changed", unitChanged)
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			if(unitName == unitChanged) then
				unitFrame:updateHealth()
			end
		end 
	end
	
	-- Target of Target never has these events fired for them
	-- So we need to refresh it manually
	refreshToT()
end

--
-- Update Unit's Max Health Values
--
local function unitHealthMaxChanged( units )
	unitHealthChanged ( units )
end

local function unitManaChanged( units )
	for unitID,_ in pairs(units) do
		local unitChanged = Inspect.Unit.Lookup (unitID)
		--print("mana changed", unitChanged)
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			if(unitName == unitChanged) then
				unitFrame:updateResources()
			end
		end 
	end
		
	-- Target of Target never has these events fired for them
	-- So we need to refresh it manually
	refreshToT()
end

local function unitManaMaxChanged( units )
	unitManaChanged(units)
end

local function unitPowerChanged( units )
	for unitID,_ in pairs(units) do
		local unitChanged = Inspect.Unit.Lookup (unitID)
		--print("power changed", unitChanged)
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			if(unitName == unitChanged) then
				unitFrame:updateResources()
			end
		end 
	end
	
		
	-- Target of Target never has these events fired for them
	-- So we need to refresh it manually
	refreshToT()
end

local function unitEnergyChanged( units )
	for unitID,_ in pairs(units) do
		local unitChanged = Inspect.Unit.Lookup (unitID)
		--print("energy changed", unitChanged)
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			if(unitName == unitChanged) then
				unitFrame:updateResources()
			end
		end 
	end
	
		
	-- Target of Target never has these events fired for them
	-- So we need to refresh it manually
	refreshToT()
end

local function unitEnergyMaxChanged( units )
	unitEnergyChanged (units)
end

local function unitComboChanged( units )
	for unitID,_ in pairs(units) do
		local unitChanged = Inspect.Unit.Lookup (unitID)
		--print("combo changed", unitChanged)
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			if(unitName == unitChanged) then
				unitFrame:updateComboPointsBar()
			end
		end 
	end
	
		
	-- Target of Target never has these events fired for them
	-- So we need to refresh it manually
	refreshToT()
end

local function unitComboUnitChanged( units )
	unitComboChanged ( units )
end

local function unitChargeChanged( units )
	for unitID,_ in pairs(units) do
		local unitChanged = Inspect.Unit.Lookup (unitID)
		--print("charge changed", unitChanged)
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			if(unitName == unitChanged) then
				unitFrame:updateChargeBar()
			end
		end 
	end
	
		
	-- Target of Target never has these events fired for them
	-- So we need to refresh it manually
	refreshToT()
end
]]


-----------------------------------------------------------------------------------------------------------------------------
--
-- Startup
--
-----------------------------------------------------------------------------------------------------------------------------
local function startup()
	-- We need our context to be restricted, so we can utilise mouse over macros
	MinUI.context:SetSecureMode("restricted")

	--
	-- event hooks
	--
	
	-- Target Changed
	-- table.insert(Event.Ability.Target, {refreshTargets, "MinUI", "target changed"})
	table.insert(Event.Ability.Target, {function () MinUI.resyncBuffs = true end, "MinUI", "target changed"})
	
	-- Buffs
	table.insert(Event.Buff.Add, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Change, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Remove, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	
	-- Unit Changes (So we don't have to poll for updates)
	-- A bit of a waste of time since tab targetting doesnt give unitDetails, and these events don't fire for 
	-- target of target
	--[[
	table.insert(Event.Unit.Detail.Health, {unitHealthChanged, "MinUI", "unit health changed"})
	table.insert(Event.Unit.Detail.HealthMax, {unitHealthMaxChanged, "MinUI", "unit health max changed"})
	table.insert(Event.Unit.Detail.Mana, {unitManaChanged, "MinUI", "unit mana changed"})
	table.insert(Event.Unit.Detail.ManaMax, {unitManaMaxChanged, "MinUI", "unit mana max changed"})
	table.insert(Event.Unit.Detail.Power, {unitPowerChanged, "MinUI", "unit power changed"})
	table.insert(Event.Unit.Detail.Energy, {unitEnergyChanged, "MinUI", "unit energy changed"})
	table.insert(Event.Unit.Detail.EnergyMax, {unitEnergyMaxChanged, "MinUI", "unit energy max changed"})
	table.insert(Event.Unit.Detail.Combo, {unitComboChanged, "MinUI", "unit combo max changed"})
	table.insert(Event.Unit.Detail.ComboUnit, {unitComboUnitChanged, "MinUI", "unit combo max changed"})
	table.insert(Event.Unit.Detail.Charge, {unitChargeChanged, "MinUI", "unit charge max changed"})
	]]
	
	-- Handle User Customisation
	table.insert(Command.Slash.Register("mui"), {muiCommandInterface, "MinUI", "Slash command"})

	-- Inform frames we are entering "secure" mode (basically, combat)
	table.insert(Event.System.Secure.Enter, {enterSecureMode, "MinUI", "entering combat/secure mode"})
	table.insert(Event.System.Secure.Leave, {leaveSecureMode, "MinUI", "leaving combat/secure mode"})
	
	-- Main Loop Event
	--createUnitFrames()
	table.insert(Event.System.Update.Begin, {update, "MinUI", "update loop"})
end

-- Start the UnitFrame
startup()