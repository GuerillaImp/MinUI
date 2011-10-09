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

-- Are we current in secure mode?
MinUI.secureMode = false

MinUI.version = "1.2a"


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
					or token == "debuffThreshold" or token == "globalTextFont" or token == "buffAuras"  or token == "debuffAuras" ) then
				command = token 
				--debugPrint("command given ", command)
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
						or command == "debuffThreshold" or command == "buffAuras"  or command == "debuffAuras" ) then
					frameToConfig = token
					----debugPrint("configuring frame", frameToConfig)
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
			-- enabled/disable buffAuras
			elseif (command == "buffAuras") then
				local buffAuras = false
				if(token == "true") then
					buffAuras = true
				end
				print ("Setting buff auras to ", buffAuras, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].buffAuras = buffAuras
				refreshRequired = true
			-- enabled/disable debuffAuras
			elseif (command == "debuffAuras") then
				local debuffAuras = false
				if(token == "true") then
					debuffAuras = true
				end
				print ("Setting debuff auras to ", debuffAuras, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].debuffAuras = debuffAuras
				refreshRequired = true					
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
	--debugPrint("Get Player Details")
	
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
			--debugPrint("Creating ", unitName)
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
				----debugPrint ( "Note: Buffs/debufs are on the same side of the unit frame ", unitSavedValues.buffLocation, " so will merge" )
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
--
-- Rename animate loop (for things that animate :P)
--
local function update()
	--
	-- Poll for player calling until we get one
	--
	if (MinUI.playerCallingKnown == false) then
		debugPrint("waiting for rift to start giving details...")
		getPlayerDetails()
	else
		--
		-- Once we get the player's calling initialise the unitFrames
		--
		if (MinUI.initialised == false) then
			debugPrint("we have details (at least for the player) so lets create the frames now")
			-- Create the Unit Frames
			createUnitFrames()
			
			-- Initialise the Unit Frames
			for unitName, unitFrame in pairs(MinUI.unitFrames) do
				unitFrame:unitChanged()
			end
			
			MinUI.resyncBuffs = true
			MinUI.initialised = true
			
			debugPrint("all done, initialisation complete")
		--
		-- Handle buffs and other items that need to constantly poll for animation/updates
		--
		else
			if(MinUI.resyncBuffs)then
				for unitName, unitFrame in pairs(MinUI.unitFrames) do
					unitFrame:updateBuffBars()
				end
				MinUI.resyncBuffs = false
			else
				for unitName, unitFrame in pairs(MinUI.unitFrames) do
					unitFrame:animateBuffs()
				end
			end
		end
	end
end

local function enterSecureMode()
	debugPrint("+++ entering combat (config disabled)")
	MinUI.secureMode = true
end

local function leaveSecureMode()
	debugPrint("--- leaving combat (config enabled)")
	MinUI.secureMode = false
end

-----------------------------------------------------------------------------------------------------------------------------
--
-- Startup
--
-----------------------------------------------------------------------------------------------------------------------------
local function startup()
	--
	-- We need our context to be restricted, so we can utilise mouse over macros
	--
	-- Eventually
	--
	--MinUI.context:SetSecureMode("restricted")
	
	--
	-- Event Hooks
	--
	
	table.insert (Event.Addon.Load.Begin, {function () print("Loaded ["..MinUI.version.."]. Type /mui for help.") end, "MinUI", "loaded"})
	
	-- Handle User Customisation
	table.insert(Command.Slash.Register("mui"), {muiCommandInterface, "MinUI", "Slash command"})

	-- Inform frames we are entering "secure" mode (basically, combat)
	table.insert(Event.System.Secure.Enter, {enterSecureMode, "MinUI", "entering combat/secure mode"})
	table.insert(Event.System.Secure.Leave, {leaveSecureMode, "MinUI", "leaving combat/secure mode"})
	
	--
	-- A Buff Hath Changed - sucks that I have to use this :/
	--
	table.insert(Event.Buff.Add, {function() MinUI.resyncBuffs = true end, "MinUI",  "MinUI_buffAdd"})
	table.insert(Event.Buff.Change, {function() MinUI.resyncBuffs = true end, "MinUI",  "MinUI_buffChange"})
	table.insert(Event.Buff.Remove, {function() MinUI.resyncBuffs = true end, "MinUI",  "MinUI_buffRemove"})
	
	-- Main Loop Event
	table.insert(Event.System.Update.Begin, {update, "MinUI", "update loop"})
end

-- Start the UnitFrame
startup()


