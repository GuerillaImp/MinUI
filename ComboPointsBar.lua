-----------------------------------------------------------------------------------------------------------------------------
--
-- ComboPoints Bar
--
----------------------------------------------------------------------------------------------------------------------------- 
ComboPointsBar = {}
ComboPointsBar.__index = ComboPointsBar

function ComboPointsBar.new( anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local cpBar = {}             				-- our new object
	setmetatable(cpBar, ComboPointsBar)      	-- make ComboPointsBar handle lookup
	
	cpBar.anchorThis = anchorThis
	cpBar.anchorParent = anchorParent
	cpBar.parentItem = parentItem
	cpBar.offsetX = offsetX
	cpBar.offsetY = offsetY
	cpBar.frame = UI.CreateFrame("Frame", "comboPointsBar", parentItem)
	cpBar.bar:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	cpBar.bar:SetWidth(uBar.width)
	cpBar.bar:SetHeight(uBar.height)
	cpBar.bar:SetLayer(1)
	cpBar.bar:SetVisible(uBar.enabled)
	cpBar.bar:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
	
	return cpBar
end



function ComboPointsBar:setComboPoints()

end
