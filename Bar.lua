-----------------------------------------------------------------------------------------------------------------------------
--
-- A Bar Class
--
----------------------------------------------------------------------------------------------------------------------------- 

UnitBar = {}
UnitFrame.__index = UnitFrame

--
-- UnitFrame Vars
--
UnitFrame.unitName = nil


--
-- Create a New UnitFrame
--
function UnitFrame.new()
	
   local uFrame = {}             		-- our new object
   setmetatable(uFrame, UnitFrame)      -- make UnitFrame handle lookup
   return uFrame
end

--
-- Set UnitFrame Unit
-- TODO Validate against player/player.target/player.focus/player.pet
--
function UnitFrame:setUnit(unitName)
	self.unitName = unitName
	print(self.unitName)
end