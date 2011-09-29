-----------------------------------------------------------------------------------------------------------------------------
--
-- User Configuration Values
--
-----------------------------------------------------------------------------------------------------------------------------

-- Default Frame Settings (Can be configured per-character through in game commands kinda)
MinUIConfig = {
	unitFrameBarWidth = 250,
	unitFrameBarHeight = 25,
	unitFrameOffset = 2,
	comboPointsBarHeight = 5,
	mageChargeBarHeight = 15,
	-- frames configured to show player cast debuffs
	showPlayerDebuffsOnly = { ["player"] = false, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = false  },
	-- frames configured to show all debuffs
	showAllDebuffs = { ["player"] = true, ["player.pet"] = false, ["player.target"] = false, ["player.target.target"] = false  },
	-- frames configured to show all buffs
	showAllBuffs = { ["player"] = false, ["player.pet"] = false, ["player.target"] = false, ["player.target.target"] = false  },
	-- frames configured to show player buffs only
	showPlayerBuffsOnly = { ["player"] = false, ["player.pet"] = false, ["player.target"] = false, ["player.target.target"] = false  }
}

-- Default Frame Placement Values (Can be configured per-character by dragging the frames around)
MinUIFramePlacement = {
	["player"] = {x = 10, y = 450},
	["player.pet"] = {x = 10, y = 570},
	["player.target"] = {x = 280, y = 450},
	["player.target.target"] = {x = 550, y = 450}
}
	