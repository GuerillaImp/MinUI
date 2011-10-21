--
-- Test Module by Grantus
--
-- Essentially registers for pretty much damn on the player, and then updates it :P
-- 

local Test = {}
Test.__index = Test

--
-- Test:new()
--
-- @params
--		
--
function Test.new( unit )
	local test = {}             	-- our new object
	setmetatable(test, Test)    	-- make Test handle lookup
	
	--
	-- Create Test Module
	--
	test.bgColor = {r=0,g=0,b=0,a=1}
	test.hb_bgColor = {r=1,g=0,b=0,a=0.3}
	test.hb_barColor = {r=1,g=0,b=0,a=0.6}
	
	
	test.mainBox = Box.new( "TOPLEFT", gUF.context, "TOPLEFT", math.random(100,1000),  math.random(100,1000), 1, test.bgColor, "horizontal", -1 )
	test.barPanel = Panel.new( "TOPLEFT", gUF.context, "TOPLEFT", 0, 0, 0, 250, 20, {r=0,g=0,b=0,a=0}, (test.mainBox:GetLayer()+1) )
	test.healthBar = Bar.new( 250, 20, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.barPanel:GetLayer()+1)  )
	
	test.unitNameText = Text.new( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.healthBar:GetLayer()+1) )
	
	test.healthText = Text.new( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.healthBar:GetLayer()+1) )
	test.healthText:SetText("--/--")
	test.healthText2 = Text.new( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.healthBar:GetLayer()+1) )
	test.healthText2:SetText("--%")
	
	test.barPanel:AddItem( test.healthBar, "TOPLEFT", "TOPLEFT", 0, 0 )
	test.barPanel:AddItem( test.healthText2, "CENTERRIGHT", "CENTERRIGHT", 0, 0 )
	test.barPanel:AddItem( test.healthText, "CENTERLEFT", "CENTERLEFT", 0, 0 )
	test.mainBox:AddItem(test.barPanel, 0, 0, 1)
	
	test.mainBox:SetVisible(true)

	test.unit = unit

	return test
end

--
-- When the unit is available for inspection gUF will initialise this module
--
function Test:Initialise( )
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local health = details.health
		local healthMax = details.healthMax
		local healthRatio = health/healthMax
		self.healthBar:SetCurrentValue(healthRatio)
		self.healthText:SetText( string.format( "%d/%d", health, healthMax ) )
		self.healthText2:SetText( string.format( "%d%%", healthRatio*100 ) )
	end
end

--
-- Update Health
--
function Test:UpdateHealth( healthValue )
	print ( "Test: new health value", healthValue )
	
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local healthRatio = healthValue/details.healthMax
		self.healthBar:SetCurrentValue(healthRatio)
		self.healthText:SetText( string.format( "%d/%d", healthValue, details.healthMax ) )
		self.healthText2:SetText( string.format( "%d%%",healthRatio*100 ) )
	end
end

--
-- Required Function for a Module
--
-- For simplicity's sake a module must have a method called "CallBack" which can take a number of arguments
--
function Test:CallBack( eventType, value )
	if ( eventType == UNIT_AVAILABLE ) then
		print ("unit is available " , self.unit)
		self:Initialise()
	elseif ( eventType == HEALTH_UPDATE ) then
		print("health updated!")
		self:UpdateHealth ( value ) 
	end
end

--
-- Required Function for a Module
--
-- Register Callbacks with gUF
--
function Test:RegisterCallbacks()
	print ("Test:RegisterCallbacks() for unit ", self.unit, " registered events")
	table.insert(gUF_EventHooks, { HEALTH_UPDATE, self.unit, self })
	table.insert(gUF_EventHooks, { UNIT_AVAILABLE, self.unit, self })
end


--
-- *** Register this Module with gUF ***
--
table.insert(gUF_Modules, { "Test", Test })