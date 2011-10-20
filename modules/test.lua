--
-- Test Module by Grantus
--
-- Essentially registers for pretty much damn on the player, and then updates it :P
-- 

local Test = {}
Test.__index = Test

--
-- Create Test Module
--
Test.bgColor = {r=0,g=0,b=0,a=1}
Test.hb_bgColor = {r=1,g=0,b=0,a=1}
Test.hb_barColor = {r=1,g=0,b=0,a=0.5}
Test.mb_bgColor = {r=0,g=0,b=1,a=1}
Test.mb_barColor = {r=0,g=0,b=1,a=0.5}
Test.mainContainer = Container.new( 500, 500, "TOPLEFT", grUF_Core.context, "TOPLEFT", Test.bgColor, "horizontal" )
Test.healthBar = Bar.new( 250, 20, "horizontal", "right", Test.hb_bgColor, Test.hb_barColor, "media/bars/otravi.tga",grUF_Core.context )
Test.manaBar = Bar.new( 250, 20, "horizontal", "right", Test.mb_bgColor, Test.mb_barColor, "media/bars/otravi.tga",grUF_Core.context )
Test.mainContainer:AddItem(Test.healthBar, 0, 0, 1)
Test.mainContainer:AddItem(Test.manaBar, 0, 0, 1)
Test.mainContainer:SetVisible(true)


Test.unit = "player"

--
-- Update Health
--
Test.UpdateHealth = function ( healthValue )
	print ( "Test: new health value", healthValue )
	
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local healthRatio = healthValue/details.healthMax
		self.healthBar:SetCurrentValue(healthRatio)
	end
end

--
-- Update Mana
--
Test.UpdateMana = function ( manaValue )
	print ( "Test: new mana value", manaValue )
	
	local details = Inspect.Unit.Detail(self.unit)
	
	if(details)then
		local manaRatio = manaValue/details.manaMax
		self.manaBar:SetCurrentValue(manaRatio)
	end
end

--
-- *** Register with grUF Core ***
--
grUF_Core:RegisterModule("Test", Test)
grUF_Core:RegisterEvent("Test", HEALTH_UPDATE, Test.UpdateHealth, "player" ) 
grUF_Core:RegisterEvent("Test", MANA_UPDATE, Test.UpdateMana, "player" ) 
