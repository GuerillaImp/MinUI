-----------------------------------------------------------------------------------------------------------------------------
--
-- User Configuration Values
--
-----------------------------------------------------------------------------------------------------------------------------

-- Defaults
local barWidthDefault = 250
local barHeightDefault = 20
local itemOffsetDefault = 5
local comboPointsBarHeightDefault = 7
local mageChargeBarHeightDefault = 15

-- Defaults for Frame Configuration
MinUIConfigDefaults = {
	unitFrameBarWidth = barWidthDefault,
	unitFrameBarHeight = barHeightDefault,
	unitFrameOffset = itemOffsetDefault,
	comboPointsBarHeight = comboPointsBarHeightDefault,
	mageChargeBarHeight = mageChargeBarHeightDefault,
	showComboBox = false,
	unitFramesLocked = true,
	-- frames configured to show player cast debuffs
	showPlayerDebuffsOnly = { ["player"] = false, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = false  },
	-- frames configured to show all debuffs
	showAllDebuffs = { ["player"] = true, ["player.pet"] = false, ["player.target"] = false, ["player.target.target"] = false  },
	-- frames configured to show all buffs
	showAllBuffs = { ["player"] = false, ["player.pet"] = false, ["player.target"] = false, ["player.target.target"] = false  },
	-- frames configured to show player buffs only
	showPlayerBuffsOnly = { ["player"] = false, ["player.pet"] = false, ["player.target"] = false, ["player.target.target"] = false  },
	-- configuration for what bars are shown on what unit frame
	showHealthBar = { ["player"] = true, ["player.pet"] = true, ["player.target"] = true, ["player.target.target"] = true },
	showPowerBar = { ["player"] = true, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = false }, 
	showUnitText = { ["player"] = false, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = true },
	-- NEW WAY: Store Everything Under a Frame
	-- Going to be much better this way
	frames = {
		["player"] =
		{ 
			frameEnabled = true,
			-- default sizes
			barWidth = barWidthDefault,
			barHeight = barHeightDefault,
			comboPointsBarHeight = comboPointsBarHeightDefault,
			mageChargeBarHeight = mageChargeBarHeightDefault,
			itemOffset = itemOffsetDefault,
			-- enabled bars/items
			showHealthBar = true,
			showPowerBar = true,
			showUnitText = false,
			showRogueComboPointsBox = false,
			showRogueComboPointsBar = false,
			showMageChargeBar = false,
			showWarriorComboPointsBar = false,
			showWarriorComboPointsBox = false,
			-- buff settings
			buffLocation = "below",
			debuffLocation = "above",
			showAllDebufs = true,
			showAllBuffs = false,
			showPlayerDebuffsOnly = false,
			showPlayerBuffsOnly = false, 
			showShortDebuffsOnly = false,
			showShortBuffsOnly = false
		},
		["player.focus"] = {},
		["player.pet"] = {},
		["player.target"] = {},
		["player.target.target"] = {},
	}
}

-- Default Placement
MinUIFramePlacementDefaults = {
	["player"] = {x = 10, y = 450},
	["player.pet"] = {x = 10, y = 570},
	["player.target"] = {x = 280, y = 450},
	["player.target.target"] = {x = 550, y = 450}
}

-- Saved Frame Settings (Configured per-character through in game commands) (Set to Defaults on First Run)
MinUIConfig = MinUIConfigDefaults

-- Saved Frame Placement Values (Configured per-character by dragging the frames around) (Set to Defaults on First Run)
MinUIFramePlacement = MinUIFramePlacementDefaults

--
-- lock frames
--
function lockFrames()
	print("Frames Locked")
	MinUIConfig.unitFramesLocked = true
end

--
-- unlock frames
--
function unlockFrames()
	print("Frames UnLocked")
	MinUIConfig.unitFramesLocked = false
end

--
-- reset frame layout
--
function resetUnitFrameLayout()
	print("Frames Reset")
	MinUIFramePlacement = MinUIFramePlacementDefaults
	print("type /reloadui")
end

--
-- reset everything to default
--
function resetAll()
	print("Resetting All")
	MinUIConfig = MinUIConfigDefaults
	MinUIFramePlacement = MinUIFramePlacementDefaults
	print("type /reloadui")
end

--
-- show current settings for the given frame
--
function showCurrentSettings(unitFrame)
	if(MinUIConfig.frames[unitFrame]) then
		print("*** Settings for ", unitFrame)
		print("frameEnabled: ", MinUIConfig.frames[unitFrame].frameEnabled)
		print("barHeight: ", MinUIConfig.frames[unitFrame].barHeight)
		print("barWidth: ", MinUIConfig.frames[unitFrame].barWidth)
		print("comboPointsBarHeight: ", MinUIConfig.frames[unitFrame].comboPointsBarHeight)
		print("mageChargeBarHeight: ", MinUIConfig.frames[unitFrame].mageChargeBarHeight)
		print("itemOffset: ", MinUIConfig.frames[unitFrame].itemOffset)
		print("showHealthBar: ", MinUIConfig.frames[unitFrame].showHealthBar)
		print("showPowerBar: ", MinUIConfig.frames[unitFrame].showPowerBar)
		print("showUnitText: ", MinUIConfig.frames[unitFrame].showUnitText)
		print("showRogueComboPointsBox: ", MinUIConfig.frames[unitFrame].showRogueComboPointsBox)
		print("showRogueComboPointsBar: ", MinUIConfig.frames[unitFrame].showRogueComboPointsBar)
		print("showMageChargeBar: ", MinUIConfig.frames[unitFrame].showMageChargeBar)
		print("showWarriorComboPointsBar: ", MinUIConfig.frames[unitFrame].showWarriorComboPointsBar)
		print("showWarriorComboPointsBox: ", MinUIConfig.frames[unitFrame].showWarriorComboPointsBox)
		print("buffLocation: ", MinUIConfig.frames[unitFrame].buffLocation)
		print("debuffLocation: ", MinUIConfig.frames[unitFrame].debuffLocation)
		print("showAllDebufs: ", MinUIConfig.frames[unitFrame].showAllDebufs)
		print("showAllBuffs: ", MinUIConfig.frames[unitFrame].showAllBuffs)
		print("showPlayerDebuffsOnly: ", MinUIConfig.frames[unitFrame].showPlayerDebuffsOnly)
		print("showPlayerBuffsOnly: ", MinUIConfig.frames[unitFrame].showPlayerBuffsOnly)
		print("showShortDebuffsOnly: ", MinUIConfig.frames[unitFrame].showShortDebuffsOnly)
		print("showShortBuffsOnly: ", MinUIConfig.frames[unitFrame].showShortBuffsOnly)
	else
		print "??? unknown frame name"
	end
end
