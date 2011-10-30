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
		colors.backgroundColor = gUF_Colors["green_background"]
		colors.foregroundColor = gUF_Colors["green_foreground"]
	elseif(percentLife >= 33 and percentLife < 66) then
		colors.backgroundColor = gUF_Colors["yellow_background"]
		colors.foregroundColor = gUF_Colors["yellow_foreground"]
	elseif(percentLife >= 1 and percentLife < 33) then
		colors.backgroundColor = gUF_Colors["red_background"]
		colors.foregroundColor = gUF_Colors["red_foreground"]
	else
		colors.backgroundColor = gUF_Colors["black_background"]
		colors.foregroundColor = gUF_Colors["black_foreground"]
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
		colors.backgroundColor = gUF_Colors["mage_background"]
		colors.foregroundColor = gUF_Colors["mage_foreground"]
	elseif( calling == "cleric" ) then
		colors.backgroundColor = gUF_Colors["cleric_background"]
		colors.foregroundColor = gUF_Colors["cleric_foreground"]
	elseif( calling == "warrior" ) then
		colors.backgroundColor = gUF_Colors["warrior_background"]
		colors.foregroundColor = gUF_Colors["warrior_foreground"]
	elseif( calling == "rogue" ) then
		colors.backgroundColor = gUF_Colors["rogue_background"]
		colors.foregroundColor = gUF_Colors["rogue_foreground"]
	else
		colors.backgroundColor = gUF_Colors["black_background"]
		colors.foregroundColor = gUF_Colors["black_foreground"]
	end
	
	return colors
end

--
-- Get "relation" colors
--
-- @params
--		relation string: relation of the given target (hostile or friendly)
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function gUF_Utils:GetRelationColor ( relation )
	local colors = {}
	
	if ( relation == "hostile" ) then
		colors.backgroundColor = gUF_Colors["red_background"]
		colors.foregroundColor = gUF_Colors["red_foreground"]
	elseif( relation == "friendly" ) then
		colors.backgroundColor = gUF_Colors["green_background"]
		colors.foregroundColor = gUF_Colors["green_foreground"]
	else
		colors.backgroundColor = gUF_Colors["yellow_background"]
		colors.foregroundColor = gUF_Colors["yellow_foreground"]
	end
	
	return colors
end

--
-- Get "buff" color
--
-- @params
--		buffType string: the buff type (debuff/poison/disease/curse/buff)
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function gUF_Utils:GetBuffColor( buffType )
	local colors = {}
	
	if ( buffType == "buff" ) then
		colors.backgroundColor = gUF_Colors["buff_background"]
		colors.foregroundColor = gUF_Colors["buff_foreground"]
	elseif( buffType == "debuff" ) then
		colors.backgroundColor = gUF_Colors["debuff_background"]
		colors.foregroundColor = gUF_Colors["debuff_foreground"]
	elseif( buffType == "poison" ) then
		colors.backgroundColor = gUF_Colors["poison_background"]
		colors.foregroundColor = gUF_Colors["poison_foreground"]
	elseif( buffType == "disease" ) then
		colors.backgroundColor = gUF_Colors["disease_background"]
		colors.foregroundColor = gUF_Colors["disease_foreground"]
	elseif( buffType == "curse" ) then
		colors.backgroundColor = gUF_Colors["curse_background"]
		colors.foregroundColor = gUF_Colors["curse_foreground"]
	end
	
	return colors
end


--
-- Get "calling" resource color
--
-- @params
--		calling string: the calling (mage/cleric/warrior/rogue)
--
-- @returns
--		colors table: contains two other tables, colors.backgroundColor and colors.foregroundColor for the background and solid components of the bar
--
function gUF_Utils:GetResourcesColor( calling )
	local colors = {}
	
	if ( calling == "warrior" ) then
		colors.backgroundColor = gUF_Colors["power_background"]
		colors.foregroundColor = gUF_Colors["power_foreground"]
	elseif( calling == "mage" or calling == "cleric" ) then
		colors.backgroundColor = gUF_Colors["mana_background"]
		colors.foregroundColor = gUF_Colors["mana_foreground"]
	elseif( calling == "rogue" ) then
		colors.backgroundColor = gUF_Colors["energy_background"]
		colors.foregroundColor = gUF_Colors["energy_foreground"]
	end
	
	return colors
end

--
-- Get "difficulty" color
--
-- @params
--		unit table: the unit whose difficulty is to be assessed
--
-- @returns
--		color table: with the difficulty color of the given unit
--
function gUF_Utils:GetDifficultyColor( unit )
	local color = {}
	
	local unit = Inspect.Unit.Detail(unit)
	local player = Inspect.Unit.Detail("player")
	if unit and unit.level and player and player.level then
		local greenStart = 0
		-- ripped fom WoW, since i can't find rifts forumla
		if player.level <= 5 then
			greenStart = 0
		elseif player.level > 5 and player.level <= 49 then
			greenStart = player.level - math.floor(player.level/10) - 5
		elseif player.level == 50 then
			greenStart = 40
		end
		local greenEnd = player.level -2
		local yellowStart = player.level -2
		local yellowEnd = player.level + 2
		local redStart = player.level + 3
		local lvl = unit.level
		
		if type(lvl) ~= "number" or lvl >= redStart  then
			return gUF_Colors["red_foreground"]
		elseif lvl >= yellowStart and lvl <= yellowEnd then
			return gUF_Colors["yellow_foreground"]
		elseif lvl >= greenStart and lvl <= greenEnd then
			return gUF_Colors["green_foreground"]
		else
			return gUF_Colors["grey_foreground"]
		end
	else
		return gUF_Colors["white"]
	end
	
	return color
end


--
-- Given a number of seconds, return a shortened version of that number. For instance, 60 seconds becomes 1m, 3600 becomes 1hr, etc.
--
-- @params
--		inputNumber number: the number of seconds to be shortened
--
-- @returns
--		shortenedTime string: the shortened time string (h:m:s)
--
function gUF_Utils:GetShortTime ( inputTime )
	local shortenedTime = ""

	local hours = math.floor(inputTime / 3600)
	local minutes = math.floor(inputTime / 60)
	local seconds = math.floor(inputTime) % 60

	-- if we have hours
	if ( inputTime >= 3600 ) then
		shortenedTime = shortenedTime .. string.format("%.2f:", inputTime / 3600)
	end
	if  ( inputTime > 59 ) then
		shortenedTime = shortenedTime .. string.format("%.2f:", inputTime / 60)
	end
	if ( inputTime > 0 ) then
		shortenedTime = shortenedTime .. string.format("%.1f", inputTime % 60)
	end
	
	return shortenedTime
end


--
-- Given a number, return a string that shows that number in a shortened fashion if required.
-- Examples: 1000000 comes 1m, 10000 becomes 10k, etc
--
-- @params
--		inputNumber number: the number to be shortened
--
-- @returns
--		shortenedNumber string: the shortened number string
--
function gUF_Utils:GetShortValue( inputNumber )
	local shortenedNumber = ""
	
	if ( inputNumber ) then
		if(inputNumber >= 1000000)then
			shortenedNumber = shortenedNumber ..  string.format("%.2fm", inputNumber / 1000000)
		elseif(inputNumber >= 10000)then
			shortenedNumber = shortenedNumber ..  string.format("%.2fk", inputNumber / 1000)
		else
			shortenedNumber = shortenedNumber ..  string.format("%d", inputNumber)
		end
	else
		shortenedNumber = "NaN"
	end
	
	return shortenedNumber
end

--
-- Returns a string representation of the percentage A is of B
--
-- @params
--		numberA number: the numerator
--		numberB number: the denominator
--
-- @returns
--		percentage string: string representation of the percentage value
--
function gUF_Utils:GetPercentage ( numberA, numberB )
	local percentageString = ""
	
	--print (numberA, numberB)
	
	if ( numberA and numberB ) then
		percentageString = string.format("%d", math.ceil( (numberA/numberB)*100))
	else
		percentageString = "NaN"
	end
	
	return percentageString
end


--
-- Given an input string with format items such as abilityName, timeRemainingShort, etc return a string formatted
-- the actual castbar details given in castBar
--
-- @params
--		inputString string: the string formatted with "detailName" components to be substituted the full list of supported substitutions is:
--							abilityName - will be replaced by the ability's name
--							casttimeShort - will be replaced by the ability's cast time short value
--							casttimeAbs - will be replaced by the ability's absolute cast time value
--							remainingShort - will be replaced by the ability's remaining time short value
--							remainingAbs - will be replaced by the ability's remaining time absolute value
--
--		castBar table: a castBar table provided by Inspect.Unit.Castbar( unitID )
--
-- @return
--		outputString string: a string with the components substituted for their actual values
--
function gUF_Utils:CreateCastingDetailsString( inputString, castbar )
	
	-- Substitute items extracted from castbar table
	if ( castbar ) then
		-- abilityName
		if ( castbar.abilityName ) then
			local newString, numSubs = string.gsub ( inputString, "abilityName", castbar.abilityName )
			inputString = newString
		end
		-- remaining
		if ( castbar.remaining ) then
			local newString, numSubs = string.gsub ( inputString, "remainingShort", gUF_Utils:GetShortTime(castbar.remaining) )
			inputString = newString
			
			local newString, numSubs = string.gsub ( inputString, "remainingAbs", castbar.remaining )
			inputString = newString
		end
		-- duration
		if ( castbar.duration ) then
			local newString, numSubs = string.gsub ( inputString, "durationShort", gUF_Utils:GetShortTime(castbar.duration) )
			inputString = newString
			
			local newString, numSubs = string.gsub ( inputString, "durationAbs", castbar.duration )
			inputString = newString
		end
	end
	
	
	return inputString
end


--
-- Given an input string with format items such as [name],[healthShort],[healthPercent] substitute those values with
-- the actual unit details given in unitDetails
--
-- @params
--		inputString string: the string formatted with "detailName" components to be substituted the full list of supported substitutions is:
--							name - will be repaced by the unit's name
--							healthShort - shortened version of the unit's health
--							healthMaxShort - shortened version of the unit's health max
--							healthAbs - absolute value of the unit's health
--							healthMaxAbs - absolute value of the unit's health max
--							healthPercent - percentage of the unit's health
--							resourceShort, resourceMaxShort, resourceAbs, resourceMaxAbs, resourcePercent - get the resource (mana/power/energy) texts as per health
-- 							guild,level,planar,vitality,afk,calling,warfont,offline -- as per unit details
--
--		unitDetails table: a unitDetails table provided by Inspect.Unit.Detail(unitID)
--
-- @return
--		outputString string: a string with the components substituted for their actual values
--
function gUF_Utils:CreateUnitDetailsString( inputString, unitDetails )
	-- if unit details are non nil
	if ( unitDetails ) then
		--
		-- I can't think of a "pretty" way to do this other than just check a whole bunch of keywords, and replace
		-- with the actual value as we go along
		--
		
		-- name
		if ( unitDetails.name ) then
			local newString, numSubs = string.gsub ( inputString, "name", unitDetails.name )
			inputString = newString
		end
		
		-- guild
		if ( unitDetails.guild ) then
			local newString, numSubs = string.gsub ( inputString, "guild", "<".. unitDetails.guild ..">")
			inputString = newString
		else
			local newString, numSubs = string.gsub ( inputString, "guild",  "" )
			inputString = newString
		end
		
		-- level
		if ( unitDetails.level ) then
			local newString, numSubs = string.gsub ( inputString, "level",  unitDetails.level)
			inputString = newString
		end
		
		-- planar charges
		if ( unitDetails.planar ) then
			local newString, numSubs = string.gsub ( inputString, "planar",  unitDetails.planar)
			inputString = newString
		else
			local newString, numSubs = string.gsub ( inputString, "planar",  "" )
			inputString = newString			
		end
		
		-- vitality
		if ( unitDetails.vitality ) then
			local newString, numSubs = string.gsub ( inputString, "vitality",  unitDetails.vitality)
			inputString = newString
		else
			local newString, numSubs = string.gsub ( inputString, "vitality",  "" )
			inputString = newString					
		end
		
		-- afk
		if ( unitDetails.afk ) then
			local newString, numSubs = string.gsub ( inputString, "afk",  "(afk)")
			inputString = newString
		else
			local newString, numSubs = string.gsub ( inputString, "afk",  "")
			inputString = newString	
		end
		
		-- offline
		if ( unitDetails.offline ) then
			local newString, numSubs = string.gsub ( inputString, "offline",  "(offline)")
			inputString = newString
		else
			local newString, numSubs = string.gsub ( inputString, "offline",  "")
			inputString = newString
		end
		
		-- warfront
		if ( unitDetails.warfont ) then
			local newString, numSubs = string.gsub ( inputString, "warfont",  "(in warfront)")
			inputString = newString
		else
			local newString, numSubs = string.gsub ( inputString, "warfont",  "")
			inputString = newString
		end
	
		
		-- health
		if ( unitDetails.health ) then
			-- healthShort
			local newString, numSubs = string.gsub ( inputString, "healthShort", gUF_Utils:GetShortValue(unitDetails.health) )
			inputString = newString
			
			-- healthAbs
			local newString, numSubs = string.gsub ( inputString, "healthAbs", unitDetails.health )
			inputString = newString
		end
		
		-- healthMax
		if ( unitDetails.healthMax ) then
			-- healthMaxShort
			local newString, numSubs = string.gsub ( inputString, "healthMaxShort", gUF_Utils:GetShortValue(unitDetails.healthMax) )
			inputString = newString
			
			-- healthMaxAbs
			local newString, numSubs = string.gsub ( inputString, "healthMaxAbs", unitDetails.healthMax )
			inputString = newString
		
		end
		
		-- healthPercent
		if ( unitDetails.health and unitDetails.healthMax ) then
			local newString, numSubs = string.gsub ( inputString, "healthPercent", gUF_Utils:GetPercentage( unitDetails.health, unitDetails.healthMax ) )
			inputString = newString
		end
		
		-- charge
		if ( unitDetails.charge ) then
			local newString, numSubs = string.gsub ( inputString, "currentCharge", unitDetails.charge )
			inputString = newString
			
			local newString, numSubs = string.gsub ( inputString, "chargeMax", 100 )
			inputString = newString
			
			local newString, numSubs = string.gsub ( inputString, "chargePercent", gUF_Utils:GetPercentage( unitDetails.charge, 100 ) )
			inputString = newString
		end
		
		-- if this details set has a calling, then update texts that are calling based
		if ( unitDetails.calling ) then
			local calling = unitDetails.calling
			
			-- calling sub
			local newString, numSubs = string.gsub ( inputString, "calling", calling )
			inputString = newString
			
			local resource = 0
			local resourceMax = 0
			
			if (calling == "mage" or calling == "cleric") then
				resource = unitDetails.mana
				resourceMax = unitDetails.manaMax
			elseif(calling == "rogue") then
				resource = unitDetails.energy
				resourceMax = unitDetails.energyMax
			elseif(calling == "warrior") then
				resource = unitDetails.power
				resourceMax = 100
			end
			
			-- resource
			if ( resource and resourceMax ) then
				-- resourceShort
				local newString, numSubs = string.gsub ( inputString, "resourceShort", gUF_Utils:GetShortValue(resource) )
				inputString = newString
				
				-- resourceAbs
				local newString, numSubs = string.gsub ( inputString, "resourceAbs", resource )
				inputString = newString

				-- resourceMaxShort
				local newString, numSubs = string.gsub ( inputString, "resourceMaxShort", gUF_Utils:GetShortValue(resourceMax) )
				inputString = newString
				
				-- resourceMaxAbs
				local newString, numSubs = string.gsub ( inputString, "resourceMaxAbs", resourceMax )
				inputString = newString
			
				-- resourcePercent
				local newString, numSubs = string.gsub ( inputString, "resourcePercent", gUF_Utils:GetPercentage( resource, resourceMax ) )
				inputString = newString
			end
		else
			-- calling sub
			local newString, numSubs = string.gsub ( inputString, "calling", "" )
			inputString = newString	
		end
		
		
	end

	return inputString
end


-- @returns a fake Inspect.Unit.Details table
function gUF_Utils:GenerateSimulatedUnit()
	local health = math.random(1,1000000)
	local healthMax = math.random(1,1000000)
	local mana = math.random(1,1000000)
	local manaMax = math.random(1,1000000)
	
	if( healthMax < health )then
		local healthMaxDiff = health - healthMax
		healthMax = healthMax + healthMaxDiff
	end
	if( manaMax < mana )then
		local manaMaxDiff = mana - manaMax
		manaMax = manaMax + manaMaxDiff
	end
	
	-- eventually have EVERYTHING in here (casting, etc, etc, etc)
	details = {}
	details.name = "TestUnit"
	details.calling = "rogue"
	details.relation = "hostile"
	details.mana = mana
	details.manaMax = manaMax
	details.health = mana
	details.healthMax = manaMax
	details.planar = math.random(1,3)
	details.vitality = math.random(0,100)
	details.guild = "awesome guild"
	details.role = "tank"
	details.offline = true
	details.afk = true
	details.warfont = true
	details.pvp = true
	details.level = math.random(1,50)
	details.charge = math.random(1,100)
	details.energy = math.random(1,100)
	details.energyMax = 100
	details.power = math.random(1,100)
	details.combo = math.random(1,5)
	details.comboUnit = "player.target"
	
	return details
end

-- @returns a fake Inspect.Unit.Castbat table
function gUF_Utils:GenerateSimulatedCastbar()
	local remaining = math.random(1,5)
	local duration = math.random(5,10)
	
	-- castbar details
	details = {}
	details.abilityName = "Awesome Spell"
	details.ability = nil
	details.remaining = remaining
	details.duration = duration
	details.uninterruptible = false
	details.channeled = false
	
	return details
end







