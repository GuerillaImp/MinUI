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
-- Configuration Interface
--
local function muiCommandInterface(commandline)
	local tokenCount = 0
	local command = nil
	local unitToConfig = nil
	local refreshRequired = false
	
	-- iterate tokens in command line
	for token in string.gmatch(commandline, "[^%s]+") do
		tokenCount = tokenCount + 1
		
		-- handle commands (should always be first token)
		if(tokenCount == 1) then
			-- lock unitFrames
			if(token == "lock") then
				lockFrames()
			-- unlock unitFrames
			elseif(token == "unlock") then
				unlockFrames()
			-- reset all settings to defaults
			elseif(token == "reset") then
				reset()
				refreshRequired = true
			-- enable a frame
			elseif(token == "enable") then
				command = token
			-- disable a frame
			elseif(token == "disable") then
				command = token
			-- unknown command
			else
				printHelpText()
			end
		end
		
		-- handle frame name (second token) given to the command
		if (command) then
			if(tokenCount == 2) then
				if (command == "enable") then
					print("enabling ", token)
					if(MinUIConfig.frames[token])then
						MinUIConfig.frames[token].frameEnabled = true
						refreshRequired = true
					else
						print("unknown frame")
					end
				elseif (command == "disable") then
					print("disabling ", token)
					if(MinUIConfig.frames[token])then
						MinUIConfig.frames[token].frameEnabled = false
						refreshRequired = true
					else
						print("unknown frame")
					end
				end
			end
		end
		
		
	end
	
	if (tokenCount == 0) then
		printHelpText()
	end

		
	if(refreshRequired)then
		print("Note ReloadUI Required:\nAt the moment you will need to \"/reloadui\" to update frames. Sorry about that - fix incoming.")
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
			
			-- create buff bars
			if ( unitSavedValues.buffsEnabled == true ) then
				newFrame:addBuffBars( "buffs", unitSavedValues.buffVisibilityOptions, unitSavedValues.buffThreshold, unitSavedValues.buffLocation,0, -unitSavedValues.itemOffset )
			end
			
			-- create debuff bars
			if ( unitSavedValues.debuffsEnabled == true ) then
				newFrame:addBuffBars( "debuffs", unitSavedValues.debuffVisibilityOptions, unitSavedValues.debuffThreshold, unitSavedValues.debuffLocation,0, -unitSavedValues.itemOffset )
			end
			
			-- store the unitframe
			MinUI.unitFrames[unitName] = newFrame
		end
	end
end

--
-- Main Update Loop
--
local function update()
	-- Poll for player calling until we get one
	if (MinUI.playerCallingKnown == false) then
		getPlayerDetails()
	else
		-- Once we get the player's calling initialise the unitFrames
		if (MinUI.initialised == false) then
			createUnitFrames()
			if(MinUI.unitFrames["player"]) then
				MinUI.unitFrames["player"]:update()
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
		end
				
		-- update cause the unit unitFrames to ensure they are all up to date every frame
		-- this isn't the best way of doing this but for now it will do
		for unitName, unitFrame in pairs(MinUI.unitFrames) do
			unitFrame:update()
			unitFrame:tickBuffBars(Inspect.Time.Frame())
		end
		
		
	end
end


-----------------------------------------------------------------------------------------------------------------------------
--
-- Startup
--
-----------------------------------------------------------------------------------------------------------------------------
local function startup()
	
	
	--
	-- event hooks
	--
	
	table.insert(Event.Ability.Target, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	
	-- Buffs
	table.insert(Event.Buff.Add, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Change, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Remove, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})

	-- Handle User Customisation
	table.insert(Command.Slash.Register("mui"), {muiCommandInterface, "MinUI", "Slash command"})

	-- Main Loop Event
	--createUnitFrames()
	table.insert(Event.System.Update.Begin, {update, "MinUI", "refresh"})
end

-- Start the UnitFrame
startup()