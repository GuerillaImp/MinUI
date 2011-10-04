-----------------------------------------------------------------------------------------------------------------------------
--
-- UnitFrame Base Class
--
----------------------------------------------------------------------------------------------------------------------------- 
UnitFrame = {}
UnitFrame.__index = UnitFrame

--[[
 TODO: Saved layout / colors / etc via MinUIConfig
]]

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
	
	-- unit bars this frame will attempt to add/update as required
	uFrame.barsEnabled = {}

	-- unit frame bars
	uFrame.bars = {}
	
	-- create the frame
	uFrame.frame = UI.CreateFrame("Frame", unitName, parentItem)
	uFrame.frame:SetPoint("TOPLEFT", parentItem, "TOPLEFT", x, y ) -- frames from top left of scren
	uFrame.frame:SetWidth(uFrame.width)
	uFrame.frame:SetHeight(uFrame.height)
	uFrame.frame:SetLayer(-1)
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
	debugPrint("set ", self.unitName, " visible ", toggle)
	self.visible = toggle
	self.frame:SetVisible( toggle )
end

--
-- Make the UnitFrame update all of it's values
--
function UnitFrame:update ( )
	local unitDetails = Inspect.Unit.Detail(self.unitName)

	if(unitDetails) then
		self.calling = unitDetails.calling
		self:setUFrameVisible(true)
		self:updateHealth()
		self:updateResources()
	else
		self:setUFrameVisible(false)
	end
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
-- Update the Resources Bar of this Unit Frame
--
function UnitFrame:updateResources( )
	-- dont update invisible frames
	if ( self.visible ) then
		local bar = self.bars["resources"]
		-- if we have an energy bar
		if (bar) then
			local unitDetails = Inspect.Unit.Detail(self.unitName)
			if (unitDetails) then
				if(self.calling == "rogue") then
					local energy = unitDetails.energy
					local energyMax = unitDetails.energyMax
					local energyRatio = energy/energyMax
					local energyPercent = math.floor(energyRatio * 100)
					
					local energyText = string.format("%s/%s (%s%%)", energy, energyMax, energyPercent)
					bar:setUBarText(energyText)
					bar:setUBarWidthRatio(energyRatio)
				elseif(self.calling == "warrior") then
					local power = unitDetails.power
					local powerMax = 100
					local powerRatio = power/powerMax
					local powerPercent = math.floor(powerRatio * 100)

					local powerText = string.format("%s/%s (%s%%)", power, powerMax, powerPercent)
					bar:setUBarText(powerText)
					bar:setUBarWidthRatio(powerRatio)
				elseif(self.calling == "cleric" or self.calling == "mage") then
					local mana = unitDetails.mana
					local manaMax = unitDetails.manaMax
					local manaRatio = mana/manaMax
					local manaPercent = math.floor(manaRatio * 100)

					local manaText = string.format("%s/%s (%s%%)", mana, manaMax, manaPercent)
					bar:setUBarText(manaText)
					bar:setUBarWidthRatio(manaRatio)
				-- No Calling
				else
					bar:setUBarText("")
					bar:setUBarWidthRatio(1)
				end
			end
			
			-- set correct color
			self:updateResourcesBarColor()
		end
	end
end

--
-- Set Frame Calling
--
function UnitFrame:setUFrameCalling ( calling )
	self.calling = calling
	debugPrint("Set ", self.unitName, " to calling ", self.calling)
end

--
-- Return a UnitBar reference by the given name
--[[
function UnitFrame:getUnitBar( barType )
	local bar = self.bars[barType]
	if(bar) then
		return bar
	end
end]]

--
-- Signal to the UnitFrame that we want these frames
--
function UnitFrame:enableBar( barType, toggle )
	self.barsEnabled[barType] = toggle
end

--
-- Initialise all the bars this frame has been told to enable
--
function UnitFrame:init()
	debugPrint("init")
	for barType, enabled in pairs(self.barsEnabled) do
		if ( barType == "health" and enabled ) then
			self:addHealthBar()
		elseif( barType == "resources" and enabled ) then
			self:addResourcesBar()
		end
	end
end

--
-- Set Color According to Calling Resource
--
--
-- TODO: Read Colors from MinUIConfig
--
function UnitFrame:updateResourcesBarColor()
	if (self.calling == "rogue") then
		self.bars["resources"]:setUBarColor( 0.8, 0, 0.8, 0.8 )
	elseif (self.calling == "warrior") then
		self.bars["resources"]:setUBarColor( 0.8, 0.6, 0, 0.8 )
	elseif (self.calling == "mage" or self.calling == "cleric") then
		self.bars["resources"]:setUBarColor( 0, 0, 0.8, 0.8 )
	else
		self.bars["resources"]:setUBarColor( 0, 0, 0, 0)
	end
end


--[[
function UnitFrame:updateResourcesBarTexture()
	-- Set Correct Energy Texture Based on Calling
	if (self.calling == "rogue") then
		self.bars["resources"]:setUBarTexture("rogue_energy")
	elseif (self.calling == "warrior") then
		self.bars["resources"]:setUBarTexture("warrior_energy")
	elseif (self.calling == "mage" or self.calling == "cleric") then
		self.bars["resources"]:setUBarTexture("mana")
	else
		self.bars["resources"]:setUBarTexture("none")
	end
end]]

--
-- Adds a Health UnitBar to this UnitFrame
--
function UnitFrame:addHealthBar()
	if( self.bars["health"] ) then
		debugPrint("Health Bar Exists")
		self.bars["health"]:setUBarEnabled(true)
	else
		self:addUnitBar( "health", 250, 20, 12, "TOPLEFT", "TOPLEFT", self.frame, 5, 5)
		self.bars["health"]:setUBarColor( 0, 0.8, 0, 0.8 )
	end
	
	-- enable the bar
	self.bars["health"]:setUBarEnabled(true)
	
	-- resize based on bars currently enabled
	self:resize()
end

--
-- A resources UnitBar on this UnitFrame
-- 
-- Resource will be based on the Unit's Calling
--
function UnitFrame:addResourcesBar()
	debugPrint("Add resources Bar")
	local anchorPoint = self.bars["health"]
	-- if no health bar to sit under just attach to frame (TODO: make a less hacky fix for this)
	if ( anchorPoint == nil ) then
		anchorPoint = self.frame
	end
	
	if(self.calling) then
		-- Reuse old resources bar if we have one
		if( self.bars["resources"] ) then
			debugPrint("resources Bar Exists")
			self.bars["resources"]:setUBarVisible(true)
		-- Else make a new bar for resources
		else
			self:addUnitBar( "resources", 250, 20, 12, "TOPLEFT", "BOTTOMLEFT", anchorPoint.bar, 0, 5)
		end
		
		-- set correct texture
		self:updateResourcesBarColor()
	else
		-- Reuse old bar if we have one
		if( self.bars["resources"] ) then
			debugPrint("resources Bar Exists")
			self.bars["resources"]:setUBarVisible(true)
		-- Else make a new bar for resources (in this case we have no calling so the texture remains "none")
		else
			self:addUnitBar( "resources", 250, 20, 12, "TOPLEFT", "BOTTOMLEFT", anchorPoint.bar, 0, 5)
		end
	end
	
	-- enable the bar
	self.bars["resources"]:setUBarEnabled(true)
	
	-- resize based on bars currently enabled
	self:resize()
end

--
-- Resize UnitFrame as Required
--
function UnitFrame:resize()
	local heightRequired = 0
	local offset = 0
	-- increase frame width / height as needed
	for k,_ in pairs(self.bars) do
		local bar = self.bars[k]
		if ( bar:isUBarEnabled() ) then
			heightRequired = heightRequired + bar:getUBarHeight()
			heightRequired = heightRequired + math.abs (bar:getUBarOffsetY())
			offset = bar:getUBarOffsetY()
		end
	end
	
	heightRequired = heightRequired + offset
	self.height = heightRequired
	self.frame:SetHeight(heightRequired)
	
	--debugPrint("resize?", heightRequired)
end

--
-- Attach event call back to the UnitFrame as required (remove unneeded)
--
function UnitFrame:registerEvents(barType)
	-- Unit Health
	if barType == "health" then
		table.insert(Event.Unit.Detail.Health, {function () self:updateHealth() end, "MinUI", self.unitName .. "_" .. barType})
	-- Unit Resources
	elseif barType == "resources" then
		table.insert(Event.Unit.Detail.Energy, {function () self:updateResources() end, "MinUI", self.unitName .. "_" .. barType})
		table.insert(Event.Unit.Detail.Mana, {function () self:updateResources() end, "MinUI", self.unitName .. "_" .. barType})
	end
	-- TODO Mage Charge 
	
end

--
-- Add a bar to this UnitFrame
--
function UnitFrame:addUnitBar( barType, width, height, texture, fontSize,  anchorThis, anchorParent, parentItem, offsetX, offsetY )
	debugPrint ("Adding Unit Bar", barType, " to ", self.unitName)

	newBar = UnitBar.new( barType, width, height, texture, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )

	-- store bar in unit frame
	self.bars[barType] = newBar
	
	-- resize based on bars currently enabled
	self:resize()
	
	-- update event tables based on bar type
	-- if we are polling in MinUI.lua we really don't need these
	-- self:registerEvents( barType )
end
