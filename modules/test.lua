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
	
	test.bgColor2 = {r=0,g=1,b=0,a=1}
	
	--
	-- due to the way the bars work, they can be used to make all sorts of things, like our old combo points bars
	--[[
	test.comboPointsTest = Box.new( "TOPLEFT", gUF.context, "TOPLEFT", math.random(100,1000),  math.random(100,1000), 5, test.bgColor, "horizontal", "right", -1 )
	test.cp1 = Bar.new( 20, 10, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.comboPointsTest:GetLayer()+1)  )
	test.cp2 = Bar.new( 20, 10, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.comboPointsTest:GetLayer()+1)  )
	test.cp3 = Bar.new( 20, 10, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.comboPointsTest:GetLayer()+1)  )
	test.cp4 = Bar.new( 20, 10, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.comboPointsTest:GetLayer()+1)  )
	test.cp5 = Bar.new( 20, 10, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.comboPointsTest:GetLayer()+1)  )
	test.comboPointsTest:AddItem(test.cp1, 0, 0)
	test.comboPointsTest:AddItem(test.cp2, 0, 0)
	test.comboPointsTest:AddItem(test.cp3, 0, 0)
	test.comboPointsTest:AddItem(test.cp4, 0, 0)
	test.comboPointsTest:AddItem(test.cp5, 0, 0)]]
	
	--
	-- Test layouts and placing items in items
	--
	math.randomseed(Inspect.Time.Frame())
	test.itemLayoutTest = Box.new(  5, test.bgColor, "horizontal", "right", gUF.context, -1 )
	
	test.boxInBox = Box.new( 5, {r=1,g=1,b=0,a=1}, "horizontal", "left", gUF.context, (test.itemLayoutTest:GetLayer()+1) )
	test.bibText = Text.new( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.boxInBox:GetLayer()+1) )
	test.bibText:SetText("box in a box")
	test.boxInBox:AddItem( test.bibText )
	
	test.panelInBox1 = Panel.new( math.random(100,200), math.random(10,30), {r=1,g=1,b=1,a=1}, gUF.context, (test.itemLayoutTest:GetLayer()+1) )
	test.pib1 = Text.new( "media/fonts/arial_round.ttf", math.random(10,30), {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.panelInBox1:GetLayer()+1) )
	test.pib1:SetText("panel 1")
	test.panelInBox1:AddItem( test.pib1, "TOPLEFT", "TOPLEFT", 0, 0 )
	
	test.panelInBox2 = Panel.new( math.random(100,200), math.random(10,30), {r=0,g=1,b=0,a=1}, gUF.context, (test.itemLayoutTest:GetLayer()+1) )
	test.pib2 = Text.new( "media/fonts/arial_round.ttf", math.random(10,30), {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.panelInBox2:GetLayer()+1) )
	test.pib2:SetText("panel 2")
	test.panelInBox2:AddItem( test.pib2, "TOPRIGHT", "TOPRIGHT", 0, 0 )
	
	test.panelInBox3 = Panel.new( math.random(100,200), math.random(10,30), {r=0,g=1,b=1,a=1}, gUF.context, (test.boxInBox:GetLayer()+1) )
	test.pib3 = Text.new( "media/fonts/arial_round.ttf", math.random(10,30), {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.panelInBox3:GetLayer()+1) )
	test.pib3:SetText("panel 3")
	test.panelInBox3:AddItem( test.pib3, "CENTERLEFT", "CENTERLEFT", 0, 0 )
	
	test.panelInBox4 = Panel.new( math.random(100,200), math.random(10,30), {r=1,g=0,b=1,a=1}, gUF.context, (test.boxInBox:GetLayer()+1) )
	test.pib4 = Text.new( "media/fonts/arial_round.ttf", math.random(10,30), {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.panelInBox4:GetLayer()+1) )
	test.pib4:SetText("panel 4")
	test.panelInBox4:AddItem( test.pib4, "CENTERRIGHT", "CENTERRIGHT", 0, 0 )
	
	test.boxInBox:AddItem ( test.panelInBox3 ) 
	test.boxInBox:AddItem ( test.panelInBox4 )
	
	test.itemLayoutTest:AddItem ( test.boxInBox ) 
	test.itemLayoutTest:AddItem ( test.panelInBox1 ) 
	test.itemLayoutTest:AddItem ( test.panelInBox2 ) 
	
	test.itemLayoutTest:SetPoint( "TOPLEFT", gUF.context, "TOPLEFT", math.random(1,1024),math.random(1,768) )
	test.itemLayoutTest:SetVisible(true)
	
	
	
	--
	-- Test Event callbacks with health
	--
	test.mainBox = Box.new(  5, test.bgColor, "horizontal", "left", gUF.context, -1 )
	test.barPanel = Panel.new( 250, 20, {r=1,g=1,b=1,a=1}, gUF.context, (test.mainBox:GetLayer()+1) )
	
	test.randomBar1 = Bar.new( 23, 12, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.mainBox:GetLayer()+1)  )
	test.randomBar2 = Bar.new( 234, 12, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.mainBox:GetLayer()+1)  )
	test.healthBar = Bar.new( 250, 20, "horizontal", "right", test.hb_bgColor, test.hb_barColor, "media/bars/otravi.tga", gUF.context, (test.barPanel:GetLayer()+1)  )

	test.healthText = Text.new( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.healthBar:GetLayer()+1) )
	test.healthText:SetText("--/--")
	test.healthText2 = Text.new( "media/fonts/arial_round.ttf", 12, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, (test.healthBar:GetLayer()+1) )
	test.healthText2:SetText("--%")
	
	test.barPanel:AddItem( test.healthBar, "TOPLEFT", "TOPLEFT", 0, 0 )
	test.barPanel:AddItem( test.healthText2, "CENTERRIGHT", "CENTERRIGHT", 0, 0 )
	test.barPanel:AddItem( test.healthText, "CENTERLEFT", "CENTERLEFT", 0, 0 )
	
	test.mainBox:AddItem( test.barPanel )
	test.mainBox:AddItem( test.randomBar1 )
	test.mainBox:AddItem( test.randomBar2 )
	
	test.mainBox:SetPoint( "TOPLEFT", test.itemLayoutTest:GetFrame(), "BOTTOMLEFT", 10,10 ) -- attach to our other junk and see what happens
	test.mainBox:SetVisible(true)
	
	test.unit = unit

	return test
end

--
-- Refresh Function for UnitChange or UnitAvailable
--
function Test:Refresh( )
	print("Refreshing...")
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
		self:Refresh()
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