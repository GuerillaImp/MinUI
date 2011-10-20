--
-- grUF_Core by Grantus
--
-- This core component of the grUF AddOn framework is responsible for marshalling events out to the units, and
-- their modules. Modules must registers with grUF to start recieving information. Modules also are comprised of the 
-- widgets defined in the core grUF AddOn.
--
--

--
-- Globals
--
grUF = {}

-- Context for Creation of Widgets
grUF.context = UI.CreateContext("grUF_Context")

-- Units Monitored
grUF.units = {}

-- Version
grUF.version = "0.0.1"

-- Animate and Update threshold items
grUF.lastUpdate = 0
grUF.lastAnimate = 0
grUF.updateDiff = 0
grUF.animateDiff = 0
grUF.curTime = 0
grUF.update = false
grUF.animate = false

-- Register events hook for grUF
registerEvents()

--
-- Functions
--

function initialiseUnits( )
	print("initialiseUnits")
	-- TODO: Create everything :)
end

--
-- Main update Loop:
-- Animates anything that has registered for an animation
-- Updates anything that has registered for an update
--
function update ( )
	--
	-- calculate frame time difference
	--[[
	grUF.curTime = Inspect.Time.Frame()
	grUF.updateDiff = grUF.curTime  - grUF.lastUpdate
	grUF.animateDiff = grUF.curTime  - grUF.lastAnimate
	grUF.update = false
	grUF.animate = false
	
	if(grUF.updateDiff >= 0.5) then -- TODO: Configurable Item
		grUF.update = true
		grUF.lastUpdate = grUF.curTime 
		grUF.updateDiff = 0
	end

	if(grUF.animateDiff >= 0.01) then -- TODO: Configurable Item
		grUF.animate = true
		grUF.lastAnimationUpdate = grUF.curTime 
		grUF.animateDiff = 0
	end

	-- TODO: Loop through units and update/animate as required]]
end

--
-- Variables Loaded
--
-- @params
-- 		addonIdentifier: the addon whose variables just loaded
--
function variablesLoaded( addonIdentifier )
	if ( addonIdentifier == "grUF" ) then
		print ( "grUF saved variables loaded" )
		initialiseUnits( )
	end
end

--
-- Open the grUF Options Window
--
--
function showOptions ( ) 
	print( "TODO: Show options GUI!" )
end

--
-- AddOn Loaded
--
-- params 
-- addonIdentifier: the addon just loaded
--
function addonLoaded ( addonIdentifer )
	if ( addonIdentifier == "grUF" ) then
		print( "Loaded ["..grUF.version.."]. Type /gruf for options." )
		table.insert(Event.System.Update.Begin, {animate, "grUF", "grUF Animation Loop"})
	end
end

--
-- Signal that we are now in combat
--
function enterCombat ( )
	print("+++ combat")
end

--
-- Signal that we have now left combat
--
function leaveCombat ( )
	print("--- combat")
end

--
-- Notify unit's that are available for Inspect.Unit
--
-- params
-- unitIDs: Table of units who have become available
--
function unitAvailable ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " available for Inspect.Unit")
	end
end

function healthChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " health changed")
	end
end

function manaChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " mana changed")
	end
end

function powerChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " power changed")
	end
end

function energyChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " energy changed")
	end
end

function comboChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " combo changed")
	end
end

function chargeChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " charge changed")
	end
end

function planarChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " planar changed")
	end
end

function vitalityChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " vitality changed")
	end
end

function levelChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " level changed")
	end
end

function guildChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " guild changed")
	end
end

function roleChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " role changed")
	end
end

function castbarChanged ( unitIDs )
	for unitID, value in pairs(unitIDs) do
		print("unit ", Inspect.Unit.Lookup(unitID), " castbar changed")
	end
end

--
-- Register event hooks for grUF
--
function registerEvents()
	--
	-- Management Events
	--

	-- Saved Variables Loaded
	table.insert(Event.Addon.SavedVariables.Load.End, { variablesLoaded, "grUF", "grUF Variables Loaded" })
	
	-- Saved Variables Loaded
	table.insert(Event.Addon.Load.End, { addonLoaded, "grUF", "grUF Addon Loaded" })
	
	-- Handle User Customisation
	table.insert(Command.Slash.Register("gruf"), {showOptions, "grUF", "grUF Slash Command"})

	-- Secure Mode Enter/Leave
	table.insert(Event.System.Secure.Enter, {enterCombat, "grUF", "grUF Entering Combat"})
	table.insert(Event.System.Secure.Leave, {leaveCombat, "grUF", "grUF Leaving Combat"})

	--
	-- Unit Events
	--
	
	--
	-- Unit Available - check for the player unit frame being avaialbe for inspection
	--
	table.insert(Event.Unit.Available, {unitAvailable, "grUF", "grUF unitAvailable"})
	
	--
	-- Unit Changes
	--
	table.insert(Event.Unit.Detail.Health, { healthChanged, "grUF", "grUF healthChanged"})
	table.insert(Event.Unit.Detail.HealthMax, { healthChanged, "grUF", "grUF healthChanged"})
	table.insert(Event.Unit.Detail.Mana, { manaChanged, "grUF", "grUF manaChanged"})
	table.insert(Event.Unit.Detail.ManaMax, { manaChanged, "grUF", "grUF manaChanged"})
	table.insert(Event.Unit.Detail.Power, { powerChanged, "grUF", "grUF powerChanged"})
	table.insert(Event.Unit.Detail.Energy, { energyChanged, "grUF", "grUF energyChanged"})
	table.insert(Event.Unit.Detail.EnergyMax, { energyChanged, "grUF", "grUF energyChanged"})
	
	--
	-- Player Only Events
	--
	table.insert(Event.Unit.Detail.Combo, { comboChanged, "grUF", "grUF comboChanged"})
	table.insert(Event.Unit.Detail.ComboUnit, { comboChanged, "grUF", "grUF comboChanged"})
	table.insert(Event.Unit.Detail.Charge, { chargeChanged, "grUF", "grUF chargeChanged"})
	table.insert(Event.Unit.Detail.Planar, { planarChanged, "grUF", "grUF planarChanged"}) 
	table.insert(Event.Unit.Detail.Vitality, { vitalityChanged, "grUF", "grUF vitalityChanged"})  
	
	--
	-- Other Events
	--
	table.insert(Event.Unit.Detail.Level, { levelChanged, "grUF", "grUF levelChanged"})
	table.insert(Event.Unit.Detail.Guild, { guildChanged, "grUF", "grUF guildChanged"})
	table.insert(Event.Unit.Detail.Role, { roleChanged, "grUF", "grUF roleChanged" })
	-- TODO: pvp
	-- TODO: warfront
	-- others.
	
	--
	-- Casting
	--
	table.insert(Event.Unit.Castbar, { castbarChanged, "grUF", "grUF castbarChanged"})
end