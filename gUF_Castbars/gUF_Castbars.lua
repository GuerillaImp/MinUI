--
-- gUF_Castbars by Grantus
--
-- This AddOn creates and manages the castbars for gUF (player, target, focus, etc)
--
--

-- all units covered by this addon
local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--
-- Unit Settings Saved Var
--
gUF_Castbars_Settings = nil

-- Defaults
gUF_Castbars_Defaults = {
	unitsEnabled = {["player"] = true, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = true, ["focus"] = false},
	unitSettings = {
		["player"] = {
			modules =  {
				[1] = "CastBar"
			},
			moduleSettings = {
				[1] = { -- CastBar config
					["width"] = 280,
					["height"] = 35,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["mana_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["mana_background"], -- user sets color
					["icon"] = "left", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 35,
					["leftText"] = "abilityName", -- abilityName, remainingShort/Abs, durationShort/Abs
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "screen",
					["anchorUnit"] = "player",
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 790,
					["anchorYOffset"] = 800
				}
			}
		},
		["player.target"] = {
			modules =  {
				[1] = "CastBar"
			},
			moduleSettings = {
				[1] = { -- CastBar config
					["width"] = 280,
					["height"] = 35,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["red_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["red_background"], -- user sets color
					["icon"] = "none", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 35,
					["leftText"] = "abilityName", -- abilityName, remainingShort/Abs, durationShort/Abs
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "screen",
					["anchorUnit"] = "notUsing",
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 790,
					["anchorYOffset"] = 750
				}
			}
		},
		["player.target.target"] = {
			modules =  {
				[1] = "CastBar"
			},
			moduleSettings = {
				[1] = { -- CastBar config
					["width"] = 250,
					["height"] = 25,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["red_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["red_background"], -- user sets color
					["icon"] = "none", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 25,
					["leftText"] = "abilityName", -- abilityName, remainingShort/Abs, durationShort/Abs
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "player.target.target",
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "BOTTOMLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 10
				}
			}
		},
		["player.pet"] = {
			modules =  {
				[1] = "CastBar"
			},
			moduleSettings = {
				[1] = { -- CastBar config
					["width"] = 250,
					["height"] = 25,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["red_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["red_background"], -- user sets color
					["icon"] = "none", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 25,
					["leftText"] = "abilityName", -- abilityName, remainingShort/Abs, durationShort/Abs
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "player.pet",
					["anchorPointThis"] = "TOPRIGHT",
					["anchorPointParent"] = "BOTTOMRIGHT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 10
				}
			}
		},
		["focus"] = {
			modules =  {
				[1] = "CastBar"
			},
			moduleSettings = {
				[1] = { -- CastBar config
					["width"] = 250,
					["height"] = 25,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["red_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["red_background"], -- user sets color
					["icon"] = "none", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 25,
					["leftText"] = "abilityName", -- abilityName, remainingShort/Abs, durationShort/Abs
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "focus",
					["anchorPointThis"] = "TOPRIGHT",
					["anchorPointParent"] = "BOTTOMRIGHT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 10
				}
			}
		}
	}
}


--
-- Castbars Namespace
--

Castbars = {}

--
-- TODO: Update to final settings when complete
--
function Castbars:CheckSettings()
	if ( gUF_Castbars_Settings ) then
		print "castbar settings exists"
		print "TODO: Check Settings Values From Defaults"
		
	else
		print "castbar settings do not exist, setting to default"
		gUF_Castbars_Settings = gUF_Castbars_Defaults
	end
end

--
-- Initialise the Castbars based on the Saved Settings
--
function Castbars:Initialise( addOnIdentifier )
	-- If gUF_Castbars just loaded 
	if ( addOnIdentifier == "gUF_Castbars" ) then
		Castbars:CheckSettings()
		
		--
		-- Create castbar modules
		--
		for unit,enabled in pairs(gUF_Castbars_Settings.unitsEnabled) do
			if ( enabled ) then
				-- for each enabled module on the unit
				for index,module in ipairs(gUF_Castbars_Settings.unitSettings[unit].modules) do
					local moduleClass = gUF_Modules[module]
					-- if module is registered then enable a new creation of it
					if ( moduleClass ) then
						print ( "creating ", module, " for unit " , unit )
					
						local moduleInstance = moduleClass.new( unit )
						local settings = gUF_Castbars_Settings.unitSettings[unit].moduleSettings[index]
						local moduleSettingsTable = moduleInstance:GetSettingsTable()
						
						-- initialise settings table from our Addon's saved variables
						for settingName,_ in pairs(moduleSettingsTable) do
							moduleSettingsTable[settingName] = settings[settingName]
						end
						
						moduleInstance:Initialise( moduleSettingsTable )
						moduleInstance:RegisterCallbacks()
						
						--
						-- retreive unit frame addon instance for this unit, just in case we need it for insideFrame or frame anchors
						--
						local frameAnchor = nil
						local frameInstance = nil 
						
						if (  moduleSettingsTable["anchor"] == "insideFrame" or moduleSettingsTable["anchor"] == "frame" ) then
							for _,unitFrameRegister in pairs ( gUF.initialisedFrames ) do
								-- check they belong to the gUF unitframe addon
								if ( unitFrameRegister[1] == "gUF_Units" ) then
									-- check the frame belongs to this modules "anchorUnit"
									if ( unitFrameRegister[2] == moduleSettingsTable["anchorUnit"] ) then
										-- get the unit frame instance itself, and the rift frame it contains
										frameInstance = unitFrameRegister[3]
										frameAnchor = frameInstance:GetFrame()
									end
								end
							end
						end
						
							
						-- Add Module at it's anchor location
						if ( moduleSettingsTable["anchor"] == "insideFrame" ) then
							if ( frameInstance ) then
								frameInstance:AddModule( moduleInstance )
							else
								print ("error: no frame instance to insert module inside ", unit,  module)
							end
						elseif ( moduleSettingsTable["anchor"] == "frame" ) then
							if ( frameAnchor ) then
								moduleInstance:SetPoint( moduleSettingsTable["anchorPointThis"], frameAnchor, moduleSettingsTable["anchorPointParent"], moduleSettingsTable["anchorXOffset"], moduleSettingsTable["anchorYOffset"]  )
							else
								print ("error: no frame instance to anchor this frame to -> ", unit, " to ", moduleSettingsTable["anchorUnit"])
							end
						elseif ( moduleSettingsTable["anchor"] == "screen" ) then
							moduleInstance:SetPoint( moduleSettingsTable["anchorPointThis"], gUF.context, moduleSettingsTable["anchorPointParent"], moduleSettingsTable["anchorXOffset"], moduleSettingsTable["anchorYOffset"]  )
						end
					end
				end
			end
		end
	end
end

-- Create the Castbars
table.insert(Event.Addon.SavedVariables.Load.End, { function( addOnIdentifier ) Castbars:Initialise(addOnIdentifier) end, "gUF_Castbars", "gUF_Castbars Variables Loaded" })