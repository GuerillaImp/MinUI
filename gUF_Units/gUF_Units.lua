--
-- gUF_Units_Settings by Grantus
--
-- This AddOn creates and manages the standard unit frames for gUF (player, target, focus, etc)
--
--

-- all units covered by this addon
local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--
-- Unit Settings Saved Var
--
gUF_Units_Settings = nil

-- Defaults
gUF_Units_Defaults = {
	unitsEnabled = {["player"] = true, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = false,["focus"] = false},
	unitSettings = {
		["player"] = {
			x = 500,
			y = 500,
			anchor = "screen",
			modulesEnabled =  {
				[1] = "HealthBar"
			},
			moduleSettings = {
				["HealthBar"] = { 
					["width"] = 400,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "[name]",
					["rightText"] = "[healthShort] | [healthPercent]",
					["texturePath"] = gUF.bars["otravi"],
					["font"] = gUF.fonts["arial_round"],
					["fontSize"] = 20,
					["anchor"] = "frame", -- unit frame or screen
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 0
				}
			} 
		},
		["player.pet"] = {
			x = 200,
			y = 500,
			anchor = "screen",
			modulesEnabled =  {
				[1] = "HealthBar"
			},
			moduleSettings = {
				["HealthBar"] = { 
					["width"] = 600,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "[name]",
					["rightText"] = "[healthShort] | [healthPercent]",
					["texturePath"] = gUF.bars["otravi"],
					["font"] = gUF.fonts["arial_round"],
					["fontSize"] = 20,
					["anchor"] = "frame", -- unit frame or screen
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 0
				}
			} 
		},
		["player.target"] = {
			x = 1100,
			y = 500,
			anchor = "screen",
			modulesEnabled =  {
				[1] = "HealthBar"
			},
			moduleSettings = {
				["HealthBar"] = { 
					["width"] = 100,
					["height"] = 60,
					["colorMode"] = "health",
					["leftText"] = "[name]",
					["rightText"] = "[healthShort] | [healthPercent]",
					["texturePath"] = gUF.bars["otravi"],
					["font"] = gUF.fonts["arial_round"],
					["fontSize"] = 20,
					["anchor"] = "frame", -- unit frame or screen
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 0
				}
			} 
		},
		["player.target.target"] = {
			x = 500,
			y = 500,
			anchor = "screen",
			modulesEnabled =  {
				[1] = "HealthBar"
			},
			moduleSettings = {
				["HealthBar"] = { 
					["width"] = 200,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "[name]",
					["rightText"] = "[healthShort] | [healthPercent]",
					["texturePath"] = gUF.bars["otravi"],
					["font"] = gUF.fonts["arial_round"],
					["fontSize"] = 20,
					["anchor"] = "frame", -- unit frame or screen
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 0
				}
			} 
		},
		["focus"] = {
			x = 500,
			y = 500,
			anchor = "screen",
			modulesEnabled =  {
				[1] = "HealthBar"
			},
			moduleSettings = {
				["HealthBar"] = { 
					["width"] = 200,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "[name]",
					["rightText"] = "[healthShort] | [healthPercent]",
					["texturePath"] = gUF.bars["otravi"],
					["font"] = gUF.fonts["arial_round"],
					["fontSize"] = 20,
					["anchor"] = "frame", -- unit frame or screen
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 0
				}
			} 
		}
	}
}

--
-- Units Namespace
--

Units = {}
Units.initialisedUnits = {}

--
--
--
function Units:CheckSettings()
	if ( gUF_Units_Settings ) then
		print "units settings exists"
		-- check that the settings are valid
		
		-- do we have a units enabled field?
		if not (gUF_Units_Settings.unitsEnabled) then
			print ("unitsEnabled created from defaults")
			gUF_Units_Settings.unitsEnabled = gUF_Units_Defaults.unitsEnabled
		end
		-- do we have a units settings field?
		if not (gUF_Units_Settings.unitSettings) then
			print ("unitSettings created from defaults")
			gUF_Units_Settings.unitSettings = gUF_Units_Defaults.unitSettings
		end
		
		-- for each unit check we have all the appropriate fields
		for _,unitName in pairs(allUnits) do
			if not (gUF_Units_Settings.unitSettings[unitName]) then
				print ("unitSettings["..unitName.."] created from defaults")
				gUF_Units_Settings.unitSettings[unitName] = gUF_Units_Defaults.unitSettings[unitName]
			else
				if not (gUF_Units_Settings.unitSettings[unitName].x) then
					print ("unitSettings["..unitName.."].x created from defaults")
					gUF_Units_Settings.unitSettings[unitName].x = gUF_Units_Defaults.unitSettings[unitName].x
				end
				if not (gUF_Units_Settings.unitSettings[unitName].y) then
					print ("unitSettings["..unitName.."].y created from defaults")
					gUF_Units_Settings.unitSettings[unitName].y = gUF_Units_Defaults.unitSettings[unitName].y
				end
				if not (gUF_Units_Settings.unitSettings[unitName].barHeight) then
					print ("unitSettings["..unitName.."].barHeight created from defaults")
					gUF_Units_Settings.unitSettings[unitName].barHeight = gUF_Units_Defaults.unitSettings[unitName].barHeight
				end
				if not (gUF_Units_Settings.unitSettings[unitName].barWidth) then
					print ("unitSettings["..unitName.."].barWidth created from defaults")
					gUF_Units_Settings.unitSettings[unitName].barWidth = gUF_Units_Defaults.unitSettings[unitName].barWidth
				end
				if not (gUF_Units_Settings.unitSettings[unitName].barTexture) then
					print ("unitSettings["..unitName.."].barTexture created from defaults")
					gUF_Units_Settings.unitSettings[unitName].barTexture = gUF_Units_Defaults.unitSettings[unitName].barTexture
				end
				if not (gUF_Units_Settings.unitSettings[unitName].barFont) then
					print ("unitSettings["..unitName.."].barFont created from defaults")
					gUF_Units_Settings.unitSettings[unitName].barFont = gUF_Units_Defaults.unitSettings[unitName].barFont
				end
				if not (gUF_Units_Settings.unitSettings[unitName].barFontSize) then
					print ("unitSettings["..unitName.."].barFontSize created from defaults")
					gUF_Units_Settings.unitSettings[unitName].barFontSize = gUF_Units_Defaults.unitSettings[unitName].barFontSize
				end
				if not (gUF_Units_Settings.unitSettings[unitName].modulesEnabled) then
					print ("unitSettings["..unitName.."].modulesEnabled created from defaults")
					gUF_Units_Settings.unitSettings[unitName].modulesEnabled = gUF_Units_Defaults.unitSettings[unitName].modulesEnabled
				end
				if not (gUF_Units_Settings.unitSettings[unitName].moduleSettings) then
					print ("unitSettings["..unitName.."].moduleSettings created from defaults")
					gUF_Units_Settings.unitSettings[unitName].moduleSettings = gUF_Units_Defaults.unitSettings[unitName].moduleSettings
				end
				if not (gUF_Units_Settings.unitSettings[unitName].anchor) then
					print ("unitSettings["..unitName.."].anchor created from defaults")
					gUF_Units_Settings.unitSettings[unitName].anchor = gUF_Units_Defaults.unitSettings[unitName].anchor
				end
			end
		end
		
	else
		print "units settings does not exist, setting to default"
		gUF_Units_Settings = gUF_Units_Defaults
	end
end

--
--
--
function Units:Initialise()
	Units:CheckSettings()
	
	-- for each enabled unit
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
			local unitSettings = gUF_Units_Settings.unitSettings[unit]
			local unitFrame = Box.new( 5, {r=0,g=0,b=0,a=0.3}, "vertical", "down", gUF.context, -1 )
			
			-- for each enabled module on the unit
			for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modulesEnabled) do
				local moduleClass = gUF_Modules[module]
				if(moduleClass)then
					local moduleInstance = moduleClass.new( unit )
					
					local settings = gUF_Units_Settings.unitSettings[unit].moduleSettings[module]
					
					local moduleSettingsTable = moduleInstance:GetSettingsTable()
					
					
					-- initialise settings table from our Addon's saved variables
					for settingName,_ in pairs(moduleSettingsTable) do
						print ( "Setting ", settingName, " => ", settings[settingName] )
						moduleSettingsTable[settingName] = settings[settingName]
					end
					
					moduleInstance:Initialise( moduleSettingsTable )
					moduleInstance:RegisterCallbacks()
					unitFrame:AddItem(moduleInstance)
				else
					print "module does not exist"
				end
			end
			
			
			-- store the fact that this unit has been initialised (such that if we change enabled units settings later, we know not to recreate this frame)
			unitFrame.initialised = true
			Units.initialisedUnits[unit] = unitFrame
			unitFrame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", unitSettings.x, unitSettings.y )
			unitFrame:SetVisible(true)
		end
	end
end

-- Create the UnitFrames
table.insert(Event.Addon.SavedVariables.Load.End, { Units.Initialise, "gUF_Units", "gUF_Units Variables Loaded" })
-- Register with gUF for options
gUF_AddOn_Config["Units"] = Units.GetOptions