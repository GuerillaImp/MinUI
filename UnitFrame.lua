-----------------------------------------------------------------------------------------------------------------------------
--
-- UnitFrame Base Class
--
----------------------------------------------------------------------------------------------------------------------------- 
UnitFrame = {}
UnitFrame.__index = UnitFrame

--[[
 TODO - power is mage charge not warrior energy duh
 fix this(combine warrior/rogue into "energy" bar
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
	print("set ", self.unitName, " visible ", toggle)
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
		self:enablePowerBar()
		self:updateHealth()
		self:updateEnergy()
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
-- Update the Energy (Rogue) Bar of this Unit Frame
--
function UnitFrame:updateEnergy( )
--print("update energy")

	-- dont update invisible frames
	if ( self.visible ) then
		local bar = self.bars["energy"]
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
				end
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
-- Set Frame Calling
--
function UnitFrame:setUFrameCalling ( calling )
	self.calling = calling
	print("Set ", self.unitName, " to calling ", self.calling)
end

--
-- Return a UnitBar reference by the given name
--
function UnitFrame:getUnitBar( barType )
	local bar = self.bars[barType]
	if(bar) then
		return bar
	end
end

--
-- Adds a Health UnitBar to this UnitFrame
--
function UnitFrame:enableHealthBar()
	self:addUnitBar( "health", 250, 20, "healthy", 12, "TOPLEFT", "TOPLEFT", self.frame, 5, 5)
end

--
-- Enable the Power UnitBar on this UnitFrame
-- 
-- Power will be based on the Unit's Calling
--
function UnitFrame:enablePowerBar()
	print("Enable Power Bar")
	if(self.calling) then
		local anchorPoint = self.bars["health"]
		-- if no health bar to sit under just attach to frame (TODO: make a less hacky fix for this)
		if ( anchorPoint == nil ) then
			anchorPoint = self.frame
		end
		
		if (self.calling == "rogue") or  (self.calling == "warrior") then
			print("Adding Rogue Energy Bar")
			-- reuse old energy bar if we have one
			if( self.bars["energy"] ) then
				print("Bar Exists")
				self.bars["energy"]:setUBarVisible(true)
			-- else make a new bar for rogue energy and show that
			else
				self:addUnitBar( "energy", 250, 20, "rogue_energy", 12, "TOPLEFT", "BOTTOMLEFT", anchorPoint.bar, 0, 5)
			end
			
			self:updateEventTables("energy")
		end
	else
		print("UnitFrame has No Calling")
		self:disablePowerBar()
	end
	
	-- resize based on bars currently enabled
	self:resize()
	
	
end

--
-- If the UnitFrame doesnt have a calling this should get disabled (to stop it updating undefined power)
--
function UnitFrame:disablePowerBar()
	if ( self.bars["energy"] ) then
		self.bars["energy"]:setUBarVisible(false)
	elseif ( self.bars["power"] ) then
		self.bars["power"]:setUBarVisible(false)
	elseif ( self.bars["mana"] ) then
		self.bars["mana"]:setUBarVisible(false)
	end
	
	-- Get rid of listeners
	self:clearEnergyEvents()
		
	-- resize based on bars currently enabled
	self:resize()
end


--
-- Stop listening to Energy (Rogue/Warrior) Events
--
function UnitFrame:clearEnergyEvents()
	for key, value in pairs(Event.Unit.Detail.Energy) do
		if(value[2] == "MinUI") then
			table.remove(Event.Unit.Detail.Energy, key)
		end
	end
end

--
-- Stop listening to Mana Events
--
local function clearManaEvents()
	for key, value in pairs(Event.Unit.Detail.Mana) do
		print(value[3])
		if(value[3] == self.unitName .. "_energy" ) then
			table.remove(Event.Unit.Detail.Mana, key)
		end
	end
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
		if ( bar:isUBarVisible() ) then
			heightRequired = heightRequired + bar:getUBarHeight()
			heightRequired = heightRequired + math.abs (bar:getUBarOffsetY())
			offset = bar:getUBarOffsetY()
		end
	end
	
	heightRequired = heightRequired + offset
	self.height = heightRequired
	self.frame:SetHeight(heightRequired)
end

--
-- Attach event call back to the UnitFrame as required (remove unneeded)
--
function UnitFrame:updateEventTables(barType)
	if barType == "health" then
		table.insert(Event.Unit.Detail.Health, {function () self:updateHealth() end, "MinUI", self.unitName .. "_" .. barType})
	elseif barType == "energy" then
		table.insert(Event.Unit.Detail.Energy, {function () self:updateEnergy() end, "MinUI", self.unitName .. "_" .. barType})
	elseif barType == "power" then
		-- mage stuff
	elseif barType == "mana" then
		clearEnergyEvents()
		--table.insert(Event.Unit.Detail.Mana, {function () self:updateMana() end, "MinUI", "update mana bar"})
	end
end

--
-- Add a bar to this UnitFrame
--
function UnitFrame:addUnitBar( barType, width, height, texture, fontSize,  anchorThis, anchorParent, parentItem, offsetX, offsetY )
	print ("Adding Unit Bar", barType, " to ", self.unitName)

	newBar = UnitBar.new( barType, width, height, texture, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )

	-- store bar in unit frame
	self.bars[barType] = newBar
	
	-- resize based on bars currently enabled
	self:resize()
	
	-- update event tables based on bar type
	self:updateEventTables( barType )
end
