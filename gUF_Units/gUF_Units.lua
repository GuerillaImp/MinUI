--
-- gUF_Units by Grantus
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
	unitsEnabled = {["player"] = true, ["player.pet"] = true, ["player.target"] = true, ["player.target.target"] = true, ["focus"] = true},
	unitSettings = {
		["player"] = {
			modules =  { -- unit frame must be first module (else things will break)
				[1] = "UnitFrame", [2] = "HealthBar", [3] = "ResourceBar", [4] = "TextItem", [5] = "TextItem", [6] = "CastBar"
			},
			--
			-- These config settings can be viewed in the [module].lua settings table, if you miss an option here it will be set to a default value 
			-- Obviously this index should line up with the indexes of the modules on the unit frame above (otherwise you will be setting values that dont get used or exist in the 
			-- modules settings table)
			--
			moduleSettings = {
				[1] = { -- UnitFrame Config: 
					["padding"] = 1,
					["bgColor"] = gUF_Colors["black"],
					["anchor"] = "screen",-- screen or frame only
					["anchorUnit"] = "ignored", -- ignored in screen mode, used in frame mode
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 600,
					["anchorYOffset"] = 600
				},
				[2] = { -- HealthBar Config
					["width"] = 250,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "healthShort/healthMaxShort",
					["rightText"] = "healthPercent%",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "ignored", -- not used in "insideFrame" or "screen" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				},
				[3] = { -- ResourcesBar Config
					["width"] = 250,
					["height"] = 20,
					["leftText"] = "resourceShort/resourceMaxShort",
					["rightText"] = "resourcePercent%",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "ignored", -- not used in "insideFrame" or "screen" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				},
				[4] = { -- TextItem Config
					["text"] = "name",
					["colorMode"] = "none", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 18,
					["anchor"] = "frame", -- anchor to the player frame itself (above left)
					["anchorUnit"] = "player", 
					["anchorPointThis"] = "BOTTOMLEFT", 
					["anchorPointParent"] = "TOPLEFT", 
					["anchorXOffset"] = 1, 
					["anchorYOffset"] = 0 
				},
				[5] = { -- TextItemConfig
					["text"] = "<planar> (vitality%) ",
					["colorMode"] = "none", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame", -- anchor to the player frame itself (above right)
					["anchorUnit"] = "player", 
					["anchorPointThis"] = "BOTTOMRIGHT", 
					["anchorPointParent"] = "TOPRIGHT", 
					["anchorXOffset"] = -1, 
					["anchorYOffset"] = 0 
				},
				[6] = { -- CastBar config
					["width"] = 222,
					["height"] = 25,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["red_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["red_background"], -- user sets color
					["icon"] = "left", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 25,
					["leftText"] = "abilityName", -- abilityName, abilityTarget, remainingShort/Abs, durationShort/Abs
					-- XXX: Ability Target is buggy
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "player",
					["anchorPointThis"] = "TOPRIGHT",
					["anchorPointParent"] = "BOTTOMRIGHT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 10
				}
			} 
		},
		["player.target"] = {
			modules =  {
				[1] = "UnitFrame", [2] = "HealthBar", [3] = "ResourceBar", [4] = "TextItem", [5] = "TextItem", [6] = "TextItem", [7] = "CastBar"
			},
			moduleSettings = {
				[1] = { 
					["padding"] = 1,
					["bgColor"] = gUF_Colors["black"],
					["anchor"] = "frame", -- screen or frame only
					["anchorUnit"] = "player", -- ignored in screen mode, used in frame mode
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPRIGHT",
					["anchorXOffset"] = 200,
					["anchorYOffset"] = 0
				},
				[2] = { 
					["width"] = 250,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "healthShort/healthMaxShort",
					["rightText"] = "healthPercent%",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame", --XXX FIX ME frame mode, requires an anchorUnit to be specified NOTE: Frame anchoring just isn't working at the moment for modules for some reason I cannot figure out
					["anchorUnit"] = "player.target", -- anchor this outside the player.target frame (just testing for now)
					["anchorPointThis"] = "TOPRIGHT", 
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = 10, 
					["anchorYOffset"] = 10
				},
				[3] = { 
					["width"] = 250,
					["height"] = 20,
					["leftText"] = "resourceShort/resourceMaxShort",
					["rightText"] = "resourcePercent%",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "ignored", -- not used in "insideFrame" or "screen" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				},
				[4] = { -- TextItem Config
					["text"] = "name",
					["colorMode"] = "relation", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 18,
					["anchor"] = "frame", -- anchor to the player frame itself (above left)
					["anchorUnit"] = "player.target", 
					["anchorPointThis"] = "BOTTOMLEFT", 
					["anchorPointParent"] = "TOPLEFT", 
					["anchorXOffset"] = 1, 
					["anchorYOffset"] = 0 
				},
				[5] = { -- TextItemConfig
					["text"] = "level",
					["colorMode"] = "difficulty", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 18,
					["anchor"] = "frame", -- anchor to the player frame itself (above right)
					["anchorUnit"] = "player.target", 
					["anchorPointThis"] = "BOTTOMRIGHT", 
					["anchorPointParent"] = "TOPRIGHT", 
					["anchorXOffset"] = -1, 
					["anchorYOffset"] = 0 
				},
				[6] = { -- TextItemConfig
					["text"] = "afk offline guild",
					["colorMode"] = "calling", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 18,
					["anchor"] = "frame", -- anchor to the player frame itself (above right)
					["anchorUnit"] = "player.target", 
					["anchorPointThis"] = "TOPCENTER", 
					["anchorPointParent"] = "BOTTOMCENTER", 
					["anchorXOffset"] = 0, 
					["anchorYOffset"] = 0 
				},
				[7] = { -- CastBar config
					["width"] = 222,
					["height"] = 25,
					["padding"] = 1,
					["frameBGColor" ] = gUF_Colors["black"],
					["barColor"] = gUF_Colors["red_foreground"], -- user sets color
					["barBGColor"] = gUF_Colors["red_background"], -- user sets color
					["icon"] = "left", -- left, right, none
					["iconPadding"] = 1,
					["iconSize"] = 25,
					["leftText"] = "abilityName", -- abilityName, abilityTarget, remainingShort/Abs, durationShort/Abs
					-- XXX: Ability Target is buggy
					["rightText"] = "remainingShort / durationShort",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame",
					["anchorUnit"] = "player.target",
					["anchorPointThis"] = "TOPRIGHT",
					["anchorPointParent"] = "BOTTOMRIGHT",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 10
				}
			} 
		},
		["player.target.target"] = {
			modules =  {
				[1] = "UnitFrame", [2] = "HealthBar"
			},
			moduleSettings = {
				[1] = { 
					["padding"] = 1,
					["bgColor"] = gUF_Colors["black"],
					["anchor"] = "frame", -- screen or frame only
					["anchorUnit"] = "player.target", -- targets target anchored to target
					["anchorPointThis"] = "TOPLEFT",
					["anchorPointParent"] = "TOPRIGHT",
					["anchorXOffset"] = 50,
					["anchorYOffset"] = 0
				},
				[2] = { 
					["width"] = 250,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "name",
					["rightText"] = "healthShort/healthMaxShort",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame", 
					["anchorUnit"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				}
			} 			
		},
		["player.pet"] = {
			modules =  {
				[1] = "UnitFrame", [2] = "HealthBar"
			},
			moduleSettings = {
				[1] = { 
					["padding"] = 1,
					["bgColor"] = gUF_Colors["black"],
					["anchor"] = "frame",-- screen or frame only
					["anchorUnit"] = "player", -- ignored in screen mode, used in frame mode
					["anchorPointThis"] = "TOPRIGHT",
					["anchorPointParent"] = "TOPLEFT",
					["anchorXOffset"] = -50,
					["anchorYOffset"] = 0
				},
				[2] = { 
					["width"] = 250,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "name",
					["rightText"] = "healthShort/healthMaxShort",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame", 
					["anchorUnit"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				}
			} 			
		},
		["focus"] = {
			modules =  {
				[1] = "UnitFrame", [2] = "HealthBar"
			},
			moduleSettings = {
				[1] = { 
					["padding"] = 1,
					["bgColor"] = gUF_Colors["black"],				
					["anchor"] = "frame", -- screen anchor is gUF.context
					["anchorUnit"] = "player",		
					["anchorPointThis"] = "TOPCENTER",
					["anchorPointParent"] = "TOPCENTER",
					["anchorXOffset"] = 0,
					["anchorYOffset"] = 100
				},
				[2] = { 
					["width"] = 250,
					["height"] = 30,
					["colorMode"] = "health",
					["leftText"] = "name",
					["rightText"] = "healthShort/healthMaxShort",
					["texturePath"] = gUF_Bars["aluminium"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 15,
					["anchor"] = "insideFrame",
					["anchorUnit"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				}
			} 			 
		}
	}
}

--
-- Units Namespace
--

Units = {}

--
-- TODO: Update to final settings when complete
--
function Units:CheckSettings()
	if ( gUF_Units_Settings ) then
		print "units settings exists"
		print "TODO: Check Settings Has Values From Defaults"
		
	else
		print "units settings does not exist, setting to default"
		gUF_Units_Settings = gUF_Units_Defaults
	end
end

--
-- Initialise the Frames based on the Saved Settings
--
function Units:Initialise()
	Units:CheckSettings()
	
	--
	-- for each enabled unit - create the UnitFrame modules
	--
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
		
			local unitSettings = gUF_Units_Settings.unitSettings[unit]
			local unitFrame = nil
			
			--
			-- create the UnitFrame modules first, just to ensure that we have them created for modules that anchor to them frame, 
			-- rather than being anchored internally
			--
			for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modules) do
				if ( module == "UnitFrame" ) then
					local moduleClass = gUF_Modules[module]
					
					if(moduleClass)then
						local moduleInstance = moduleClass.new( unit, "gUF_Units" )
						local settings = gUF_Units_Settings.unitSettings[unit].moduleSettings[index]
						local moduleSettingsTable = moduleInstance:GetSettingsTable()
						
						-- initialise settings table from our Addon's saved variables
						for settingName,_ in pairs(moduleSettingsTable) do
							moduleSettingsTable[settingName] = settings[settingName]
						end
						
						-- Initialise the Module
						moduleInstance:Initialise( moduleSettingsTable )
						
						-- Register it's event callbacks
						moduleInstance:RegisterCallbacks()
						
						-- Store a reference to the unit frame such that we may add other items to it
						unitFrame = moduleInstance
						unitFrame.initialised = true
						
						table.insert(gUF.initialisedFrames, { "gUF_Units", unit, unitFrame })
					end
				end
			end
		end
	end	
	
	
	--
	-- anchor the unit frames appropriately - we do this after the creation loop as we want to make sure all the UnitFrames that are enabled have been created
	-- this is because we dont know exactly the order the frames will be created and we want to ensure that frames anchored to frames work correctly
	--
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
			--print ( "anchoring frame for ", unit)
			local uFrameSettings = gUF_Units_Settings.unitSettings[unit].moduleSettings[1] -- unit frame must always be first?!? XXX: This is a bit hacktacular
			
			local uFrameInstance = nil
			
			-- get unit frame instance from the gUF registry
			for _,unitFrameRegister in pairs ( gUF.initialisedFrames ) do
				-- check they belong to this addon
				if ( unitFrameRegister[1] == "gUF_Units" ) then
					-- check the frame belongs to this unit
					if ( unitFrameRegister[2] == unit ) then
						-- store the instance
						uFrameInstance = unitFrameRegister[3]
					end
				end
			end
			
			--print ("unit frame register --> ", uFrameInstance)
		
			
			if ( uFrameInstance ) then
				if ( uFrameSettings["anchor"] == "frame" ) then
					local frameAnchor = nil

					-- find anchor unit from the registry
					for _,unitFrameRegister in pairs ( gUF.initialisedFrames ) do
						-- check they belong to this addon
						if ( unitFrameRegister[1] == "gUF_Units" ) then
							-- check the frame belongs to this modules "anchorUnit"
							if ( unitFrameRegister[2] == uFrameSettings["anchorUnit"] ) then
								-- store the instance of the Rift Frame stored by this frame :P
								frameAnchor = unitFrameRegister[3]:GetFrame()
							end
						end
					end	
					
					--print ("unit frame from registry for frame to anchor on --> ", frameAnchor)
							
					if ( frameAnchor ) then										
						uFrameInstance:SetPoint( uFrameSettings["anchorPointThis"], frameAnchor, uFrameSettings["anchorPointParent"], uFrameSettings["anchorXOffset"], uFrameSettings["anchorYOffset"]  )
					else
						print ("error: no frame instance to anchor this frame to -> ", unit, " to ", uFrameSettings["anchorUnit"])
					end
				elseif ( uFrameSettings["anchor"] == "screen" ) then
					uFrameInstance:SetPoint( uFrameSettings["anchorPointThis"], gUF.context, uFrameSettings["anchorPointParent"], uFrameSettings["anchorXOffset"], uFrameSettings["anchorYOffset"]  )
				end	
			end
		end
	end

	
	--
	-- now create the modules
	--
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
		
			-- get unit frame instance from the gUF registry
			local uFrameInstance = nil
			for _,unitFrameRegister in pairs ( gUF.initialisedFrames ) do
				-- check they belong to this addon
				if ( unitFrameRegister[1] == "gUF_Units" ) then
					-- check the frame belongs to this unit
					if ( unitFrameRegister[2] == unit ) then
						-- store the instance
						uFrameInstance = unitFrameRegister[3]
					end
				end
			end
			
			--print ("unit frame register --> ", uFrameInstance)
		
			-- for each enabled module on the unit
			for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modules) do
				
				-- we've already done the UnitFrame's so just create the other modules
				if not (module == "UnitFrame") then
					local moduleClass = gUF_Modules[module]
					
					if(moduleClass)then
						local moduleInstance = moduleClass.new( unit )
						local settings = gUF_Units_Settings.unitSettings[unit].moduleSettings[index]
						local moduleSettingsTable = moduleInstance:GetSettingsTable()
						
						-- initialise settings table from our Addon's saved variables
						for settingName,_ in pairs(moduleSettingsTable) do
							moduleSettingsTable[settingName] = settings[settingName]
						end
						
						moduleInstance:Initialise( moduleSettingsTable )
						moduleInstance:RegisterCallbacks()
							
						-- Add Module at it's anchor location
						if ( moduleSettingsTable["anchor"] == "insideFrame" ) then
							if ( uFrameInstance ) then
								uFrameInstance:AddModule( moduleInstance )
							else
								print ("error: no frame instance to insert module inside ", unit,  module)
							end
						elseif ( moduleSettingsTable["anchor"] == "frame" ) then
							local frameAnchor = nil

							-- find anchor unit from the registry
							for _,unitFrameRegister in pairs ( gUF.initialisedFrames ) do
								-- check they belong to this addon
								if ( unitFrameRegister[1] == "gUF_Units" ) then
									-- check the frame belongs to this modules "anchorUnit"
									if ( unitFrameRegister[2] == moduleSettingsTable["anchorUnit"] ) then
										-- store the instance of the Rift Frame stored by this frame :P
										frameAnchor = unitFrameRegister[3]:GetFrame()
									end
								end
							end
							
							
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

--
-- Reinitialise the Frames once settings have been changed - this shuold probably called by an "Apply" button
--
function Units:ReInitialise()
	Units:CheckSettings()
	print "NYI: Units Reinitialise"
end


-- Create the UnitFrames
table.insert(Event.Addon.SavedVariables.Load.End, { Units.Initialise, "gUF_Units", "gUF_Units Variables Loaded" })