--
-- gUF by Grantus
--
-- This core component of the gUF AddOn framework is responsible for marshalling events out to the units, and
-- their modules. Modules must registers with gUF to start recieving information. Modules also are comprised of the 
-- widgets defined in the core gUF AddOn.
--
--


--
-- Globals
--

-- Grantus' UnitFrame's main table
gUF = {}

-- Module Registry (For Addons to use)
gUF_Modules = {}

-- Event Hooks (For modules to register callbacks)
gUF_EventHooks = {}

-- AddOn Config Registry (For Options and Configuration)
gUF_AddOn_Config = {}

-- Context for Creation of Widgets
gUF.context = UI.CreateContext("gUF_Context")

-- Version
gUF.version = "0.0.1"

-- Animate and Update threshold calcualtions
gUF.lastUpdate = 0
gUF.lastAnimate = 0
gUF.updateDiff = 0
gUF.animateDiff = 0
gUF.curTime = 0
gUF.update = false
gUF.animate = false


--
-- Main update Loop:
-- Animates anything that has registered for an animation
-- Updates anything that has registered for an update
--
function Update ( )
	--
	-- calculate frame time difference
	--
	gUF.curTime = Inspect.Time.Frame()
	gUF.updateDiff = gUF.curTime  - gUF.lastUpdate
	gUF.animateDiff = gUF.curTime  - gUF.lastAnimate
	gUF.update = false
	gUF.animate = false
	
	if(gUF.updateDiff >= 0.5) then -- TODO: Configurable Item
		gUF.update = true
		gUF.lastUpdate = gUF.curTime 
		gUF.updateDiff = 0
		FireEvent( REFRESH_UPDATE, nil )
	end

	if(gUF.animateDiff >= 0.01) then -- TODO: Configurable Item
		gUF.animate = true
		gUF.lastAnimationUpdate = gUF.curTime 
		gUF.animateDiff = 0
		FireEvent( ANIMATION_UPDATE, nil )
	end
end

--
-- AddOn Loaded
--
-- params 
-- addonIdentifier: the addon just loaded
--
function AddonLoaded ( addonIdentifer )
	if ( addonIdentifier == "gUF" ) then
		print( "Loaded ["..gUF.version.."]. Type /gruf for options." )
		table.insert(Event.System.Update.Begin, {animate, "gUF", "gUF Animation Loop"})
	end
end

--
-- Common code used to run accross an event callback registry, with new data
--
-- @params
--		eventType: the name of the event the module is registering for, there are whole bunch defined in grUF_Events
--		unitIDs table: a list of updated units, a list containing [unit id, value] from Rift's Event System
--
function FireEvent ( eventType, unitIDs )
	-- dump (unitIDs)
	
	for _,eventHook in pairs(gUF_EventHooks)do
		local hookEventType = eventHook[1]
		
		-- does this event match the event type given?
		if ( hookEventType == eventType ) then
			local unitName = eventHook[2]

			-- do we have unitIDs? (Some events dont use them)
			if ( unitIDs ) then
				-- if so iterate then find the correct one and fire it's CallBack function
				for unitID, value in pairs ( unitIDs ) do
					if ( unitName == Inspect.Unit.Lookup(unitID) ) then
						print(Inspect.Unit.Lookup(unitID), value)
						local moduleInstance = eventHook[3]
						local moduleCallback = eventHook[4]
						moduleInstance:CallBack(eventType, value) -- give the function the value for the update and the event type it came from (just to double check)
					end
				end
			-- no unitIDs, just fire the CallBack
			else
				local moduleInstance = eventHook[3]
				local moduleCallback = eventHook[4]
				moduleInstance:CallBack(eventType, nil)
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
	FireEvent( HEALTH_UPDATE, unitIDs )
end
function ManaChanged ( unitIDs )
	FireEvent( MANA_UPDATE, unitIDs )
end
function PowerChanged ( unitIDs )
	FireEvent( POWER_UPDATE, unitIDs )
end
function EnergyChanged ( unitIDs )
	FireEvent( ENERGY_UPDATE, unitIDs )
end
function ComboChanged ( unitIDs )
	FireEvent( COMBO_UPDATE, unitIDs )
end
function ChargeChanged ( unitIDs )
	FireEvent( CHARGE_UPDATE, unitIDs )
end
function PlanarChanged ( unitIDs )
	FireEvent( PLANAR_UPDATE, unitIDs )
end
function VitalityChanged ( unitIDs )
	FireEvent( VITALITY_UPDATE, unitIDs )
end
function LevelChanged ( unitIDs )
	FireEvent( LEVEL_UPDATE, unitIDs )
end
function GuildChanged ( unitIDs )
	FireEvent( GUILD_UPDATE, unitIDs )
end
function RoleChanged ( unitIDs )
	FireEvent( ROLE_UPDATE, unitIDs )
end
function CastbarChanged ( unitIDs )
	FireEvent( CASTBAR_UPDATE, unitIDs )
end
function UnitAvailable ( unitIDs )
	FireEvent( UNIT_AVAILABLE, unitIDs )
end
function UnitChanged ( unitID )
	if ( unitID ) then
		local unit = {}
		unit[unitID] = true
		FireEvent( UNIT_CHANGED, unit )
	end
end

--
-- Signal that we are now in combat
--
function EnterCombat ( )
	print("+++ combat")
	FireEvent( ENTER_COMBAT, nil )
end

--
-- Signal that we have now left combat
--
function LeaveCombat ( )
	print("--- combat")
	FireEvent( LEAVE_COMBAT, nil )
end


--
-- Register event hooks for gUF
--
function RegisterEvents()
	--
	-- Management Events
	--
	
	-- Saved Variables Loaded
	table.insert(Event.Addon.Load.End, { AddonLoaded, "gUF", "gUF Addon Loaded" })

	--
	-- Unit Events
	--

	--
	-- Secure Mode Enter/Leave
	--
	table.insert(Event.System.Secure.Enter, { EnterCombat, "gUF", "gUF Entering Combat"})
	table.insert(Event.System.Secure.Leave, { LeaveCombat, "gUF", "gUF Leaving Combat"})
	
	--
	-- Unit Available
	--
	table.insert(Event.Unit.Available, { UnitAvailable, "gUF", "gUF unitAvailable"})
	
	--
	-- Unit Change
	--
	local units = {"player","player.target","player.target.target","player.pet","focus"} -- perhaps have one for group01-20?
	for _,unit in pairs(units)do
		local unitChangedEventTable = Library.LibUnitChange.Register( unit )
		table.insert(unitChangedEventTable, { function ( unit ) UnitChanged( unit ) end, "gUF", "gUF UnitChanged"})
	end
	
	--
	-- Unit Updates
	--
	table.insert(Event.Unit.Detail.Health, { HealthChanged, "gUF", "gUF healthChanged"})
	table.insert(Event.Unit.Detail.HealthMax, { HealthChanged, "gUF", "gUF healthChanged"})
	table.insert(Event.Unit.Detail.Mana, { ManaChanged, "gUF", "gUF manaChanged"})
	table.insert(Event.Unit.Detail.ManaMax, { ManaChanged, "gUF", "gUF manaChanged"})
	table.insert(Event.Unit.Detail.Power, { PowerChanged, "gUF", "gUF powerChanged"})
	table.insert(Event.Unit.Detail.Energy, { EnergyChanged, "gUF", "gUF energyChanged"})
	table.insert(Event.Unit.Detail.EnergyMax, { EnergyChanged, "gUF", "gUF energyChanged"})
	
	--
	-- Player Only Events
	--
	table.insert(Event.Unit.Detail.Combo, { ComboChanged, "gUF", "gUF comboChanged"})
	table.insert(Event.Unit.Detail.ComboUnit, { ComboChanged, "gUF", "gUF comboChanged"})
	table.insert(Event.Unit.Detail.Charge, { ChargeChanged, "gUF", "gUF chargeChanged"})
	table.insert(Event.Unit.Detail.Planar, { PlanarChanged, "gUF", "gUF planarChanged"}) 
	table.insert(Event.Unit.Detail.Vitality, { VitalityChanged, "gUF", "gUF vitalityChanged"})  
	
	--
	-- Other Events
	--
	table.insert(Event.Unit.Detail.Level, { LevelChanged, "gUF", "gUF levelChanged"})
	table.insert(Event.Unit.Detail.Guild, { GuildChanged, "gUF", "gUF guildChanged"})
	table.insert(Event.Unit.Detail.Role, { RoleChanged, "gUF", "gUF roleChanged" })
	-- TODO: pvp
	-- TODO: warfront
	-- others.
	
	--
	-- Casting
	--
	table.insert(Event.Unit.Castbar, { CastbarChanged, "gUF", "gUF castbarChanged"})
end


-- 
-- Register Rift API Events (which "starts" the addon as well)
-- 
RegisterEvents()