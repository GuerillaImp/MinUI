-----------------------------------------------------------------------------------------------------------------------------
--
-- ComboPoints Bar
--
-- "Extends" a UnitBar as it implements:
--
-- function XXX:isUBarEnabled()
-- function XXX:setUBarEnabled( toggle )
-- function XXX:getUBarHeight()
-- function XXX:getUBarOffsetY()
--
-- This means I can add it to a UnitFrame as a "bar" and it "just works"
--
----------------------------------------------------------------------------------------------------------------------------- 
UnitComboBar = {}
UnitComboBar.__index = UnitComboBar

function UnitComboBar.new( width, height, calling, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local cpBar = {}             				-- our new object
	setmetatable(cpBar, UnitComboBar)      	-- make UnitComboBar handle lookup
	
	cpBar.anchorThis = anchorThis
	cpBar.anchorParent = anchorParent
	cpBar.parentItem = parentItem
	cpBar.offsetX = offsetX
	cpBar.offsetY = offsetY
	cpBar.width = width
	cpBar.height = height
	cpBar.maxPoints = 0

	-- rogue
	if( calling == "rogue") then
		cpBar.maxPoints = 5
	-- warrior
	else
		cpBar.maxPoints = 3
	end
	
	cpBar.enabled = true
	
	cpBar.frame = UI.CreateFrame("Frame", "comboPointsBar", parentItem)
	cpBar.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	cpBar.frame:SetWidth(cpBar.width)
	cpBar.frame:SetHeight(cpBar.height)
	cpBar.frame:SetLayer(1)
	cpBar.frame:SetVisible( cpBar.enabled )
	cpBar.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	cpBar.comboPoints = 0
	cpBar.pointBars = {}
	cpBar.pointGap = 2
	
	-- determine the bar width for a "point"
	local pointWidth = cpBar.width / cpBar.maxPoints
	pointWidth = pointWidth - cpBar.pointGap
	
	-- create "point bars"
	for i=0, (cpBar.maxPoints-1) do
		cpBar.pointBars[i] = UI.CreateFrame("Frame", "comboPoint_1", cpBar.frame)
		cpBar.pointBars[i]:SetWidth(pointWidth)
		cpBar.pointBars[i]:SetHeight(cpBar.height)
		cpBar.pointBars[i]:SetLayer(2)
		cpBar.pointBars[i]:SetVisible(false)
		
		-- rogue
		if( calling == "rogue") then
			cpBar.pointBars[i]:SetBackgroundColor(1.0, 1.0, 0.0, 0.5)
		-- warrior
		else
			cpBar.pointBars[i]:SetBackgroundColor(1.0, 0.2, 0.2, 0.5)
		end
		-- Attach Point Bars
		cpBar.pointBars[i]:SetPoint("CENTERLEFT", cpBar.frame, "CENTERLEFT", (cpBar.pointGap*i) + (pointWidth*i), 0 )
	end
	
	return cpBar
end

--
-- Is the bar enabled?
--
function UnitComboBar:isUBarEnabled()
	return self.enabled
end

--
-- Enable/Disable the bar
--
function UnitComboBar:setUBarEnabled( toggle )
	self.enabled = toggle
	self.bar:SetVisible(toggle)
end

--
-- Get Bar Height
--
function UnitComboBar:getUBarHeight()
	return self.height
end

--
-- Get OffsetY
--
function UnitComboBar:getUBarOffsetY()
	return self.offsetY
end

--
-- Set UnitComboBar Points
--
function UnitComboBar:updateComboPoints(points)
	-- disable all points
	for i=0, (self.maxPoints-1) do
		self.pointBars[i]:SetVisible(false)
	end
	-- set visible points
	for i=0, (points-1) do
		self.pointBars[i]:SetVisible(true)
	end
end
