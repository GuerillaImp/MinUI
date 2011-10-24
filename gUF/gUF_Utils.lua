gUF_Utils = {}

--
-- Get health percent colors
--
-- @params
--		percentLife number: the percentage of the unit's health that is left
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function gUF_Utils:GetHealthPercentColor ( percentLife )
	local colors = {}
	
	if (percentLife >= 66) then
		colors.backgroundColor = gUF.colors["green_background"]
		colors.foregroundColor = gUF.colors["green_foreground"]
	elseif(percentLife >= 33 and percentLife < 66) then
		colors.backgroundColor = gUF.colors["yellow_background"]
		colors.foregroundColor = gUF.colors["yellow_foreground"]
	elseif(percentLife >= 1 and percentLife < 33) then
		colors.backgroundColor = gUF.colors["red_background"]
		colors.foregroundColor = gUF.colors["red_foreground"]
	else
		colors.backgroundColor = gUF.colors["black"]
		colors.foregroundColor = gUF.colors["black"]
	end
	
	return colors
end

--
-- Get calling colors
--
-- @params
--		class string: the calling of the unit
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function gUF_Utils:GetCallingColor ( calling )
	local colors = {}
	
	if ( calling == "mage" ) then
		colors.backgroundColor = gUF.colors["mage_background"]
		colors.foregroundColor = gUF.colors["mage_foreground"]
	elseif( calling == "cleric" ) then
		colors.backgroundColor = gUF.colors["cleric_background"]
		colors.foregroundColor = gUF.colors["cleric_foreground"]
	elseif( calling == "warrior" ) then
		colors.backgroundColor = gUF.colors["warrior_background"]
		colors.foregroundColor = gUF.colors["warrior_foreground"]
	elseif( calling == "rogue" ) then
		colors.backgroundColor = gUF.colors["rogue_background"]
		colors.foregroundColor = gUF.colors["rogue_foreground"]
	else
		colors.backgroundColor = gUF.colors["black"]
		colors.foregroundColor = gUF.colors["black"]
	end
	
	return colors
end

--
-- Get "reaction" colors
--
-- @params
--		percentLife numbeR: the percentage of the unit's health that is left
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function gUF_Utils:GetReactionColor ( reaction )
	local colors = {}
	
	if ( reaction == "hostile" ) then
		colors.backgroundColor = gUF.colors["red_background"]
		colors.foregroundColor = gUF.colors["red_foreground"]
	elseif( reaction == "friendly" ) then
		colors.backgroundColor = gUF.colors["green_background"]
		colors.foregroundColor = gUF.colors["green_foreground"]
	else
		colors.backgroundColor = gUF.colors["yellow_background"]
		colors.foregroundColor = gUF.colors["yellow_foreground"]
	end
	
	return colors
end
