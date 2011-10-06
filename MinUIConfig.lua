-----------------------------------------------------------------------------------------------------------------------------
--
-- User Configuration Values
--
-----------------------------------------------------------------------------------------------------------------------------

-- Defaults
local barWidthDefault = 240
local barHeightDefault = 25
local itemOffsetDefault = 2
local comboPointsBarHeightDefault = 7
local mageChargeBarHeightDefault = 15

local barFontSizeDefault = 14
local buffFontSizeDefault = 12
local unitTextFontSizeDefault = 12
local mageChargeFontSizeDefault = 10

-- Defaults for Frame Configuration
MinUIConfigDefaults = {
	-- Frames Locked
	unitFramesLocked = true,
	globalTextFont = "arial_round",
	-- Frame Settings
	frames = {
		["player"] =
		{ 
			x = 600, -- x location 
			y = 500, -- y location 
			frameEnabled = true, -- determines if the frame is created on loading
			-- default sizes
			barWidth = barWidthDefault, -- the width of the bars 
			barHeight = barHeightDefault, -- the height of the bars
			barFontSize = barFontSizeDefault, -- the font size used on the bars
			buffFontSize = buffFontSizeDefault, -- the font size used on the buff bars
			unitTextFontSize = unitTextFontSizeDefault, -- the font size used on the unit bar
			comboPointsBarHeight = comboPointsBarHeightDefault, -- combo points bar height
			mageChargeBarHeight = mageChargeBarHeightDefault, -- mage charge bar height
			mageChargeFontSize = mageChargeFontSizeDefault, -- mage charge font size
			itemOffset = itemOffsetDefault, -- the generic spacer used
			-- enabled bars/items
			bars = { "health", "resources", "charge", "warriorComboPoints", "text" }, -- bars enabled on this frame, (can be health, resources, charge, rogueComboPoints, warriorComboPoints, text) the order here is the order they are placed on the frame left->right
			texts = { "level", "name", "planarCharges", "vitality"}, -- bars enabled on this frame, (can be level, name, planarCharges, guild, vitality, calling) the order here is currently unimportant but eventually will be as above
			-- buff/debuff settings
			buffsEnabled = true, -- true/false
			debuffsEnabled = true, -- true/false
			buffLocation = "below", -- can only be below or above at the moment
			debuffLocation = "above", -- can only be below or above at the moment
			buffVisibilityOptions = "player", -- "player" cast or "all"
			debuffVisibilityOptions = "all",-- "player" cast or "all"
			buffThreshold = 30, -- the maximum length of the buff shown on the buff bar (i.e only show buffs shorter than 30 seconds here)
			debuffThreshold = 3600 -- the maximum length of the debuff shown on the buff bar (i.e only show debuffs shorter than 1 hour here)
		},
		["player.target"] = {
			x = 1100,
			y = 500,
			frameEnabled = true,
			-- default sizes
			barWidth = barWidthDefault,
			barHeight = barHeightDefault,
			barFontSize = barFontSizeDefault,
			buffFontSize = buffFontSizeDefault,
			unitTextFontSize = unitTextFontSizeDefault,
			comboPointsBarHeight = comboPointsBarHeightDefault,
			mageChargeBarHeight = mageChargeBarHeightDefault,
			mageChargeFontSize = mageChargeFontSizeDefault,
			itemOffset = itemOffsetDefault,
			-- enabled bars/items
			bars = { "health", "resources", "rogueComboPoints", "text" }, 
			texts = { "level", "name", "guild" },
			-- buff/debuff settings
			buffsEnabled = true,
			debuffsEnabled = true,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "all",
			debuffVisibilityOptions = "player",
			buffThreshold = 30,
			debuffThreshold = 30
		},
		["player.target.target"] = {
			x = 1400,
			y = 500,
			frameEnabled = true,
			-- default sizes
			barWidth = barWidthDefault,
			barHeight = barHeightDefault,
			barFontSize = barFontSizeDefault,
			buffFontSize = buffFontSizeDefault,
			unitTextFontSize = unitTextFontSizeDefault,
			comboPointsBarHeight = comboPointsBarHeightDefault,
			mageChargeBarHeight = mageChargeBarHeightDefault,
			mageChargeFontSize = mageChargeFontSizeDefault,
			itemOffset = itemOffsetDefault,
			-- enabled bars/items
			bars = { "health", "text" }, 
			texts = { "level", "name" },
			-- buff/debuff settings
			buffsEnabled = false,
			debuffsEnabled = false,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "player",
			debuffVisibilityOptions = "player",
			buffThreshold = 30,
			debuffThreshold = 30
		},
		["focus"] = {
			x = 1400,
			y = 600,
			frameEnabled = true,
			-- default sizes
			barWidth = barWidthDefault,
			barHeight = barHeightDefault,
			barFontSize = barFontSizeDefault,
			buffFontSize = buffFontSizeDefault,
			unitTextFontSize = unitTextFontSizeDefault,
			comboPointsBarHeight = comboPointsBarHeightDefault,
			mageChargeBarHeight = mageChargeBarHeightDefault,
			mageChargeFontSize = mageChargeFontSizeDefault,
			itemOffset = itemOffsetDefault,
			-- enabled bars/items
			bars = { "health", "text" }, 
			texts = { "level", "name" },
			-- buff/debuff settings
			buffsEnabled = false,
			debuffsEnabled = false,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "player",
			debuffVisibilityOptions = "player",
			buffThreshold = 30,
			debuffThreshold = 30
		},
		["player.pet"] = {
			x = 300,
			y = 500,
			frameEnabled = true,
			-- default sizes
			barWidth = barWidthDefault,
			barHeight = barHeightDefault,
			barFontSize = barFontSizeDefault,
			buffFontSize = buffFontSizeDefault,
			unitTextFontSize = unitTextFontSizeDefault,
			comboPointsBarHeight = comboPointsBarHeightDefault,
			mageChargeBarHeight = mageChargeBarHeightDefault,
			mageChargeFontSize = mageChargeFontSizeDefault,
			itemOffset = itemOffsetDefault,
			-- enabled bars/items
			bars = { "health", "text" }, 
			texts = { "level", "name" },
			-- buff/debuff settings
			buffsEnabled = false,
			debuffsEnabled = false,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "player",
			debuffVisibilityOptions = "player",
			buffThreshold = 30,
			debuffThreshold = 30
		}
	}
}

-- Saved Frame Settings (Configured per-character through in game commands) (Set to Defaults on First Run)
MinUIConfig = MinUIConfigDefaults

--
-- lock frames
--
function lockFrames()
	print("Frames locked")
	MinUIConfig.unitFramesLocked = true
end

--
-- unlock frames
--
function unlockFrames()
	print("Frames unLlcked")
	MinUIConfig.unitFramesLocked = false
end

--
-- reset everything to default
--
function reset()
	print("Restoring factory default settings ;)")
	MinUIConfig = MinUIConfigDefaults
end

--
-- show current settings for the given frame
--
function showCurrentSettings(unitFrame)
	if(MinUIConfig.frames[unitFrame]) then
		print("*** Settings for ", unitFrame)
		print("x: ", MinUIConfig.frames[unitFrame].x)
		print("y: ", MinUIConfig.frames[unitFrame].y)
		print("itemOffset: ", MinUIConfig.frames[unitFrame].itemOffset)
		print("enabled?: ", MinUIConfig.frames[unitFrame].frameEnabled)
		print("barWidth: ", MinUIConfig.frames[unitFrame].barWidth)
		print("barHeight: ", MinUIConfig.frames[unitFrame].barHeight)
		print("comboPointsBarHeight: ", MinUIConfig.frames[unitFrame].comboPointsBarHeight)
		print("mageChargeBarHeight: ", MinUIConfig.frames[unitFrame].mageChargeBarHeight)

		for position, bar in pairs(MinUIConfig.frames[unitFrame].bars) do
			print ("Bar ", bar, " enabled in position ", position)
		end		
		
		for _, text in pairs(MinUIConfig.frames[unitFrame].texts) do
			print("Unit Text ", text, " enabled")
		end
		print("unitTextPosition: ", MinUIConfig.frames[unitFrame].unitTextPosition)
		
		print("buffLocation: ", MinUIConfig.frames[unitFrame].buffLocation)
		print("buffVisibilityOptions: ", MinUIConfig.frames[unitFrame].buffVisibilityOptions)
		print("debuffVisibilityOptions: ", MinUIConfig.frames[unitFrame].debuffVisibilityOptions)
		print("buffThreshold: ", MinUIConfig.frames[unitFrame].buffThreshold)
		print("debuffThreshold: ", MinUIConfig.frames[unitFrame].debuffThreshold)
	else
		print "??? unknown frame name"
	end
end
