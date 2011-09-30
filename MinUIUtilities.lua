-- toggle debugging print outs
local debugging = false

--
-- return the "difficulty colour" of the given unit
--
function difficultyColour(unit)
	local unit = Inspect.Unit.Detail(unit)
	local player = Inspect.Unit.Detail("player")
	if unit and unit.level and player and player.level then
		local greenStart = max(player.level - 2, 1)
		local greenEnd = player.level
		local yellowStart = player.level + 1
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
	end
end

--
-- utility print function that can be disabled easily
--
function debugPrint(...)
	if( debugging == true) then
		print(...)
	end
end

--
-- print help text
--
function printHelpText()
	print("Mui Help:")
	print("/mui command [frame] [params]")
	print("Commands:")
	print("lock unlock reset configure")
	print("Frames:")
	print("player player.pet player.target player.target.target") -- todo player.focus
end