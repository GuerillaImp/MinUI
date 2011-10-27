-- all units covered by this addon
local allUnits = {"player","player.pet","player.target","player.target.target","focus"}

--
-- Return a settings panel for the given unit
--
function Units:GetUnitSettingsPanel( unitName )
	local unitSettingsPanel = Box.new( 10, {r=0,g=0,b=0,a=0}, "vertical", "down", gUF.context, 9 )
	
	local text = Text.new ( "media/fonts/arial_round.ttf", 26, {r=1,g=1,b=1,a=1}, "grow", 0, "shadow", gUF.context, 11 )
	text:SetText("gUF_Units Config --- TODO!")
	unitSettingsPanel:AddItem(text)
	
	
	return unitSettingsPanel
end

--
-- Get Options
--
--
function Units:GetOptions()
	Units:CheckSettings()
	
	local optionsPane = Box.new( 0, {r=0,g=0,b=0,a=0}, "horizontal", "right", gUF.context, 7 )
	local configButtonBox = Box.new( 0, {r=0,g=0,b=0,a=0}, "vertical", "down", gUF.context, 7 )
	local configPanel = Panel.new( 530, 790, {r=0,g=0,b=0,a=0.5}, gUF.context, 7 )
	
	--
	-- Buttons for Units To Configure
	--
	for _,unitName in pairs (allUnits) do
		local buttonBox = Box.new( 0, {r=0,g=0,b=0,a=0.5}, "horizontal", "right", gUF.context, 8 )
		local unitButton = UI.CreateFrame("RiftButton", "Unit Button", gUF.context)
		unitButton:SetVisible(false)
		unitButton:SetLayer(9)
		unitButton:SetText(unitName)
		buttonBox:AddItem(unitButton)
		
		function unitButton.Event:LeftPress( )	
			--print (unitName,"player button pressed")
			configPanel:RemoveItem(1)
			configPanel:AddItem(Units:GetUnitSettingsPanel( unitName ),"TOPLEFT","TOPLEFT",5,5)
			configPanel:SetVisible(true)
		end
	
		configButtonBox:AddItem(buttonBox)
	end
	
	-- Add Items
	optionsPane:AddItem(configButtonBox)
	optionsPane:AddItem(configPanel)
	
	
	local triggerButton = UI.CreateFrame("RiftButton", "gUF_Options", gUF.context)
	triggerButton:SetLayer(7)
	triggerButton:SetText("Units Config")
	
	local optionsItems = { triggerButton, optionsPane }
	
	return optionsItems
end

-- Register with gUF for options
gUF_AddOn_Config["Units"] = Units.GetOptions