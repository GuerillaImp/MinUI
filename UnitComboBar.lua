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
	cpBar.enabled = true

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
	
	
	
	cpBar.pointBars = {}
	cpBar.pointBarsTextures = {}
	cpBar.pointGap = 2
	
	-- determine the bar width for a "point"
	local pointWidth = cpBar.width / cpBar.maxPoints
	pointWidth = pointWidth - cpBar.pointGap
	
	-- create "point bars"
	for i=0, (cpBar.maxPoints-1) do
		cpBar.pointBars[i] = UI.CreateFrame("Frame", "comboPoint_"..i, cpBar.frame)
		cpBar.pointBars[i]:SetWidth(pointWidth)
		cpBar.pointBars[i]:SetHeight(cpBar.height)
		cpBar.pointBars[i]:SetLayer(2)
		cpBar.pointBars[i]:SetVisible(false)
		-- texture
		cpBar.pointBarsTextures[i]  = UI.CreateFrame("Texture", "comboPoint_texture_"..i, cpBar.frame)
		if ( MinUIConfig.barTexture ) then
			cpBar.pointBarsTextures[i]:SetTexture("MinUI", "Media/"..MinUIConfig.barTexture..".tga")
		else
			cpBar.pointBarsTextures[i]:SetTexture("MinUI", "Media/Aluminium.tga")
		end
		cpBar.pointBarsTextures[i]:SetWidth(pointWidth)
		cpBar.pointBarsTextures[i]:SetLayer(1)
		cpBar.pointBarsTextures[i]:SetHeight(cpBar.height)
		cpBar.pointBarsTextures[i]:SetVisible(false)
		
		-- rogue
		if( calling == "rogue") then
			cpBar.pointBars[i]:SetBackgroundColor(1.0, 1.0, 0.0, 0.5)
		-- warrior
		else
			cpBar.pointBars[i]:SetBackgroundColor(1.0, 0.2, 0.2, 0.5)
		end
		-- Attach Point Bars
		cpBar.pointBars[i]:SetPoint("CENTERLEFT", cpBar.frame, "CENTERLEFT", (cpBar.pointGap*i) + (pointWidth*i), 0 )
		cpBar.pointBarsTextures[i]:SetPoint("CENTERLEFT", cpBar.frame, "CENTERLEFT", (cpBar.pointGap*i) + (pointWidth*i), 0 )
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
-- Enable/Disable the frame/bar
--
function UnitComboBar:setUBarEnabled( toggle )
	self.enabled = toggle
	self.frame:SetVisible(toggle)
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
	-- hide all points
	for i=0, (self.maxPoints-1) do
		self.pointBars[i]:SetVisible(false)
		self.pointBarsTextures[i]:SetVisible(false)
	end
	
	-- guard against people adding comboPoints bar to things they shouldnt
	if (points) then
		-- set visible points
		if (points > 0) then
			for i=0, (points-1) do
				self.pointBars[i]:SetVisible(true)
				self.pointBarsTextures[i]:SetVisible(true)
			end
		end
	end
end
