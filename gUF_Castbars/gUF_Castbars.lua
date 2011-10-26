--
-- gUF_Castbars by Grantus
--
-- This AddOn creates and manages the castbars for gUF (player, target, focus, etc)
--
--

-- all units covered by this addon
local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--[[ Create the UnitFrames
table.insert(Event.Addon.SavedVariables.Load.End, { Units.Initialise, "gUF_Units", "gUF_Units Variables Loaded" })]]