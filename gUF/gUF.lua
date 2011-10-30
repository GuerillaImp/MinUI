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

-- Initialised Frame Registry (Such that other addons can anchor to other addon's frames)
-- Addons must register there frames as a table = { "addonName", "unit", instanceReference }
gUF.initialisedFrames = {}

-- Context for Creation of Widgets
gUF.context = UI.CreateContext("gUF_Context")

-- Version
gUF.version = "0.0.1"

-- Animate and Update threshold calcualtions
gUF.lastUpdate = 0
gUF.lastAnimate = 0
gUF.lastSimulate = 0
gUF.updateDiff = 0
gUF.animateDiff = 0
gUF.simualteDiff = 9
gUF.curTime = 0

-- simulation for 
gUF.simulate = false

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
	gUF.simulateDiff = gUF.curTime  - gUF.lastSimulate
	
	if(gUF.updateDiff >= 0.2) then -- TODO: Configurable Item
		gUF.lastUpdate = gUF.curTime 
		gUF.updateDiff = 0
		FireEvent( REFRESH_UPDATE, nil )
	end

	if ( gUF.simulate ) then
		if(gUF.simulateDiff >= 0.2)then -- TODO: Configuration Item
			gUF.lastSimulate = gUF.curTime 
			gUF.simulateDiff = 0
			FireEvent( SIMULATE_UPDATE, nil )
		end
	end
	
	if(gUF.animateDiff >= 0.01) then -- TODO: Configurable Item
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
	--print ("addong loaded ", addonIdentifer)
	if ( addonIdentifer == "gUF" ) then
		--print( "Loaded ["..gUF.version.."]. Type /guf for options." )
		table.insert(Event.System.Update.Begin, {Update, "gUF", "gUF Animation Loop"})
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

			hookUnitID = Inspect.Unit.Lookup(unitName)
			
			
			-- do we have unitIDs? (Some events dont use them)
			if ( unitIDs ) then
				-- if so iterate then find the correct one and fire it's CallBack function
				for unitID, value in pairs ( unitIDs ) do
					if ( unitID == hookUnitID ) then
						--print(Inspect.Unit.Lookup(unitID), value)
						local moduleInstance = eventHook[3]
						local moduleCallback = eventHook[4]
						moduleInstance:CallBack(eventType, value) -- give the function the value for the update and the event type it came from (just to double check)
					end
				end
			-- no unitIDs, just fire the CallBack to anything listening (for charge/combo points and other player items)
			else
				local moduleInstance = eventHook[3]
				local moduleCallback = eventHook[4]
				moduleInstance:CallBack(eventType, nil)
			end
		end
	end
end

--
-- Unit Changed Event, slightly different from above in that we have the unitName as the key, and the current unitID as the value
-- due to the LibUnitChanged way of handling events
--
-- @params
--		unitsChanged table: changed units, a list containing [unitName, unitID] from Rift's Event System, unitID will be false if the unit is no longer available
--
function FireUnitChangedEvent ( unitsChanged )
	-- dump (unitIDs)
	
	--print("firing unit change events ", unitsChanged)
	
	for _,eventHook in pairs(gUF_EventHooks)do
		local hookEventType = eventHook[1]
		
		-- Look for UNIT_CHANGED event hooks
		if ( hookEventType == UNIT_CHANGED ) then
		
			local unitName = eventHook[2] -- the unit that this hook is listening to
			
			-- if we actually have some unit's changed
			if ( unitsChanged ) then
				--  iterate then find the correct event hook and fire it's CallBack function
				for unitChangedName, value in pairs ( unitsChanged ) do
					--print("unitChanged ", unitChangedName, " new value " , value)
					if ( unitName == unitChangedName ) then
						local moduleInstance = eventHook[3]
						local moduleCallback = eventHook[4]
						moduleInstance:CallBack( UNIT_CHANGED, value ) -- give the function the value for the update and the event type it came from (just to double check)
						
					end
				end
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
	print ( "comboChanged!" )
	FireEvent( COMBO_UPDATE, nil )
end
function ComboUnitChanged ( unitIDs )
	print ( "comboUnitChanged!" )
	FireEvent( COMBO_UNIT_UPDATE, nil )
end
function ChargeChanged ( unitIDs )
	FireEvent( CHARGE_UPDATE, nil )
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
function PvpChanged ( unitIDs )
	FireEvent( PVP_UPDATE, unitIDs )
end
function WarfrontChanged ( unitIDs )
	FireEvent( WARFRONT_UPDATE, unitIDs )
end
function OfflineChanged ( unitIDs ) 
	FireEvent( OFFLINE_UPDATE, unitIDs )
end
function MarkChanged ( unitIDs )
	FireEvent( MARK_UPDATE, unitIDs )
end
function AfkChanged ( unitIDs ) 
	FireEvent( AFK_UPDATE, unitIDs )
end
function NameChanged ( unitIDs ) 
	FireEvent( NAME_UPDATE, unitIDs )
end

function UnitChanged ( unitID, unitName )
	local unit = {}
	unit[unitName] = unitID
	FireUnitChangedEvent( unit )
end

--
-- Signal that we are now in combat
--
function EnterCombat ( )
	FireEvent( ENTER_COMBAT, nil )
end

--
-- Signal that we have now left combat
--
function LeaveCombat ( )
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
	for _,unitName in pairs(units)do
		local unitChangedEventTable = Library.LibUnitChange.Register( unitName )
		table.insert(unitChangedEventTable, { function ( unitID ) UnitChanged( unitID, unitName ) end, "gUF", "gUF UnitChanged"})
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
	table.insert(Event.Unit.Detail.ComboUnit, { ComboUnitChanged, "gUF", "gUF comboChanged"})
	table.insert(Event.Unit.Detail.Charge, { ChargeChanged, "gUF", "gUF chargeChanged"})
	table.insert(Event.Unit.Detail.Planar, { PlanarChanged, "gUF", "gUF planarChanged"}) 
	table.insert(Event.Unit.Detail.Vitality, { VitalityChanged, "gUF", "gUF vitalityChanged"})  
	
	--
	-- Textual Events
	--
	table.insert(Event.Unit.Detail.Level, { LevelChanged, "gUF", "gUF levelChanged"})
	table.insert(Event.Unit.Detail.Guild, { GuildChanged, "gUF", "gUF guildChanged"})
	table.insert(Event.Unit.Detail.Warfront, { WarfrontChanged, "gUF", "gUF WarfontChanged" })
	table.insert(Event.Unit.Detail.Offline, { OfflineChanged, "gUF", "gUF OfflineChanged" })
	table.insert(Event.Unit.Detail.Mark, { MarkChanged, "gUF", "gUF MarkChanged" })
	table.insert(Event.Unit.Detail.Afk, { AfkChanged, "gUF", "gUF AfkChange" })
	table.insert(Event.Unit.Detail.Name, { NameChanged, "gUF", "gUF NameChange" })

	--
	-- Icon Events 
	--  
	table.insert(Event.Unit.Detail.Role, { RoleChanged, "gUF", "gUF roleChanged" })
	table.insert(Event.Unit.Detail.Pvp, { PvpChanged, "gUF", "gUF PvpChanged" })
	
	--
	-- Casting
	--
	table.insert(Event.Unit.Castbar, { CastbarChanged, "gUF", "gUF castbarChanged"})
	
	-- Simulate Events
	table.insert(Command.Slash.Register("gufsim"), { 
	function ()
		if ( gUF.simulate == true ) then 
			gUF.simulate = false 
		else
			gUF.simulate = true 
		end 
	end, "gUF", "gUF simulate Command"})
	
	
	-- Toggle frame locked/unlock
	table.insert( Command.Slash.Register("gufconfig"), { function() FireEvent( TOGGLE_FRAME_LOCK, nil ) end, "gUF", "gUF toggleFramesLocked"})

end

--
-- Get Core Functions panel
--
function GetCoreOptions()
	local optionsPane = Box.new(  0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, -1 )
	local text = Text.new ( "media/fonts/arial_round.ttf", 26, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	text:SetText("gUF_Core Config --- TODO!")
	optionsPane:AddItem(text)
	
	
	local triggerButton = UI.CreateFrame("RiftButton", "gUF_Options", gUF.context)
	triggerButton:SetLayer(7)
	triggerButton:SetText("gUF_Core")
	
	local optionsItems = { triggerButton, optionsPane }
	
	return optionsItems
end

-- 
-- Register Rift API Events (which "starts" the addon as well)
-- 
RegisterEvents()

-- Register for options
gUF_AddOn_Config["Core"] = GetCoreOptions