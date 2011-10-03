-----------------------------------------------------------------------------------------------------------------------------
--
-- UnitFrame Base Class
--
----------------------------------------------------------------------------------------------------------------------------- 
UnitFrame = {}
UnitFrame.__index = UnitFrame

--
-- Create a New UnitFrame
--
function UnitFrame.new( unitName, width, height, parentItem, x, y )
	local uFrame = {}             			-- our new object
	setmetatable(uFrame, UnitFrame)      	-- make UnitFrame handle lookup

	-- store values for the bar
	uFrame.width = width
	uFrame.height = height
	uFrame.unitName = unitName
	uFrame.x = x
	uFrame.y = y
	uFrame.parentItem = parentItem
	uFrame.calling = nil
	uFrame.visible = false

	-- unit frame bars
	uFrame.bars = {}
	
	-- create the frame
	uFrame.frame = UI.CreateFrame("Frame", unitName, parentItem)
	uFrame.frame:SetPoint("TOPLEFT", parentItem, "TOPLEFT", x, y ) -- frames from top left of scren
	uFrame.frame:SetWidth(uFrame.width)
	uFrame.frame:SetHeight(uFrame.height)
	uFrame.frame:SetLayer(1)
	uFrame.frame:SetVisible(uFrame.visible)
	uFrame.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
	
	function uFrame.frame.Event:LeftDown()
		self.MouseDown = true
			mouseData = Inspect.Mouse()
			self.MyStartX = uFrame.frame:GetLeft()
			self.MyStartY = uFrame.frame:GetTop()
			self.StartX = mouseData.x - self.MyStartX
			self.StartY = mouseData.y - self.MyStartY
			tempX = uFrame.frame:GetLeft()
			tempY = uFrame.frame:GetTop()
			tempW = uFrame.frame:GetWidth()
			tempH =	uFrame.frame:GetHeight()
			uFrame.frame:ClearAll()
			uFrame.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", tempX, tempY)
			uFrame.frame:SetWidth(tempW)
			uFrame.frame:SetHeight(tempH)
			self:SetBackgroundColor(0.3,0.0,0.0,0.5)
	end
	
	function uFrame.frame.Event:MouseMove()
		if self.MouseDown then
			local newX, newY
			mouseData = Inspect.Mouse()
			newX = mouseData.x - self.StartX
			newY = mouseData.y - self.StartY
			uFrame.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", newX, newY)
		end
	end
	
	function uFrame.frame.Event:LeftUp()
		if self.MouseDown then
			self.MouseDown = false
			uFrame.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
						
			-- store frame placement in saved var
			uFrame.x = uFrame.frame:GetLeft()
			uFrame.y = uFrame.frame:GetTop()
		end
	end
	

	return uFrame
end

--
-- Set the UnitFrame to visible/invisible
--
function UnitFrame:setUFrameVisible( toggle )
	self.visible = toggle
	self.frame:SetVisible( toggle )
end

--
-- Update the Health Bar of this Unit Frame
--
function UnitFrame:updateHealth( )
	-- dont update invisible frames
	if ( self.visible ) then
		local bar = self.bars["health"]
		-- if this frame has a health bar
		if (bar) then
			local unitDetails = Inspect.Unit.Detail(self.unitName)
			if (unitDetails) then
				local health = unitDetails.health
				local healthMax = unitDetails.healthMax
				local healthRatio = health/healthMax
				local healthPercent = math.floor(healthRatio * 100)
				
				local healthText = string.format("%s/%s (%s%%)", health, healthMax, healthPercent)
				bar:setUBarText(healthText)
				bar:setUBarWidthRatio(healthRatio)
			end
		end
	end
end

--
-- Update the Energy Bar of this Unit Frame
--
function UnitFrame:updateEnergy( )
	-- dont update invisible frames
	if ( self.visible ) then
		local bar = self.bars["energy"]
		-- if we have an energy bar
		if (bar) then
			local unitDetails = Inspect.Unit.Detail(self.unitName)
			if (unitDetails) then
				local power = unitDetails.energy
				local powerMax = unitDetails.energyMax
				local powerRatio = power/powerMax
				local powerPercent = math.floor(powerRatio * 100)
				
				local powerText = string.format("%s/%s (%s%%)", power, powerMax, powerPercent)
				bar:setUBarText(powerText)
				bar:setUBarWidthRatio(powerRatio)
			end
		end
	end
end

--
-- Set Text of Given Bar
-- 
function UnitFrame:setUnitBarText ( barType, text )
	local bar = self.bars[barType]
	if(bar) then
		bar:setUBarText(text)
	end
end

--
-- Return a UnitBar reference by the given name
--
function UnitFrame:getUnitBar( barType)
	local bar = self.bars[barType]
	if(bar) then
		return bar
	end
end

--
-- Add a bar to this frame
--
function UnitFrame:addUnitBar( barType, width, height, texture, fontSize,  anchorThis, anchorParent, parentItem, offsetX, offsetY )
	newBar = UnitBar.new( barType, width, height, texture, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )

	-- store bar in unit frame
	self.bars[barType] = newBar
	
	local heightRequired = 0
	-- increase frame width / height as needed
	for k,_ in pairs(self.bars) do
		local bar = self.bars[k]
		heightRequired = heightRequired + bar:getUBarHeight()
		heightRequired = heightRequired + math.abs (offsetY)
	end
	
	heightRequired = heightRequired + offsetY
	self.height = heightRequired
	self.frame:SetHeight(heightRequired)
	
	--
	-- attach event call back to this bar as appropriate
	--
	if barType == "health" then
		table.insert(Event.Unit.Detail.Health, {function () self:updateHealth() end, "MinUI", "update health bar"})
	elseif barType == "energy" then
		table.insert(Event.Unit.Detail.Energy, {function () self:updateEnergy() end, "MinUI", "update energy bar"})
	elseif barType == "mana" then
		table.insert(Event.Unit.Detail.Energy, {function () self:updateMana() end, "MinUI", "update mana bar"})
	end
end
