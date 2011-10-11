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
	-- Global Text Font
	globalTextFont = "arial_round",
	-- Global Texture
	barTexture = "minimalist",
	-- Background Color
	backgroundColor = {r=0,g=0,b=0,a=0.9},
	-- Frame Settings
	frames = {
		["player"] =
		{ 
			x = 600, -- x location 
			y = 500, -- y location
			scale = 1.0, -- frame scale
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
			texts = { "level", "name", "planar", "vitality"}, -- bars enabled on this frame, (can be level, name, planar, guild, vitality, calling) the order here is currently unimportant but eventually will be as above
			-- buff/debuff settings
			buffsEnabled = true, -- true/false
			debuffsEnabled = true, -- true/false
			buffsMax = 10, -- max number of buffs/debuffs
			debuffsMax = 10,
			buffLocation = "above", -- can only be below or above at the moment
			debuffLocation = "above", -- can only be below or above at the moment
			buffVisibilityOptions = "all", -- "player" cast or "all"
			debuffVisibilityOptions = "all",-- "player" cast or "all"
			buffThreshold = 9000, -- the maximum length of the buff shown on the buff bar (i.e only show buffs shorter than 9000 seconds here)
			debuffThreshold = 9000, -- the maximum length of the debuff shown on the buff bar (i.e only show debuffs shorter than 1 hour here)
			debuffAuras = true, -- debuff auras? (i.e. no duration buffs)
			buffAuras = true -- buff auras?
		},
		["player.target"] = {
			x = 1100,
			y = 500,
			scale = 1.0,
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
			buffsMax = 10,
			debuffsMax = 10,
			buffLocation = "above",
			debuffLocation = "above",
			buffVisibilityOptions = "all",
			debuffVisibilityOptions = "all",
			buffThreshold = 9000,
			debuffThreshold = 9000,
			debuffAuras = true, -- debuff auras? (i.e. no duration buffs)
			buffAuras = true -- buff auras?
		},
		["player.target.target"] = {
			x = 1400,
			y = 500,
			scale = 1.0, 
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
			buffsMax = 10,
			debuffsMax = 10,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "all",
			debuffVisibilityOptions = "all",
			buffThreshold = 9000,
			debuffThreshold = 9000,
			debuffAuras = true, -- debuff auras? (i.e. no duration buffs)
			buffAuras = true -- buff auras?
		},
		["focus"] = {
			x = 1400,
			y = 600,
			scale = 1.0, 
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
			buffsMax = 10,
			debuffsMax = 10,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "all",
			debuffVisibilityOptions = "all",
			buffThreshold = 9000,
			debuffThreshold = 9000,
			debuffAuras = true, -- debuff auras? (i.e. no duration buffs)
			buffAuras = true -- buff auras?
		},
		["player.pet"] = {
			x = 300,
			y = 500,
			scale = 1.0,
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
			buffsMax = 10,
			debuffsMax = 10,
			buffLocation = "below",
			debuffLocation = "above",
			buffVisibilityOptions = "all",
			debuffVisibilityOptions = "all",
			buffThreshold = 9000,
			debuffThreshold = 9000,
			debuffAuras = true, -- debuff auras? (i.e. no duration buffs)
			buffAuras = true -- buff auras?
		}
	}
}

-- Saved Frame Settings (Configured per-character through in game commands) (Set to Defaults on First Run)
MinUIConfig = MinUIConfigDefaults

--
-- lock frames
--
function lockFrames()
	debugPrint("Frames locked")
	MinUIConfig.unitFramesLocked = true
end

--
-- unlock frames
--
function unlockFrames()
	debugPrint("Frames unlocked")
	MinUIConfig.unitFramesLocked = false
end

--
-- reset everything to default
--
function reset()
	debugPrint("Restoring factory default settings ;)")
	MinUIConfig = MinUIConfigDefaults
end

function showGlobalSettings()

	print ("*** global settings")
	
	print ("unitFramesLocked? ", MinUIConfig.unitFramesLocked)

	print ("globalTextFont: ", MinUIConfig.globalTextFont)

	print ("barTexture: ", MinUIConfig.barTexture)

	print ("backgroundColor: ", MinUIConfig.backgroundColor.r,MinUIConfig.backgroundColor.g,MinUIConfig.backgroundColor.b,MinUIConfig.backgroundColor.a)

end

--
-- show current settings for the given frame
--
function showCurrentSettings(unitFrame)
	if(MinUIConfig.frames[unitFrame]) then
		debugPrint("*** Settings for ", unitFrame)
		debugPrint("x: ", MinUIConfig.frames[unitFrame].x)
		debugPrint("y: ", MinUIConfig.frames[unitFrame].y)
		debugPrint("scale: ", MinUIConfig.frames[unitFrame].scale)
		debugPrint("itemOffset: ", MinUIConfig.frames[unitFrame].itemOffset)
		debugPrint("enabled?: ", MinUIConfig.frames[unitFrame].frameEnabled)
		debugPrint("barWidth: ", MinUIConfig.frames[unitFrame].barWidth)
		debugPrint("barHeight: ", MinUIConfig.frames[unitFrame].barHeight)
		debugPrint("comboPointsBarHeight: ", MinUIConfig.frames[unitFrame].comboPointsBarHeight)
		debugPrint("mageChargeBarHeight: ", MinUIConfig.frames[unitFrame].mageChargeBarHeight)

		for position, bar in pairs(MinUIConfig.frames[unitFrame].bars) do
			debugPrint ("Bar ", bar, " enabled in position ", position)
		end		
		
		for _, text in pairs(MinUIConfig.frames[unitFrame].texts) do
			debugPrint("Unit Text ", text, " enabled")
		end
		debugPrint("unitTextPosition: ", MinUIConfig.frames[unitFrame].unitTextPosition)
		
		debugPrint("buffLocation: ", MinUIConfig.frames[unitFrame].buffLocation)
		debugPrint("buffVisibilityOptions: ", MinUIConfig.frames[unitFrame].buffVisibilityOptions)
		debugPrint("debuffVisibilityOptions: ", MinUIConfig.frames[unitFrame].debuffVisibilityOptions)
		debugPrint("buffThreshold: ", MinUIConfig.frames[unitFrame].buffThreshold)
		debugPrint("debuffThreshold: ", MinUIConfig.frames[unitFrame].debuffThreshold)
	else
		debugPrint "??? unknown frame name"
	end
end
