--
-- gUF_CallingModules by Grantus
--
-- This AddOn creates and manages the CallingModules for gUF (player, target, focus, etc)
--
--

-- all units covered by this addon
local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--
-- Unit Settings Saved Var
--
gUF_CallingModules_Settings = nil

-- Defaults
gUF_CallingModules_Defaults = {
	unitsEnabled = {["player"] = true, ["player.pet"] = false, ["player.target"] = true, ["player.target.target"] = true, ["focus"] = false},
	unitSettings = {
		["player"] = {
			modules =  {
				[1] = "ChargeBar", [2] = "WarriorComboBar"
			},
			moduleSettings = {
				[1] = { -- ChargeBar Config
					["width"] = 250,
					["height"] = 15,
					["leftText"] = "currentCharge/chargeMax",
					["rightText"] = "chargePercent%",
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["arial_round"],
					["fontSize"] = 12,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "player", -- not used in "screen" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode				
				},
				[2] = { -- WarriorComboBar Config
					["width"] = 250,
					["height"] = 5,
					["padding"] = 3, -- this is divided by 3 for the warrior bar ( so 3 == 1 pixel between combo points )
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["arial_round"],
					["fontSize"] = 12,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "player",
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode				
				}
			}
		},
		["player.target"] = {
			modules =  {
				[1] = "RogueComboBar"
			},
			moduleSettings = {
				[1] = { -- RogueComboBar Config
					["width"] = 250,
					["height"] = 5,
					["padding"] = 5, -- this is divided by 5 for the rogue bar ( so 5 == 1 pixel between combo points )
					["texturePath"] = gUF_Bars["eya02"],
					["font"] = gUF_Fonts["arial_round"],
					["fontSize"] = 12,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "player.target",
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode				
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
-- CallingModules Namespace
--

CallingModules = {}
CallingModules.init = false

--
-- TODO: Update to final settings when complete
--
function CallingModules:CheckSettings()
	if ( gUF_CallingModules_Settings ) then
		print "calling modules settings exists"
		print "TODO: Check Settings Values From Defaults"
		
	else
		print "calling modules settings do not exist, setting to default"
		gUF_CallingModules_Settings = gUF_CallingModules_Defaults
	end
end

--
-- Initialise the CallingModules based on the Saved Settings
--
function CallingModules:Initialise( )
	CallingModules:CheckSettings()
	
	local playerDetails = Inspect.Unit.Detail ( "player" )
	local playerCalling = "none"
	if ( playerDetails ) then
		playerCalling = playerDetails.calling
	end
	
	--
	-- Create calling modules modules
	--
	for unit,enabled in pairs(gUF_CallingModules_Settings.unitsEnabled) do
		if ( enabled ) then
			-- for each enabled module on the unit
			for index,module in ipairs(gUF_CallingModules_Settings.unitSettings[unit].modules) do
				local allowModule = false
				
				-- check for modules that should only exist with certain callings
				if ( module == "ChargeBar" and playerCalling == "mage") then
					allowModule = true
				end
				if ( module == "RogueComboBar" and playerCalling == "rogue") then
					allowModule = true
				end
				if ( module == "WarriorComboBar" and playerCalling == "warrior") then
					allowModule = true
				end					
			
				print ( "creating ", module, " for unit " , unit, " == ", allowModule )
			
				-- only create modules if they should be allowed with the current calling
				if( allowModule ) then
					local moduleClass = gUF_Modules[module]
					-- if module is registered then enable a new creation of it
					if ( moduleClass ) then
					
						local moduleInstance = moduleClass.new( unit )
						local settings = gUF_CallingModules_Settings.unitSettings[unit].moduleSettings[index]
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
	CallingModules.init = true
end

--
-- Only load once we player details are available
--
function CallingModules:UnitsAvailable ( unitIDs )
	-- once the modules have initialiesd, just return
	if ( CallingModules.init == true ) then
		return
	end
	
	for unitID, value in pairs ( unitIDs ) do
		local unitName = Inspect.Unit.Lookup ( unitID )
		if ( unitName == "player" ) then
			print "player available, creating calling based modules"
				CallingModules:Initialise()
		end
	end
end

-- Create the CallingModules once the player's details are available
table.insert(Event.Unit.Available, { function( unitIDs ) CallingModules:UnitsAvailable( unitIDs ) end, "gUF_CallingModules", "gUF_CallingModules Unit Available" })