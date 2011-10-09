-- toggle debugging print outs
local debugging = false

--
-- return the "difficulty colour" of the given unit
--
function difficultyColour(unit)
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
			return 1, 0, 0
		elseif lvl >= yellowStart and lvl <= yellowEnd then
			return 1, 1, 0
		elseif lvl >= greenStart and lvl <= greenEnd then
			return 0, 1, 0
		else
			return 0.5, 0.5, 0.5
		end
	else
		-- return white if no data available
		return 1,1,1
	end
end

--
-- utility print function that can be disabled easily
--
function debugPrint(...)
	if( debugging == true) then
		print("Debug: ",...)
	end
end