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
	unitsEnabled = {["player"] = true, ["player.pet"] = true, ["player.target"] = true, ["player.target.target"] = true, ["focus"] = true},
	unitSettings = {
		["player"] = {
			modules =  { -- unit frame must be first module (else things will break)
				[1] = "UnitFrame", [2] = "HealthBar", [3] = "ResourceBar", [4] = "TextItem", [5] = "TextItem"
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
					["colorMode"] = "calling",
					["leftText"] = "healthShort/healthMaxShort",
					["rightText"] = "(healthPercent%)",
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
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
					["rightText"] = "(resourcePercent%)",
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
					["anchor"] = "insideFrame", -- screen, frame or insideFrame: if the anchor is insideFrame the module just get's inserted inside as part of the UnitFrame modules vertical box, if the anchor is outsideFrame, the anchors points are used
					["anchorUnit"] = "ignored", -- not used in "insideFrame" or "screen" mode
					["anchorPointThis"] = "ignored", -- not used in "insideFrame" mode
					["anchorPointParent"] = "ignored", -- not used in "insideFrame" mode
					["anchorXOffset"] = 0, -- not used in "insideFrame" mode
					["anchorYOffset"] = 0 -- not used in "insideFrame" mode
				},
				[4] = { -- TextItem Config
					["text"] = "name level",
					["colorMode"] = "calling", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame", -- anchor to the player frame itself (above left)
					["anchorUnit"] = "player", 
					["anchorPointThis"] = "BOTTOMLEFT", 
					["anchorPointParent"] = "TOPLEFT", 
					["anchorXOffset"] = 1, 
					["anchorYOffset"] = 0 
				},
				[5] = { -- TextItemConfig
					["text"] = "[planar] [vitality%] ",
					["colorMode"] = "none", -- none, relation, difficulty, or calling
					["color"] = gUF_Colors["white"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 12,
					["anchor"] = "frame", -- anchor to the player frame itself (above right)
					["anchorUnit"] = "player", 
					["anchorPointThis"] = "BOTTOMRIGHT", 
					["anchorPointParent"] = "TOPRIGHT", 
					["anchorXOffset"] = 1, 
					["anchorYOffset"] = 0 
				}
			} 
		},
		["player.target"] = {
			modules =  {
				[1] = "UnitFrame", [2] = "HealthBar", [3] = "ResourceBar", [4] = "TextItem", [5] = "TextItem"
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
					["rightText"] = "(healthPercent%)",
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
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
					["rightText"] = "(resourcePercent%)",
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
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
					["fontSize"] = 12,
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
					["fontSize"] = 12,
					["anchor"] = "frame", -- anchor to the player frame itself (above right)
					["anchorUnit"] = "player.target", 
					["anchorPointThis"] = "BOTTOMRIGHT", 
					["anchorPointParent"] = "TOPRIGHT", 
					["anchorXOffset"] = 1, 
					["anchorYOffset"] = 0 
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
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
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
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
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
					["padding"] = 5,
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
					["texturePath"] = gUF_Bars["smooth"],
					["font"] = gUF_Fonts["groovy"],
					["fontSize"] = 14,
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
Units.initialisedUnits = {}

--
-- TODO: Update to final settings when complete
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
						--print ( "creating enabled module ", index, "=>", module, " in unit ", unit)
						local moduleInstance = moduleClass.new( unit )
						local settings = gUF_Units_Settings.unitSettings[unit].moduleSettings[index]
						local moduleSettingsTable = moduleInstance:GetSettingsTable()
						
						-- initialise settings table from our Addon's saved variables
						for settingName,_ in pairs(moduleSettingsTable) do
							--print ( "Setting ", settingName, " => ", settings[settingName] )
							moduleSettingsTable[settingName] = settings[settingName]
						end
						
						-- Initialise the Module
						moduleInstance:Initialise( moduleSettingsTable )
						
						-- Register it's event callbacks
						moduleInstance:RegisterCallbacks()
						
						-- Store a reference to the unit frame such that we may add other items to it
						unitFrame = moduleInstance
						unitFrame.initialised = true
						Units.initialisedUnits[unit] = unitFrame
						--print ("storing frame instance for", unit, unitFrame, moduleInstance, Units.initialisedUnits[unit])
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
			local uFrameInstance = Units.initialisedUnits[unit] 
			if ( uFrameSettings["anchor"] == "frame" ) then
				local frameAnchor = Units.initialisedUnits[uFrameSettings["anchorUnit"]]:GetFrame()
				uFrameInstance:SetPoint( uFrameSettings["anchorPointThis"], frameAnchor, uFrameSettings["anchorPointParent"], uFrameSettings["anchorXOffset"], uFrameSettings["anchorYOffset"]  )
			elseif ( uFrameSettings["anchor"] == "screen" ) then
				uFrameInstance:SetPoint( uFrameSettings["anchorPointThis"], gUF.context, uFrameSettings["anchorPointParent"], uFrameSettings["anchorXOffset"], uFrameSettings["anchorYOffset"]  )
			end	
		end
	end

	
	--
	-- now create the modules
	--
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
			-- get the initialised unit frame instance
			local uFrameInstance = Units.initialisedUnits[unit] 
		
			-- for each enabled module on the unit
			for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modules) do
				
				-- we've already done the UnitFrame's so just create the other modules
				if not (module == "UnitFrame") then
					local moduleClass = gUF_Modules[module]
					
					if(moduleClass)then
						----print ( "creating enabled module ", index, "=>", module, " in unit ", unit)
						--print ("creating module --> ", module, " on/in -> ", unit)
					
						local moduleInstance = moduleClass.new( unit )
						local settings = gUF_Units_Settings.unitSettings[unit].moduleSettings[index]
						local moduleSettingsTable = moduleInstance:GetSettingsTable()
						
						-- initialise settings table from our Addon's saved variables
						for settingName,_ in pairs(moduleSettingsTable) do
							----print ( "Setting ", settingName, " => ", settings[settingName] )
							moduleSettingsTable[settingName] = settings[settingName]
						end
						
						moduleInstance:Initialise( moduleSettingsTable )
						moduleInstance:RegisterCallbacks()
							
						-- Hopefully we have a unit frame, and if so, add to it at the appropriate locale
						if ( uFrameInstance ) then
							if ( moduleSettingsTable["anchor"] == "insideFrame" ) then
								uFrameInstance:AddModule( moduleInstance )
							elseif ( moduleSettingsTable["anchor"] == "frame" ) then
								local frameAnchor = Units.initialisedUnits[moduleSettingsTable["anchorUnit"]]:GetFrame()
								--print ( "Module ", module, unit ," frame anchor ", frameAnchor )
								moduleInstance:SetPoint( moduleSettingsTable["anchorPointThis"], frameAnchor, moduleSettingsTable["anchorPointParent"], moduleSettingsTable["anchorXOffset"], moduleSettingsTable["anchorYOffset"]  )
							elseif ( moduleSettingsTable["anchor"] == "screen" ) then
								moduleInstance:SetPoint( moduleSettingsTable["anchorPointThis"], gUF.context, moduleSettingsTable["anchorPointParent"], moduleSettingsTable["anchorXOffset"], moduleSettingsTable["anchorYOffset"]  )
							end
						end
					else
						--print ("module does not exist", module)
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
	
	--print("*** NYI: ReInitialise")
	
	--[[ for each enabled unit
	for unit,enabled in pairs(gUF_Units_Settings.unitsEnabled) do
		if ( enabled ) then
			local unitSettings = gUF_Units_Settings.unitSettings[unit]
			
			if not (Units.initialisedUnits[unit]) then
				-- if we haven't already create this frame this session, or we have disabled it in this session
				--print ( "creating new enabled unit ", unit)
				local unitFrame = Box.new( 5, {r=0,g=0,b=0,a=0.3}, "vertical", "down", gUF.context, -1 )
				
				-- for each enabled module on the unit
				for index,module in ipairs(gUF_Units_Settings.unitSettings[unit].modules) do
					--print ( "creating enabled module ", index, "=>", module, " in unit ", unit)
					local moduleClass = gUF_Modules[module]
					if(moduleClass)then
						--print "module exists, creating"
						local moduleInstance = moduleClass.new( unit, unitSettings.barWidth, unitSettings.barHeight )
						moduleInstance:RegisterCallbacks()
						unitFrame:AddItem(moduleInstance)
						--
						-- TODO: Module Settings
						--
					else
						--print "module does not exist"
					end
				end
				
				
				-- store the fact that this unit has been initialised (such that if we change enabled units settings later, we know not to recreate this frame)
				unitFrame.initialised = true
				Units.initialisedUnits[unit] = unitFrame
				unitFrame:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", unitSettings.x, unitSettings.y )
				unitFrame:SetVisible(true)
			elseif (Units.initialisedUnits[unit] and Units.initialisedUnits[unit].initialised == false) then
				--print ("previously disabled, but will now reenable ",unit)
				Units.initialisedUnits[unit].initialised = true
				Units.initialisedUnits[unit]:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", unitSettings.x, unitSettings.y )
				Units.initialisedUnits[unit]:SetVisible(true)
			end
		else
			-- was this frame previously enabled?
			if(Units.initialisedUnits[unit])then
				--print ("previously enabled, but will now disable ",unit)
				Units.initialisedUnits[unit]:SetVisible(false)
				Units.initialisedUnits[unit].initialised = false
				
				--
				-- TODO: Go through modules and stop them listening for callbacks
				--
				
			end
		end
	end]]
end


-- Create the UnitFrames
table.insert(Event.Addon.SavedVariables.Load.End, { Units.Initialise, "gUF_Units", "gUF_Units Variables Loaded" })