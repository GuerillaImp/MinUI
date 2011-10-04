--
-- MinUI UnitFrames by Grantus
--

--[[
*TODO*
	* Add Vitality Number
	* Add Planar Charge Number
]]


-----------------------------------------------------------------------------------------------------------------------------
--
-- MinUI Global Settings/Values
--
----------------------------------------------------------------------------------------------------------------------------- 
MinUI = {}

MinUI.context = UI.CreateContext("MinUIContext")

-- Unit Frames
MinUI.frames = {}

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
-- Target Changed
--[[
local function targetChanged()
	--print("Target Changed")
	
	-- Update Player's Target/Target's Target
	for unitName, unitFrame in pairs(MinUI.frames) do
		if (unitName == "player.target") then
			unitFrame:update()
		elseif (unitName == "player.target.target") then
			unitFrame:update()
		end
	end
end]]

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
-- Based on Config (Eventually) create desired frames
--
local function createUnitFrames()
	debugPrint("Create Unit Frames")
	--
	local playerFrame = UnitFrame.new( "player", 260, 40, MinUI.context, 500,500 )
	playerFrame:setUFrameCalling(MinUI.playerCalling)
	playerFrame:enableBar( 1, "health" )
	playerFrame:enableBar( 2, "resources" )
	-- If we Have a Warrior
	if ( MinUI.playerCalling == "warrior" ) then
		playerFrame:enableBar( 3, "comboPointsBar" )
	end
	if ( MinUI.playerCalling == "mage" ) then
		--print("creating charge bar")
		playerFrame:enableBar( 3, "charge" )
	end
	playerFrame:createEnabledBars()
	playerFrame:setUFrameVisible(true)

	local targetFrame = UnitFrame.new( "player.target", 260, 40, MinUI.context, 780,500 )
	targetFrame:enableBar( 1, "health" )
	targetFrame:enableBar( 2, "resources" )
	-- If we Have a Rogue
	if ( MinUI.playerCalling == "rogue" ) then
		targetFrame:enableBar( 3, "comboPointsBar" )
	end
	targetFrame:enableBar( 4, "text")
	targetFrame:createEnabledBars()
	targetFrame:showText ("name")
	targetFrame:showText ("level")
	targetFrame:showText ("guild")
	
	-- add buffs with 30 seconds or less duration max, by the player, that are debuffs, above
	--targetFrame:addBuffBars( "debuffs", "player", 30, "above",0,-5 )
	-- show all buffs with 30seconds or less duration max, below
	--targetFrame:addBuffBars( "buffs", "all", 30, "below",0,5 )
	
	
	local totFrame = UnitFrame.new( "player.target.target", 260, 40, MinUI.context, 1080,500 )
	totFrame:enableBar( 1, "health" )
	totFrame:enableBar( 2, "text" )
	totFrame:createEnabledBars()
	totFrame:showText ("name")
	totFrame:setUFrameVisible( false )
	
	local focusFrame = UnitFrame.new( "focus", 260, 40, MinUI.context, 1380,500 )
	focusFrame:enableBar( 1, "health" )
	focusFrame:enableBar( 2, "text" )
	focusFrame:createEnabledBars()
	focusFrame:showText ("name")
	focusFrame:setUFrameVisible( false )
	
	local petFrame = UnitFrame.new( "player.pet", 260, 40, MinUI.context, 200,500 )
	petFrame:enableBar( 1, "health" )
	petFrame:enableBar( 2, "text" )
	petFrame:createEnabledBars()
	petFrame:showText ("name")
	petFrame:setUFrameVisible( false )
	
	-- Store the frames
	MinUI.frames["player"] = playerFrame
	MinUI.frames["player.target"] = targetFrame
	MinUI.frames["player.target.target"] = totFrame
	MinUI.frames["focus"] = focusFrame
	MinUI.frames["player.pet"] = petFrame
end

--
-- Main Update Loop
--
local function update()
	-- Poll for player calling until we get one
	if (MinUI.playerCallingKnown == false) then
		getPlayerDetails()
	else
		-- Once we get the player's calling initialise the frames
		if (MinUI.initialised == false) then
			createUnitFrames()
			if(MinUI.frames["player"]) then
				MinUI.frames["player"]:update()
			end
			MinUI.resyncBuffs = true
			MinUI.initialised = true
		end
				
		-- A buff recalculation has been queued, so go ahead and recalculate.
		if MinUI.resyncBuffs then
			for unitName, unitFrame in pairs(MinUI.frames) do
				unitFrame:refreshBuffBars(Inspect.Time.Frame())
			end
			MinUI.resyncBuffs = false
		end
				
		-- update cause the unit frames to ensure they are all up to date every frame
		-- this isn't the best way of doing this but for now it will do
		for unitName, unitFrame in pairs(MinUI.frames) do
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
	--createUnitFrames()
	--
	-- event hooks
	--
	
	table.insert(Event.Ability.Target, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	
	-- Buffs
	table.insert(Event.Buff.Add, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Change, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Remove, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})

	-- Handle User Customisation
	-- table.insert(Command.Slash.Register("mui"), {muiCommandInterface, "MinUI", "Slash command"})

	-- Main Loop Event
	table.insert(Event.System.Update.Begin, {update, "MinUI", "refresh"})
end

-- Start the UnitFrame
startup()