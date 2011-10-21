--
-- HealthBar Module by Grantus
--
-- Registers for Health Updates and Displays it
--[[

local HealthBar = {}
HealthBar.__index = HealthBar

--
-- HealthBar:new()
--
-- @params
--		
--
function HealthBar.new( unit )
	local test = {}             	-- our new object
	setmetatable(test, HealthBar)    	-- make HealthBar handle lookup
	
	--
	-- Create HealthBar Module
	--
	test.bgColor = {r=0,g=0,b=0,a=1}
	test.hb_bgColor = {r=1,g=0,b=0,a=1}
	test.hb_barColor = {r=1,g=0,b=0,a=0.5}
	test.mainBox = Box.new( 500, 500, "TOPLEFT", gUF.context, "TOPLEFT", test.bgColor, "horizontal" )
	test.healthBar = Bar.new( 250, 20, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context )
	test.mainBox:AddItem(test.healthBar, 0, 0, 1)
	test.mainBox:SetVisible(true)

	test.unit = unit

	return test
end

--
-- Update Health
--
function HealthBar:UpdateHealth( healthValue )
	print ( "HealthBar: new health value", healthValue )
	
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local healthRatio = healthValue/details.healthMax
		self.healthBar:SetCurrentValue(healthRatio)
	end
end

--
-- Required Function for a Module
--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function HealthBar:CallBack( eventType, value )
	if ( eventType == HEALTH_UPDATE ) then
		print("health updated!")
		self:UpdateHealth ( value ) 
	end
end

--
-- Required Function for a Module
--
-- Register Callbacks with gUF
--
function HealthBar:RegisterCallbacks()
	print ("HealthBar:RegisterCallbacks() for unit ", self.unit, " registered events")
	table.insert(gUF_EventHooks, { HEALTH_UPDATE, self.unit, self })
end


--
-- *** Register this Module with gUF ***
--
--table.insert(gUF_Modules, { "HealthBar", HealthBar })
]]