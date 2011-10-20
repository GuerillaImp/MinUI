--
-- grUF_Core by Grantus
--
-- This core component of the grUF_Core AddOn framework is responsible for marshalling events out to the units, and
-- their modules. Modules must registers with grUF_Core to start recieving information. Modules also are comprised of the 
-- widgets defined in the core grUF_Core AddOn.
--
--

--
-- Globals
--

-- Grantus' UnitFrame's main table
grUF_Core = {}

-- Modules
grUF_Core.modules = {}
grUF_Core.eventCallBackRegistry = {}

-- Settings Saved Variable
grUF_Settings = {}

-- Context for Creation of Widgets
grUF_Core.context = UI.CreateContext("grUF_Context")

-- Units Monitored
grUF_Core.units = {}

-- Version
grUF_Core.version = "0.0.1"

-- Animate and Update threshold calcualtions
grUF_Core.lastUpdate = 0
grUF_Core.lastAnimate = 0
grUF_Core.updateDiff = 0
grUF_Core.animateDiff = 0
grUF_Core.curTime = 0
grUF_Core.update = false
grUF_Core.animate = false


--
-- Modules must register with the grUF core if they are to be used
--
-- @params
--		moduleName string: the name of the module registering with grUF, acts as the key in grUF_Core.modules
--		moduleHook table: the table that contains the modules functionality
--
function grUF_Core:RegisterModule( moduleName, moduleHook )
	print("core: registered module ", moduleName )
	
	-- insert module into modules table using the name as a key
	grUF_Core.modules[moduleName] = moduleHook
end

--
-- A module should register the events that it wishes to be informed about
--
-- @params
--		moduleName string: the name of the module registering an event
--		eventType: the name of the event hte module is registering for, there are whole bunch defined in grUF_Events
--		functionCallBack function: reference to the method in the module that should be called when this event is fired
--
function grUF_Core:RegisterEvent( moduleName, eventType, functionCallBack, unitName )
	print("core: registered ", moduleName, " for event ", eventType, " on unit ", unitName, " and shall call ", functionCallBack, " when it fires" )
	

	-- if the module actually exists (has been registered)
	local module = grUF_Core.modules[moduleName]
	
	if ( module ) then
		print("module exists")
	
		-- get any existing callbacks
		local eventCallbackRegister = grUF_Core.eventCallBackRegistry[eventType]
		
		-- store the unit name, the module and the function callback
		local newEventHook = {}
		newEventHook[unitName] = functionCallBack
		
		-- if other modules are already registered, then append this function callback to the end
		if ( eventCallbackRegister ) then
			table.insert(eventCallbackRegister, newEventHook)
			
		-- else create a new table at that registry name, then add the new function
		else
			grUF_Core.eventCallBackRegistry[eventType] = {}
			eventCallbackRegister = grUF_Core.eventCallBackRegistry[eventType]
			
			table.insert(eventCallbackRegister, newEventHook)
		end
	end
	
	--dump(grUF_Core.eventCallBackRegistry)
	--dump(grUF_Core.modules)
end



--
-- Initalise Units
--
function InitialiseUnits( )
	print("core: initialiseUnits")
	
	--
	-- Register for Unit Change here (used when the target/unit changes)
	--
	--local unitChangedEventTable = Library.LibUnitChange.Register("player")
	--table.insert(unitChangedEventTable, {function() unitChanged() end, "MinUI", uFrame.unitName.."_unitChanged"})
	
	-- TODO: Create everything :)
end


--
-- Main update Loop:
-- Animates anything that has registered for an animation
-- Updates anything that has registered for an update
--
function Update ( )
	--
	-- calculate frame time difference
	--[[
	grUF_Core.curTime = Inspect.Time.Frame()
	grUF_Core.updateDiff = grUF_Core.curTime  - grUF_Core.lastUpdate
	grUF_Core.animateDiff = grUF_Core.curTime  - grUF_Core.lastAnimate
	grUF_Core.update = false
	grUF_Core.animate = false
	
	if(grUF_Core.updateDiff >= 0.5) then -- TODO: Configurable Item
		grUF_Core.update = true
		grUF_Core.lastUpdate = grUF_Core.curTime 
		grUF_Core.updateDiff = 0
	end

	if(grUF_Core.animateDiff >= 0.01) then -- TODO: Configurable Item
		grUF_Core.animate = true
		grUF_Core.lastAnimationUpdate = grUF_Core.curTime 
		grUF_Core.animateDiff = 0
	end

	-- TODO: Loop through units and update/animate as required]]
end



--
-- Variables Loaded
--
-- @params
-- 		addonIdentifier: the addon whose variables just loaded
--
function VariablesLoaded( addonIdentifier )
	if ( addonIdentifier == "grUF_Core" ) then
		print ("core: grUF_Core saved variables loaded")
		InitialiseUnits( )
	end
end



--
-- Open the grUF_Core Options Window (if the module is enabled)
--
--
function ToggleOptionsWindow ( ) 
	local options = grUF_Core.modules["Options"]
	
	if(options)then
		print("core: toggling options")
		options:ToggleOptionsWindow()
	end
end



--
-- AddOn Loaded
--
-- params 
-- addonIdentifier: the addon just loaded
--
function AddonLoaded ( addonIdentifer )
	if ( addonIdentifier == "grUF_Core" ) then
		print( "Loaded ["..grUF_Core.version.."]. Type /gruf for options." )
		table.insert(Event.System.Update.Begin, {animate, "grUF_Core", "grUF_Core Animation Loop"})
	end
end

--
-- Common code used to run accross an event callback registry, with new data
--
-- @params
--		eventType: the name of the event hte module is registering for, there are whole bunch defined in grUF_Events
--		unitIDs table: a list of updated units, a list containing [unit id, value] from Rift's Event System
--
function UpdateRegisteredModules ( eventType, unitIDs )
	local callBackRegistry = grUF_Core.eventCallBackRegistry[eventType]
	
	-- if we have both the cbr and unitIDs
	if ( callBackRegistry and unitIDs ) then
		for unitID, value in pairs(unitIDs) do
			local updatedUnitName = Inspect.Unit.Lookup(unitID)
			-- check against callback registry and see if we have any modules listening on that unitID
			for _, eventHook in pairs ( callBackRegistry ) do
				for unitName, func in pairs ( eventHook ) do
					if(unitName == updatedUnitName)then
						func( value )
					end
				end
			end
		end
	-- some event's don't have unitIDs assoced with them, so just call their callbacks (with no args)
	elseif (callBackRegistry) then
		for _, eventHook in pairs ( callBackRegistry ) do
			for _, func in pairs ( eventHook ) do
				func()
			end
		end
	end
end

--
-- For all Update Methods:
--
-- params
-- unitIDs: list of units whose values have changed (unitID/value)
--
function HealthChanged ( unitIDs )
	UpdateRegisteredModules( HEALTH_UPDATE, unitIDs )
end
function ManaChanged ( unitIDs )
	UpdateRegisteredModules( MANA_UPDATE, unitIDs )
end
function PowerChanged ( unitIDs )
	UpdateRegisteredModules( POWER_UPDATE, unitIDs )
end
function EnergyChanged ( unitIDs )
	UpdateRegisteredModules( ENERGY_UPDATE, unitIDs )
end
function ComboChanged ( unitIDs )
	UpdateRegisteredModules( COMBO_UPDATE, unitIDs )
end
function ChargeChanged ( unitIDs )
	UpdateRegisteredModules( CHARGE_UPDATE, unitIDs )
end
function PlanarChanged ( unitIDs )
	UpdateRegisteredModules( PLANAR_UPDATE, unitIDs )
end
function VitalityChanged ( unitIDs )
	UpdateRegisteredModules( VITALITY_UPDATE, unitIDs )
end
function LevelChanged ( unitIDs )
	UpdateRegisteredModules( LEVEL_UPDATE, unitIDs )
end
function GuildChanged ( unitIDs )
	UpdateRegisteredModules( GUILD_UPDATE, unitIDs )
end
function RoleChanged ( unitIDs )
	UpdateRegisteredModules( ROLE_UPDATE, unitIDs )
end
function CastbarChanged ( unitIDs )
	UpdateRegisteredModules( CASTBAR_UPDATE, unitIDs )
end
function UnitAvailable ( unitIDs )
	UpdateRegisteredModules( UNIT_AVAILABLE, unitIDs )
end

--
-- Signal that we are now in combat
--
function EnterCombat ( )
	print("+++ combat")
	UpdateRegisteredModules( ENTER_COMBAT, nil )
end

--
-- Signal that we have now left combat
--
function LeaveCombat ( )
	print("--- combat")
	UpdateRegisteredModules( LEAVE_COMBAT, nil )
end


--
-- Register event hooks for grUF_Core
--
function RegisterEvents()
	--
	-- Management Events
	--

	-- Saved Variables Loaded
	table.insert(Event.Addon.SavedVariables.Load.End, { VariablesLoaded, "grUF_Core", "grUF_Core Variables Loaded" })
	
	-- Saved Variables Loaded
	table.insert(Event.Addon.Load.End, { AddonLoaded, "grUF_Core", "grUF_Core Addon Loaded" })
	
	-- Handle User Customisation
	table.insert(Command.Slash.Register("gruf"), { ToggleOptionsWindow, "grUF_Core", "grUF_Core Slash Command"})


	--
	-- Unit Events
	--

	--
	-- Secure Mode Enter/Leave
	--
	table.insert(Event.System.Secure.Enter, { EnterCombat, "grUF_Core", "grUF_Core Entering Combat"})
	table.insert(Event.System.Secure.Leave, { LeaveCombat, "grUF_Core", "grUF_Core Leaving Combat"})
	
	--
	-- Unit Available
	--
	table.insert(Event.Unit.Available, { UnitAvailable, "grUF_Core", "grUF_Core unitAvailable"})
	
	--
	-- Unit Changes
	--
	table.insert(Event.Unit.Detail.Health, { HealthChanged, "grUF_Core", "grUF_Core healthChanged"})
	table.insert(Event.Unit.Detail.HealthMax, { HealthChanged, "grUF_Core", "grUF_Core healthChanged"})
	table.insert(Event.Unit.Detail.Mana, { ManaChanged, "grUF_Core", "grUF_Core manaChanged"})
	table.insert(Event.Unit.Detail.ManaMax, { ManaChanged, "grUF_Core", "grUF_Core manaChanged"})
	table.insert(Event.Unit.Detail.Power, { PowerChanged, "grUF_Core", "grUF_Core powerChanged"})
	table.insert(Event.Unit.Detail.Energy, { EnergyChanged, "grUF_Core", "grUF_Core energyChanged"})
	table.insert(Event.Unit.Detail.EnergyMax, { EnergyChanged, "grUF_Core", "grUF_Core energyChanged"})
	
	--
	-- Player Only Events
	--
	table.insert(Event.Unit.Detail.Combo, { ComboChanged, "grUF_Core", "grUF_Core comboChanged"})
	table.insert(Event.Unit.Detail.ComboUnit, { ComboChanged, "grUF_Core", "grUF_Core comboChanged"})
	table.insert(Event.Unit.Detail.Charge, { ChargeChanged, "grUF_Core", "grUF_Core chargeChanged"})
	table.insert(Event.Unit.Detail.Planar, { PlanarChanged, "grUF_Core", "grUF_Core planarChanged"}) 
	table.insert(Event.Unit.Detail.Vitality, { VitalityChanged, "grUF_Core", "grUF_Core vitalityChanged"})  
	
	--
	-- Other Events
	--
	table.insert(Event.Unit.Detail.Level, { LevelChanged, "grUF_Core", "grUF_Core levelChanged"})
	table.insert(Event.Unit.Detail.Guild, { GuildChanged, "grUF_Core", "grUF_Core guildChanged"})
	table.insert(Event.Unit.Detail.Role, { RoleChanged, "grUF_Core", "grUF_Core roleChanged" })
	-- TODO: pvp
	-- TODO: warfront
	-- others.
	
	--
	-- Casting
	--
	table.insert(Event.Unit.Castbar, { CastbarChanged, "grUF_Core", "grUF_Core castbarChanged"})
end


-- 
-- Register Rift API Events (which "starts" the addon as well)
-- 
RegisterEvents()