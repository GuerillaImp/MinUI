--
-- gUF_Buffs by Grantus
--
-- This AddOn creates and manages the BuffBars for gUF (player, target, focus, etc)
--
--

-- all units covered by this addon
local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--
-- Unit Settings Saved Var
--
gUF_Buffs_Settings = nil

-- Defaults
gUF_Buffs_Defaults = {
	unitsEnabled = {["player"] = true, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = false, ["focus"] = false},
	unitSettings = {
		["player"] = {
			modules =  {
				[1] = "BuffBar"
			},
			moduleSettings = {
				[1] = { -- buffbar config
					["width"] = 252,
					["height"] = 15,
					["padding"] = 1,
					["leftText"] = "buffName",
					["rightText"] = "remainingShort",
					["texturePath"] = gUF_Bars["eya02"],
					["whitelist"] = {},
					["blacklist"] = {},
					["frameBGColor"] = {r=1,g=1,b=1,a=1},
					["icon"] = "left", -- left, right, none
					["iconSize"] = 15,
					["maxBuffs"] = 20,
					["growthDirection"] = "down", --up/down
					["filterMode"] = "blacklist", -- whitelist/blacklist
					["buffMode"] = "all", -- buff/debuff/all
					["visibilityOptions"] = "all", -- player/all
					["timeThreshold"] = 9000, -- max seconds of buff to show
					["font"] = gUF_Fonts["arial_round"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "player",
					["anchorPointThis"] = "TOPRIGHT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = -10,
					["anchorYOffset"] = 0
				}
			}
		},
		["player.target"] = {
			modules =  {
				[1] = "BuffBar"
			},
			moduleSettings = {
				[1] = { -- buffbar config
					["width"] = 236,
					["height"] = 15,
					["padding"] = 1,
					["leftText"] = "buffName",
					["rightText"] = "remainingShort",
					["texturePath"] = gUF_Bars["eya02"],
					["whitelist"] = {},
					["blacklist"] = {},
					["frameBGColor"] = gUF_Colors["black"],
					["icon"] = "right", -- left, right, none
					["iconSize"] = 15,
					["maxBuffs"] = 20,
					["growthDirection"] = "up", --up/down
					["filterMode"] = "blacklist", -- whitelist/blacklist
					["buffMode"] = "all", -- buff/debuff/all
					["visibilityOptions"] = "all", -- player/all
					["timeThreshold"] = 9000, -- max seconds of buff to show
					["font"] = gUF_Fonts["arial_round"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "player.target",
					["anchorPointThis"] = "BOTTOMLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = -30
				}
			}
		},
		["player.target.target"] = {
			modules =  {

			},
			moduleSettings = {
				
			}
		},
		["player.pet"] = {
			modules =  {
			},
			moduleSettings = {
				
			}
		},
		["focus"] = {
			modules =  {
			
			},
			moduleSettings = {
				
			}
		}
	}
}


--
-- BuffBars Namespace
--

BuffBars = {}

--
-- TODO: Update to final settings when complete
--
function BuffBars:CheckSettings()
	if ( gUF_Buffs_Settings ) then
		print "buffbar settings exists"
		print "TODO: Check Settings Values From Defaults"
		
	else
		print "buffbar settings do not exist, setting to default"
		gUF_Buffs_Settings = gUF_Buffs_Defaults
	end
end

--
-- Initialise the BuffBars based on the Saved Settings
--
function BuffBars:Initialise( addOnIdentifier )
	-- If gUF_Buffs just loaded 
	if ( addOnIdentifier == "gUF_Buffs" ) then
		BuffBars:CheckSettings()
		
		--
		-- Create buffbar modules
		--
		for unit,enabled in pairs(gUF_Buffs_Settings.unitsEnabled) do
			if ( enabled ) then
				-- for each enabled module on the unit
				for index,module in ipairs(gUF_Buffs_Settings.unitSettings[unit].modules) do
					local moduleClass = gUF_Modules[module]
					-- if module is registered then enable a new creation of it
					if ( moduleClass ) then
						print ( "creating ", module, " for unit " , unit )
					
						local moduleInstance = moduleClass.new( unit )
						local settings = gUF_Buffs_Settings.unitSettings[unit].moduleSettings[index]
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

-- Create the BuffBars
table.insert(Event.Addon.SavedVariables.Load.End, { function( addOnIdentifier ) BuffBars:Initialise(addOnIdentifier) end, "gUF_Buffs", "gUF_Buffs Variables Loaded" })