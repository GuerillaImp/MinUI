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

-- Locked
MinUI.framesLocked = true

-- Player Calling / Initialisation
MinUI.playerCalling = "unknown"
MinUI.playerCallingKnown = false
MinUI.initialised = false

-- Update/Animation throttling
MinUI.lastBuffUpdate = 0
MinUI.lastAnimationUpdate = 0
MinUI.buffUpdateDiff = 0
MinUI.animationUpdateDiff = 0
MinUI.curTime = 0
MinUI.animateBuffs = false
MinUI.animate = false
			
-- Are we current in secure mode?
MinUI.secureMode = false

-- Version
MinUI.version = "1.3.2"


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
	print("\'/mui barTexture [textureName (do not add .png/.tga)]\' change the bar texture for this frame\nCan be \"smooth\",\"ace\",\"minimalist\",\"aluminium\",\"banto\",\"glaze\",\"lite\",\"otravi\", or the filename (excluding extension) of any .tga or .png you place in /Media of the addon folder.")
	print("\'/mui buffUpdateThreshold [number]\' set the buffs to \"tick\" at this number, by default it is 1.0 (1 second) but this will look odd for bars, which need around 0.1 to look decent\nThe lower this goes, the more CPU time the addon will consume.")
	print("\'/mui animationUpdateThreshold [number]\' set the animation threshold value, by default it is 0.01 (10 ms). This effects castbars, and other animating items.")
	print("---")
	print("Mui Frame Commands (all require \'/reloadui\'")
	print("Allowed Frames: player, focus, player.pet, player.target, player.target.target")
	print("Number: must be positive")
	print("\'/mui enabe [frame]\' enables a frame.")
	print("\'/mui disable [frame]\' disables a frame.")
	print("\'/mui scale [frame] [number]\' scales a frame.")
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
	print("\'/mui buffAuras [frame] [true/false]\' show buff auras on the frame.")
	print("\'/mui debuffAuras [frame] [true/false]\' show debuff auras on the frame.")
	print("\'/mui buffView [frame] [bar/icon] change the view of the frame's buffs to an icon or bar style.")
	print("\'/mui debuffView [frame] [bar/icon] change the view of the frame's debuffs to an icon or bar style.")
	print("\'/mui buffsMax [frame] [number] the max number of buffs that will be displayed.")
	print("\'/mui debuffsMax [frame] [number] the max number of debuffs that will be displayed.")
	print("\'/mui castbar [frame] [above/below/none] change the casthar on the frame to be above, below or none.")
	print("---")
	print("Allowed Bars: health,resources,warriorComboPoints,rogueComboPoints,charge,text")
	print("Allowed Texts: name,level,guild,vitality,planar")
	print("\'/mui bars [frame] [comma,separated,bar,list]\' set the bars shown on the frame to those in the list.")
	print("\'/mui texts [frame] [comma,separated,text,list]\' set the texts shown on the frame \'s unit text bar to those in the list.")
	print("---")
	print("\'/mui globalTextFont [fontName (do not add .ttf)]\' set the font used globally to the one provided, exlude the .ttf.\nWARNING: if the font isn't in the addon folder this makes things go crazy.")
	print("\'/mui backgroundColor [r,g,b,a]\' set the unit frames background color.")
end

--
-- lock frames
--
local function lockFrames()
	print "Frames Locked"
	MinUI.framesLocked = true
	
	for _,frame in pairs (MinUI.unitFrames) do
		frame:showMovementHandle(false)
	end
end

--
-- unlock frames
--
local function unlockFrames()
	print "Frames Unlocked"
	MinUI.framesLocked = false
	
	for _,frame in pairs (MinUI.unitFrames) do
		frame:showMovementHandle(true)
	end
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
			elseif(	token == "enable" or token == "disable" or token == "backgroundColor"  or token == "barTexture" or token == "barWidth" or token == "barHeight" or token == "barFontSize" or token == "scale"
					or token == "buffFontSize" or token == "unitTextFontSize" or token == "comboPointsBarHeight" or token == "mageChargeBarHeight" 
					or token == "mageChargeFontSize" or token == "itemOffset" or token == "bars" or token == "texts" 
					or token == "buffsEnabled" or token == "debuffsEnabled" or token == "buffLocation" or token == "debuffLocation"
					or token == "buffVisibilityOptions" or token == "debuffVisibilityOptions" or token == "buffThreshold" 
					or token == "debuffThreshold" or token == "globalTextFont" or token == "buffAuras"  or token == "debuffAuras" or token == "buffView"  or token == "debuffView" or token == "castbar" 
					or token == "buffUpdateThreshold" or token == "animationUpdateThreshold" or token == "buffsMax" or token == "debuffsMax") then
				command = token 
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
			-- Set Global Texture 
			elseif (command == "barTexture") then
				if(token)then
					print("Setting bar texture to ", token)
					MinUIConfig.barTexture = token
					refreshRequired = true
				end
			-- Set Global Buff Update Threshold 
			elseif (command == "buffUpdateThreshold") then
				local threshold = tonumber(token)
				if(threshold)then
					print("Setting buffUpdateThreshold to ", threshold)
					MinUIConfig.buffUpdateThreshold = threshold
				end
			-- Set Global Animation Update Threshold 
			elseif (command == "animationUpdateThreshold") then
				local threshold = tonumber(token)
				if(threshold)then
					print("Setting animationUpdateThreshold to ", threshold)
					MinUIConfig.animationUpdateThreshold = threshold
				end
			-- Set Background Color
			elseif(command == "backgroundColor")then
				local backgroundColor = {r=0,g=0,b=0,a=0}
				local index = 1
				if(token)then
					for color in string.gmatch(token, "[^%s,]+") do
						local value = tonumber(color)
						if ( value ) then
							if ( value >= 0 ) then
								if(index == 1)then
									backgroundColor.r = value
								elseif(index == 2)then
									backgroundColor.g = value
								elseif(index == 3)then
									backgroundColor.b = value
								elseif(index == 4)then
									backgroundColor.a = value
								end
							end
						end
						index = index+1
					end
					
					-- sanity check teh value
					print("Setting background color values to, ", backgroundColor.r,backgroundColor.g,backgroundColor.b,backgroundColor.a)
					MinUIConfig.backgroundColor = backgroundColor
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
				elseif (command == "barWidth" or command == "barHeight" or command == "barFontSize" or command == "buffFontSize" or command == "scale"
						or command == "unitTextFontSize" or command == "comboPointsBarHeight" or command == "mageChargeBarHeight"
						or command == "mageChargeFontSize" or command == "itemOffset" or command == "bars"  or command == "texts" 
						or command == "buffsEnabled" or command == "debuffsEnabled" or command == "buffLocation" or command == "debuffLocation"
						or command == "buffVisibilityOptions" or command == "debuffVisibilityOptions" or command == "buffThreshold" 
						or command == "debuffThreshold" or command == "buffAuras"  or command == "debuffAuras" or command == "buffView"  or command == "debuffView" or command == "castbar"  
						or command == "buffsMax"  or command == "debuffsMax" ) then
					frameToConfig = token
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
			-- set frame scale value
			elseif (command == "scale") then
				local scale = tonumber(token)
				print ("Setting scale to ", scale, " on ", frameToConfig)
				if(scale > 0)then
					MinUIConfig.frames[frameToConfig].scale = scale
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
			-- buff view type
			elseif (command == "buffView") then
				local buffView = token
				print ("Setting buff view to ", buffView, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].buffView = buffView
				refreshRequired = true		
			-- debuff view type
			elseif (command == "debuffView") then
				local debuffView = token
				print ("Setting debuff view to ", debuffView, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].debuffView = debuffView
				refreshRequired = true
			-- max buffs to show
			elseif (command == "buffsMax") then
				local buffsMax = tonumber(token)
				print ("Setting buffsMax to ", buffsMax, " on ", frameToConfig)
				if(buffsMax > 0)then
					MinUIConfig.frames[frameToConfig].buffsMax = buffsMax
					refreshRequired = true
				end	
			-- max debuffs to show				
			elseif (command == "debuffsMax") then
				local debuffsMax = tonumber(token)
				print ("Setting debuffsMax to ", debuffsMax, " on ", frameToConfig)
				if(debuffsMax > 0)then
					MinUIConfig.frames[frameToConfig].debuffsMax = debuffsMax
					refreshRequired = true
				end					
			-- debuff view type
			elseif (command == "castbar") then
				local castbar = token
				print ("Setting castbar to ", castbar, " on ", frameToConfig)
				MinUIConfig.frames[frameToConfig].castbar = castbar
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
			local newFrame = nil
			if (unitSavedValues.scale) then
				--debugPrint("Scale: ",unitSavedValues.scale)
				local scaledWidth = (unitSavedValues.barWidth + (unitSavedValues.itemOffset*2)) * unitSavedValues.scale
				local scaledHeight = unitSavedValues.barHeight * unitSavedValues.scale
				newFrame = UnitFrame.new( unitName, scaledWidth, scaledHeight, MinUI.context, unitSavedValues.x, unitSavedValues.y )
			else	
				
				newFrame = UnitFrame.new( unitName, (unitSavedValues.barWidth + (unitSavedValues.itemOffset*2)), unitSavedValues.barHeight, MinUI.context, unitSavedValues.x, unitSavedValues.y )
			end
			
			
			local enabledBars = unitSavedValues.bars
			local enabledTexts = unitSavedValues.texts
			
			-- add enabled bars
			for position,barType in ipairs(enabledBars) do
				--debugPrint("creating bar ", barType, " at position ", position)
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
			
			-- create cast bar if enabled
			local castBar =  unitSavedValues.castbar 
			if ( castBar ) then
				newFrame:addCastBar(castBar)
			end
			
			-- check if both buff/debuff are on the same side and we need to make a "merged" buff bar
			local mergedBuffs = false
			if ( unitSavedValues.buffsEnabled == true and unitSavedValues.debuffsEnabled == true ) then
				if ( unitSavedValues.buffLocation == unitSavedValues.debuffLocation ) then
					mergedBuffs = true
				end
			end
			
			local buffView = unitSavedValues.buffView
			local debuffView = unitSavedValues.debuffView
			
			-- if we do have a merged buff bar then create it
			if ( mergedBuffs ) then
				-- NOTE: in merged bars the threshold and visibility options provided here are ignored (and read out of MinUI Config)
				newFrame:addBuffs( buffView, "merged", unitSavedValues.buffVisibilityOptions, unitSavedValues.buffThreshold, unitSavedValues.buffLocation)
			-- else create bars as normal
			else
				-- create buff bars
				if ( unitSavedValues.buffsEnabled == true ) then
					newFrame:addBuffs( buffView, "buffs", unitSavedValues.buffVisibilityOptions, unitSavedValues.buffThreshold, unitSavedValues.buffLocation)
				end
				
				-- create debuff bars
				if ( unitSavedValues.debuffsEnabled == true ) then
					newFrame:addBuffs( debuffView, "debuffs", unitSavedValues.debuffVisibilityOptions, unitSavedValues.debuffThreshold, unitSavedValues.debuffLocation)
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
local function animate()
	--
	-- calculate frame time difference
	--
	MinUI.curTime = Inspect.Time.Frame()
	MinUI.buffUpdateDiff = MinUI.curTime  - MinUI.lastBuffUpdate
	MinUI.animationUpdateDiff = MinUI.curTime  - MinUI.lastAnimationUpdate
	MinUI.animateBuffs = false
	MinUI.animate = false
	
	if(MinUI.buffUpdateDiff >= MinUIConfig.buffUpdateThreshold)then
		MinUI.animateBuffs = true
		MinUI.lastBuffUpdate = MinUI.curTime 
		MinUI.buffUpdateDiff = 0
	end

	if(MinUI.animationUpdateDiff >= MinUIConfig.animationUpdateThreshold)then
		MinUI.animate = true
		MinUI.lastAnimationUpdate = MinUI.curTime 
		MinUI.animationUpdateDiff = 0
	end

	--
	-- update / animate buffs/castbars etc
	--
	for unitName, unitFrame in pairs(MinUI.unitFrames) do
		if ( MinUI.animateBuffs ) then
			unitFrame:animateBuffTimers( MinUI.curTime  )
		end
		if ( MinUI.animate ) then
			unitFrame:animate()
		end
	end
end

local function enterSecureMode()
	--debugPrint("+++ entering combat (config disabled)")
	MinUI.secureMode = true
	
	-- if we have a player frame, tell it to be "in combat"
	local player = MinUI.unitFrames["player"]
	if(player)then
		player:setInCombat(true)
	end
end

local function leaveSecureMode()
	--debugPrint("--- leaving combat (config enabled)")
	MinUI.secureMode = false
	
	-- if we have a player frame, tell it to be "in combat"
	local player = MinUI.unitFrames["player"]
	if(player)then
		player:setInCombat(false)
	end
end

--
-- Check saved vars are all good
--
local function variablesLoaded( addon )
	if not (addon == "MinUI") then
		return
	end
	
	--
	-- Ensure the Saved Variables do not contain nil values (because of new additions or w.e.)
	--
	if not MinUIConfig.globalTextFont then
		print("New config setting globalTextFont added")
		MinUIConfig.globalTextFont = MinUIConfigDefaults.globalTextFont
	end
	if not MinUIConfig.barTexture then
		print("New config setting barTexture added")
		MinUIConfig.barTexture = MinUIConfigDefaults.barTexture
	end
	if not MinUIConfig.backgroundColor then
		print("New config setting backgroundColor added")
		MinUIConfig.backgroundColor = MinUIConfigDefaults.backgroundColor
	end

	if not MinUIConfig.buffUpdateThreshold then
		print("New config setting buffUpdateThreshold added")
		MinUIConfig.buffUpdateThreshold = MinUIConfigDefaults.buffUpdateThreshold
	end
	
	if not MinUIConfig.animationUpdateThreshold then
		print("New config setting animationUpdateThreshold added")
		MinUIConfig.animationUpdateThreshold = MinUIConfigDefaults.animationUpdateThreshold
	end
	
	
	if not MinUIConfig.frames then -- if this happens the version is probably epically old anyawys
		print("Restored frames from Default - did not exist in MinUIConfig")
		MinUIConfig.frames = MinUIConfigDefaults.frames
	end

	--
	-- For all Frames in MinUIConfig.frames, check that we aren't missing any values (because of new options or w.e.)
	--
	for key,_ in pairs(MinUIConfig.frames) do
		--debugPrint("Checking: ",key, " saved variables")
		
		if not MinUIConfig.frames[key].x then
			print("Restored ",key, " x value from defaults")
			MinUIConfig.frames[key].x = MinUIConfigDefaults.frames[key].x
		end
		if not MinUIConfig.frames[key].y then
			print("Restored ",key, " y value from defaults")
			MinUIConfig.frames[key].y = MinUIConfigDefaults.frames[key].y
		end
		if not MinUIConfig.frames[key].scale then
			print("Restored ",key, " scale value from defaults")
			MinUIConfig.frames[key].scale = MinUIConfigDefaults.frames[key].scale
		end
		if not MinUIConfig.frames[key].barWidth then
			print("Restored ",key, " frameEnabled value from defaults")
			MinUIConfig.frames[key].barWidth = MinUIConfigDefaults.frames[key].barWidth
		end
		if not MinUIConfig.frames[key].barHeight then
			print("Restored ",key, " barHeight value from defaults")
			MinUIConfig.frames[key].barHeight = MinUIConfigDefaults.frames[key].barHeight
		end
		if not MinUIConfig.frames[key].barFontSize then
			print("Restored ",key, " barFontSize value from defaults")
			MinUIConfig.frames[key].barFontSize = MinUIConfigDefaults.frames[key].barFontSize
		end
		if not MinUIConfig.frames[key].buffFontSize then
			print("Restored ",key, " buffFontSize value from defaults")
			MinUIConfig.frames[key].buffFontSize = MinUIConfigDefaults.frames[key].buffFontSize
		end
		if not MinUIConfig.frames[key].unitTextFontSize then
			print("Restored ",key, " unitTextFontSize value from defaults")
			MinUIConfig.frames[key].unitTextFontSize = MinUIConfigDefaults.frames[key].unitTextFontSize
		end
		if not MinUIConfig.frames[key].comboPointsBarHeight then
			print("Restored ",key, " comboPointsBarHeight value from defaults")
			MinUIConfig.frames[key].comboPointsBarHeight = MinUIConfigDefaults.frames[key].comboPointsBarHeight
		end
		if not MinUIConfig.frames[key].mageChargeBarHeight then
			print("Restored ",key, " mageChargeBarHeight value from defaults")
			MinUIConfig.frames[key].mageChargeBarHeight = MinUIConfigDefaults.frames[key].mageChargeBarHeight
		end
		if not MinUIConfig.frames[key].mageChargeFontSize then
			print("Restored ",key, " mageChargeFontSize value from defaults")
			MinUIConfig.frames[key].mageChargeFontSize = MinUIConfigDefaults.frames[key].mageChargeFontSize
		end
		if not MinUIConfig.frames[key].itemOffset then
			print("Restored ",key, " itemOffset value from defaults")
			MinUIConfig.frames[key].itemOffset = MinUIConfigDefaults.frames[key].itemOffset
		end	
		if not MinUIConfig.frames[key].bars then
			print("Restored ",key, " bars from defaults")
			MinUIConfig.frames[key].bars = MinUIConfigDefaults.frames[key].bars
		end		
		if not MinUIConfig.frames[key].texts then
			print("Restored ",key, " texts from defaults")
			MinUIConfig.frames[key].texts = MinUIConfigDefaults.frames[key].texts
		end	
		if not MinUIConfig.frames[key].buffLocation then
			print("Restored ",key, " buffLocation value from defaults")
			MinUIConfig.frames[key].buffLocation = MinUIConfigDefaults.frames[key].buffLocation
		end	
		if not MinUIConfig.frames[key].debuffLocation then
			print("Restored ",key, " debuffLocation value from defaults")
			MinUIConfig.frames[key].debuffLocation = MinUIConfigDefaults.frames[key].debuffLocation
		end	
		if not MinUIConfig.frames[key].buffVisibilityOptions then
			print("Restored ",key, " buffVisibilityOptions value from defaults")
			MinUIConfig.frames[key].buffVisibilityOptions = MinUIConfigDefaults.frames[key].buffVisibilityOptions
		end	
		if not MinUIConfig.frames[key].debuffVisibilityOptions then
			print("Restored ",key, " debuffVisibilityOptions value from defaults")
			MinUIConfig.frames[key].debuffVisibilityOptions = MinUIConfigDefaults.frames[key].debuffVisibilityOptions
		end	
		if not MinUIConfig.frames[key].buffThreshold then
			print("Restored ",key, " buffThreshold value from defaults")
			MinUIConfig.frames[key].buffThreshold = MinUIConfigDefaults.frames[key].buffThreshold
		end	
		if not MinUIConfig.frames[key].debuffThreshold then
			print("Restored ",key, " debuffThreshold value from defaults")
			MinUIConfig.frames[key].debuffThreshold = MinUIConfigDefaults.frames[key].debuffThreshold
		end		
		if not MinUIConfig.frames[key].buffsMax then
			print("Restored ",key, " buffsMax value from defaults")
			MinUIConfig.frames[key].buffsMax = MinUIConfigDefaults.frames[key].buffsMax
		end	
		if not MinUIConfig.frames[key].debuffsMax then
			print("Restored ",key, " debuffsMax value from defaults")
			MinUIConfig.frames[key].debuffsMax = MinUIConfigDefaults.frames[key].debuffsMax
		end	
		
		if not MinUIConfig.frames[key].castbar then
			print("Restored ",key, " castbar value from defaults")
			MinUIConfig.frames[key].castbar = MinUIConfigDefaults.frames[key].castbar
		end	
		
		if not MinUIConfig.frames[key].buffView then
			print("Restored ",key, " buffView value from defaults")
			MinUIConfig.frames[key].buffView = MinUIConfigDefaults.frames[key].buffView
		end	
		
		if not MinUIConfig.frames[key].debuffView then
			print("Restored ",key, " debuffView value from defaults")
			MinUIConfig.frames[key].debuffView = MinUIConfigDefaults.frames[key].debuffView
		end
	end
	
	debugPrint("saved variables loaded")
end


--
-- Unit's Available - Use this to check when the player frame / pet frame is available for inspection
-- This should help overcome issues with buggy pets
--
local function unitAvailable ( unitIDs )
	local frameUnitID = -1
	
	if (MinUI.initialised == false) then
		-- initially we only care about the player's details being available,
		-- once this unit signals that it is available we can create the unit frames
		frameUnitID = Inspect.Unit.Lookup("player") 
		for unitID, value in pairs(unitIDs) do
			if ( unitID == frameUnitID ) then
				debugPrint("Player available for inspection.")
				
				getPlayerDetails()
				createUnitFrames()
				
				MinUI.initialised = true
				
				-- initialise all of the frames
				for unitName, unitFrame in pairs(MinUI.unitFrames) do
					unitFrame:unitChanged()
				end
			end
		end
	else
		-- use this for when a frame's detail's become available that may have been 
		-- unavailable on unit change, zone change, death, out of range, etc
		-- just call unitChanged on the frame again and it shuold update nicely
		for unitName, unitFrame in pairs (MinUI.unitFrames) do
			frameUnitID = Inspect.Unit.Lookup(unitName) 
			for unitID, value in pairs(unitIDs) do
				if ( unitID == frameUnitID ) then
					debugPrint(unitName, " available for inspection.")
					
					-- refresh the unit frame
					for unitName, unitFrame in pairs(MinUI.unitFrames) do
						unitFrame:refreshUnitFrame()
					end
				end
			end
		end
	end
end


--
-- Update the health values of the unitIDs who we have frames for
--
local function updateHealthValues ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose health value just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's health value just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating health values on ", unitName)
					unitFrame:updateHealth()
				end
			end
		end
	end
end

--
-- Update the power values of the unitIDs who we have frames for
--
local function updatePowerValues ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose power value just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's power value just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating power values on ", unitName)
					unitFrame:updatePower()
				end
			end
		end
	end
end

--
-- Update the mana values of the unitIDs who we have frames for
--
local function updateManaValues ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose mana value just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's mana value just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating mana values on ", unitName)
					unitFrame:updateMana()
				end
			end
		end
	end
end

--
-- Update the mana values of the unitIDs who we have frames for
--
local function updateEnergyValues ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose energy value just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's energy value just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating energy values on ", unitName)
					unitFrame:updateEnergy()
				end
			end
		end
	end
end

--
-- Update the charge values on any of the frames (taken from "player" unit always)
--
local function updateChargeValues ()
	debugPrint("updating charge values")
	
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		unitFrame:updateCharge()
	end
end

--
-- Update the combo points values on any of the frames (taken from "player" unit always)
--
local function updateComboPointsValues()
	debugPrint("updating combo points values")
			
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		unitFrame:updateComboPoints()
	end
end

--
-- Update Unit Level
--
local function updateUnitLevel( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose level just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's level just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating level on ", unitName)
					unitFrame:updateTexts() -- TODO more granular approach to updating textual items (each their own thing)
				end
			end
		end
	end
end

--
-- Update Unit Guild
--
local function updateUnitGuild ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose guild just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's guild just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating guild on ", unitName)
					unitFrame:updateTexts() -- TODO more granular approach to updating textual items (each their own thing)
				end
			end
		end
	end
end


--
-- Update Unit Role
--
local function updateUnitRole ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose role just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's role just update?
				if ( unitID == frameUnitID ) then
					debugPrint("updating role on ", unitName)
					unitFrame:updateIcons() -- TODO more granular approach to updating textual items (each their own thing)
				end
			end
		end
	end
end

--
-- Update Player Planar Charges
--
local function updatePlanarValue ( )
	if(MinUI.unitFrames["player"])then
		MinUI.unitFrames["player"]:updateTexts() -- TODO: again this should eventually be more granular for each text item
	end
end

--
-- Update Player Vitality
--
local function updateVitalityValue ( )
	if(MinUI.unitFrames["player"])then
		MinUI.unitFrames["player"]:updateTexts() -- TODO: again this should eventually be more granular for each text item
	end
end

--
-- Add the Buffs/Debuffs on the given unitID
--
local function addBuffs ( unitID, buffs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Did this unit have a buff that just changed?
			if ( unitID == frameUnitID ) then
				for buff,value in pairs(buffs) do
					unitFrame:addBuff( buff, Inspect.Time.Frame() )
				end
			end
		end
	end	
end

--
-- Remove the Buffs/Debuffs on the given unitID
--
local function removeBuffs ( unitID, buffs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Did this unit have a buff that just changed?
			if ( unitID == frameUnitID ) then
				for buff,value in pairs(buffs) do
					unitFrame:removeBuff( buff, Inspect.Time.Frame() )
				end
			end
		end
	end	
end

--
-- Change the Buffs/Debuffs on the given unitID
--
local function changeBuffs ( unitID, buffs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Did this unit have a buff that just changed?
			if ( unitID == frameUnitID ) then
				for buff,value in pairs(buffs) do
					unitFrame:changeBuff( buff, Inspect.Time.Frame() )
				end
			end
		end
	end	
end


--
-- Update castbars
--
local function updateCastbars ( unitIDs )
	local frameUnitID = -1
	
	--
	-- For all of our unitFrames
	--
	for unitName,unitFrame in pairs (MinUI.unitFrames) do
		-- Get the ID of the unit represented by the unitFrame
		frameUnitID = Inspect.Unit.Lookup(unitName)
		-- If the frame is currently representing a unit
		if(frameUnitID)then
			-- Cycle through the unitIDs of unit's whose castbar value just updated
			for unitID, value in pairs (unitIDs) do
				-- Did this frame's castbar value just change?
				if ( unitID == frameUnitID ) then
					debugPrint("updating casting on ", unitName, value)
					unitFrame:updateCastbar( value )
				end
			end
		end
	end
end

--
-- Addon finished loading
--
local function addonLoaded( addon )
	if(addon == "MinUI")then
		print("Loaded ["..MinUI.version.."]. Type /mui for help.")
		table.insert(Event.System.Update.Begin, {animate, "MinUI", "MinUI Animation Loop"})
	end
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
	
	-- Saved Variables Loaded
	table.insert(Event.Addon.SavedVariables.Load.End, { variablesLoaded, "MinUI", "variables loaded" })
	
	-- Saved Variables Loaded
	table.insert(Event.Addon.Load.End, { addonLoaded, "MinUI", "Addon Loaded" })
	
	-- Handle User Customisation
	table.insert(Command.Slash.Register("mui"), {muiCommandInterface, "MinUI", "Slash command"})

	-- Secure Mode Enter/Leave
	table.insert(Event.System.Secure.Enter, {enterSecureMode, "MinUI", "Entering combat/secure mode"})
	table.insert(Event.System.Secure.Leave, {leaveSecureMode, "MinUI", "Leaving combat/secure mode"})

	--
	-- Unit Frame Events
	--
	
	--
	-- Unit Available - check for the player unit frame being avaialbe for inspection
	--
	table.insert(Event.Unit.Available, {unitAvailable, "MinUI", "MinUI unitAvailable"})
	
	--
	-- Unit Changes
	--
	table.insert(Event.Unit.Detail.Health, { updateHealthValues, "MinUI", "MinUI updateHealthValues"})
	table.insert(Event.Unit.Detail.HealthMax, { updateHealthValues, "MinUI", "MinUI updateHealthValues"})
	table.insert(Event.Unit.Detail.Mana, { updateManaValues, "MinUI", "MinUI updateManaValues"})
	table.insert(Event.Unit.Detail.ManaMax, { updateManaValues, "MinUI", "MinUI updateManaMaxValues"})
	table.insert(Event.Unit.Detail.Power, { updatePowerValues, "MinUI", "MinUI updatePowerValues"})
	table.insert(Event.Unit.Detail.Energy, { updateEnergyValues, "MinUI", "MinUI updateEnergyValues"})
	table.insert(Event.Unit.Detail.EnergyMax, { updateEnergyValues, "MinUI", "MinUI updateEnergyMaxValues"})
	
	--
	-- Player Only Events
	--
	table.insert(Event.Unit.Detail.Combo, { updateComboPointsValues, "MinUI", "MinUI updateComboPointsValues"})
	table.insert(Event.Unit.Detail.ComboUnit, { updateComboPointsValues, "MinUI", "MinUI updateComboPointsValues"})
	table.insert(Event.Unit.Detail.Charge, { updateChargeValues, "MinUI", "MinUI updateChargeValues"})
	table.insert(Event.Unit.Detail.Planar, { updatePlanarValue, "MinUI", "MinUI updatePlanarValue"}) 
	table.insert(Event.Unit.Detail.Vitality, { updateVitalityValue, "MinUI", "MinUI updateVitalityValue"})  
	
	--
	-- Other Events
	--
	table.insert(Event.Unit.Detail.Level, { updateUnitLevel, "MinUI", "MinUI updateUnitLevel"})
	table.insert(Event.Unit.Detail.Guild, { updateUnitGuild, "MinUI", "MinUI updateUnitGuild"})
	table.insert(Event.Unit.Detail.Role, { updateUnitRole, "MinUI", "MinUI updateUnitRole" })
	-- TODO: pvp
	-- TODO: warfront
	-- others.
	
	--
	-- Buffs/Debuffs
	--
	table.insert(Event.Buff.Add, { addBuffs, "MinUI", "MinUI addBuffs"})
	table.insert(Event.Buff.Change, { changeBuffs, "MinUI", "MinUI changeBuffs"})
	table.insert(Event.Buff.Remove, { removeBuffs, "MinUI", "MinUI removeBuffs"})
	
	--
	-- Casting
	--
	table.insert(Event.Unit.Castbar, { updateCastbars, "MinUI", "MinUI updateCastbars"})
	
			
	--local group01 = UnitFrame.new( "group01", 50,50, MinUI.context, 10, 500 )
	--group01:enableBar(1, "health")
	--group01:createEnabledBars()
	--group01:unitChanged()
	
end

-- Start the UnitFrame
startup()


