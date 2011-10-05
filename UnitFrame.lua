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
	
	-- buffbars
	uFrame.buffs = nil
	uFrame.debuffs = nil
	
	-- castbar
	uFrame.castbar = nil -- TODO
	
	-- the next "thing" a UnitBar (or equivillent) should anchor on
	uFrame.nextAnchor = nil
	
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
	uFrame.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
	
	--
	-- Mouse Interaction Code
	--
	-- For now we just support dragging of frames when unlocked
	--
	function uFrame.frame.Event:LeftDown()
		if(MinUIConfig.unitFramesLocked == false) then
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
	end
	
	function uFrame.frame.Event:MouseMove()
		if(MinUIConfig.unitFramesLocked == false) then
			if self.MouseDown then
				local newX, newY
				mouseData = Inspect.Mouse()
				newX = mouseData.x - self.StartX
				newY = mouseData.y - self.StartY
				uFrame.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", newX, newY)
			end
		end
	end
	
	function uFrame.frame.Event:LeftUp()
		if(MinUIConfig.unitFramesLocked == false) then
			if self.MouseDown then
				self.MouseDown = false
				uFrame.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
							
				-- store frame placement in saved var
				uFrame.x = uFrame.frame:GetLeft()
				uFrame.y = uFrame.frame:GetTop()
				
				MinUIConfig.frames[uFrame.unitName].x = uFrame.x
				MinUIConfig.frames[uFrame.unitName].y = uFrame.y
			end
		end
	end
	

	return uFrame
end

--
-- Set the UnitFrame to visible/invisible
--
function UnitFrame:setUFrameVisible( toggle )
	--print("set ", self.unitName, " visible ", toggle)
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
		
		for _,barType in pairs(self.barsEnabled) do
			-- only update what is actually enabled on this unit frame
			if(barType == "health") then
				self:updateHealth()
			end
			if(barType == "resources") then
				self:updateResources()
			end
			if(barType == "comboPointsBar") then
				self:updateComboPointsBar()
			end
			if(barType == "text") then
				self.bars["text"]:updateTextItems()
			end
			if(barType == "charge") then
				self:updateChargeBar()
			end
		end
		
		-- Target Reaction Colours (Expand this)
		if( self.unitName == "player.target" ) then
			if ( unitDetails.relation == "friendly" ) then
				self.frame:SetBackgroundColor(0,0.1,0, 0.3)
			elseif( unitDetails.relation == "hostile" ) then
				self.frame:SetBackgroundColor(0.1,0,0.0,0.3)
			else
				self.frame:SetBackgroundColor(0.1,0.1,0.0,0.3)
			end
		end
	else
		self:setUFrameVisible(false)
	end
end


--
-- Add Buff Bars to the UnitFrame
--
-- buffType == buff/debuff
-- visibilityOptions == player/all/curable
-- lengthThreshold == max time (i.e 30 secs or less)
--
--
function UnitFrame:addBuffBars( buffType, visibilityOptions, lengthThreshold, location )
	local bbars = nil
	local fontSize = 12
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local itemOffset =  MinUIConfig.frames[self.unitName].itemOffset
	
	-- get font size
	if (buffType == "buffs")then
		fontSize = MinUIConfig.frames[self.unitName].buffFontSize
	elseif (buffType == "debuffs")then
		fontSize = MinUIConfig.frames[self.unitName].debuffFontSize
	end
	
	if( location == "above") then
		bbars = UnitBuffBars.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "up", barWidth, fontSize, "BOTTOMCENTER", "TOPCENTER", self.frame, itemOffset, itemOffset )
	elseif ( location == "below") then
		bbars = UnitBuffBars.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "down", barWidth, fontSize, "TOPCENTER", "BOTTOMCENTER", self.frame, itemOffset, itemOffset )
	end
	
	-- store frame
	if (buffType == "buffs")then
		self.buffs = bbars
	elseif (buffType == "debuffs")then
		self.debuffs = bbars
	end
	
	-- TODO: add more positions if requested
end

function UnitFrame:resetBuffBars()
	if(self.buffs) then
		self.buffs:resetBuffBars(time)
	end
	if(self.debuffs)  then
		self.debuffs:resetBuffBars(time)
	end
end

function UnitFrame:refreshBuffBars(time)
	if(self.buffs) then
		self.buffs:update(time)
	end
	if(self.debuffs)  then
		self.debuffs:update(time)
	end
end

function UnitFrame:tickBuffBars(time)
	if(self.buffs) then
		self.buffs:tickBars(time)
	end
	if(self.debuffs)  then
		self.debuffs:tickBars(time)
	end
end

--
-- Update the Combo Points Bar
--
function UnitFrame:updateComboPointsBar()
	-- dont update invisible frames
	if ( self.visible ) then
		local bar = self.bars["comboPointsBar"]
		if (bar) then
			-- combo points only available for player
			local unitDetails = Inspect.Unit.Detail("player")
			if (unitDetails) then
				local points = unitDetails.combo
				bar:updateComboPoints(points)
			end
		end
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
				
				local healthText = string.format("%s/%s", health, healthMax)
				bar:setUBarText(healthText)
				bar:setUBarWidthRatio(healthRatio)
				
				-- set correct color
				self:updateHealthBarColor(healthPercent)
			end
		end
	end
end

--
-- Update the Charge Bar of this Unit Frame
--
function UnitFrame:updateChargeBar( )
	-- dont update invisible frames
	if ( self.visible ) then
		local bar = self.bars["charge"]
		-- if this frame has a charge bar
		if (bar) then
			local unitDetails = Inspect.Unit.Detail(self.unitName)
			if (unitDetails) then
				local charge = unitDetails.charge
				local chargeMax = 100 -- TODO: can mages go over 100 charge?
				local chargeRatio = charge/chargeMax
				local chargePercent = math.floor(chargeRatio * 100)
				
				local chargeText = string.format("%s/%s", charge,chargeMax)
				--print(chargeText)
				bar:setUBarText(chargeText)
				bar:setUBarWidthRatio(chargeRatio)
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
					
					local energyText = string.format("%s/%s)", energy, energyMax)
					bar:setUBarText(energyText)
					bar:setUBarWidthRatio(energyRatio)
				elseif(self.calling == "warrior") then
					local power = unitDetails.power
					local powerMax = 100
					local powerRatio = power/powerMax
					local powerPercent = math.floor(powerRatio * 100)

					local powerText = string.format("%s/%s", power, powerMax)
					bar:setUBarText(powerText)
					bar:setUBarWidthRatio(powerRatio)
				elseif(self.calling == "cleric" or self.calling == "mage") then
					local mana = unitDetails.mana
					local manaMax = unitDetails.manaMax
					local manaRatio = mana/manaMax
					local manaPercent = math.floor(manaRatio * 100)

					local manaText = string.format("%s/%s", mana, manaMax)
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
-- Set Color According to Calling Resource
--
--
-- TODO: Read Colors from MinUIConfig
--
function UnitFrame:updateResourcesBarColor()
	if (self.calling == "rogue") then
		self.bars["resources"]:setUBarColor( 0.7, 0, 0.7, 0.6)
	elseif (self.calling == "warrior") then
		self.bars["resources"]:setUBarColor( 0.7, 0.5, 0, 0.6 )
	elseif (self.calling == "mage" or self.calling == "cleric") then
		self.bars["resources"]:setUBarColor( 0, 0.2, 0.7, 0.6 )
	else
		self.bars["resources"]:setUBarColor( 0, 0, 0, 0)
	end
end

--
-- Set Health Color According to Percentage
--
--
-- TODO: Read Colors from MinUIConfig
--
function UnitFrame:updateHealthBarColor(percentage)
	if (percentage >= 66) then
		self.bars["health"]:setUBarColor( 0.0, 0.7, 0.0, 0.6 )
	elseif(percentage >= 33 and percentage <= 66) then
		self.bars["health"]:setUBarColor( 0.7, 0.7, 0.0, 0.6 )
	elseif(percentage >= 1 and percentage <= 33) then
		self.bars["health"]:setUBarColor( 0.7, 0.0, 0.0, 0.6 )
	else
		self.bars["health"]:setUBarColor( 0.0, 0.0, 0.0, 0.6 )
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
-- Signal to the UnitFrame that we want these frames
--
function UnitFrame:enableBar( position, barType )
	---print("enabling bar", barType," position ", position, " on ", self.unitName)
	self.barsEnabled[position] = barType
end

--
-- Initialise all the bars this frame has been told to enable
--
function UnitFrame:createEnabledBars()
--print("Creating enabled bars")
	
	for _,barType in pairs(self.barsEnabled) do
		if ( barType == "health" ) then
			self:addHealthBar()
		end
		if( barType == "resources" ) then
			self:addResourcesBar()
		end
		if( barType == "charge" ) then
			self:addChargeBar()
		end
		if( barType == "comboPointsBar" ) then
			self:addComboPointsBar()
		end
		if( barType == "text" ) then
			self:addUnitTextBar()
		end
	end
end

--
-- Tell this UnitFrame to shwo the given text on the UnitFrame's UnitText bar (if it has one)
--
function UnitFrame:showText(textItem) --TODO: add ordering for text items
	-- if we actually have a text bar
	if (self.bars["text"]) then
		self.bars["text"]:addTextItem(textItem)
	end
end

--
-- Add a Combo Points Bar
--
function UnitFrame:addComboPointsBar()
	debugPrint("Add combo points bar", self.unitName)
	
	-- base on player's calling ALWAYS
	local details = Inspect.Unit.Detail("player")
	
	if(details) then
		local playerCalling = details.calling
		
		-- values from config
		local barWidth = MinUIConfig.frames[self.unitName].barWidth
		local barHeight = MinUIConfig.frames[self.unitName].comboPointsBarHeight
		local itemOffset = MinUIConfig.frames[self.unitName].itemOffset
		
		-- if we can find the player calling (sometimes just doesnt work)
		if(playerCalling) then
			-- we have an anchor point
			if(self.nextAnchor) then
				self.bars["comboPointsBar"] = UnitComboBar.new( barWidth, barHeight, playerCalling, "TOPLEFT", "BOTTOMLEFT", self.nextAnchor, 0, itemOffset )
				-- store anchor
				self.nextAnchor = self.bars["comboPointsBar"].frame
			-- anchor to top left of frame
			else
				self.bars["comboPointsBar"] = UnitComboBar.new( barWidth, barHeight, playerCalling, "TOPLEFT", "TOPLEFT", self.frame, itemOffset, itemOffset )
				-- store anchor
				self.nextAnchor = self.bars["comboPointsBar"].frame
			end
			
			self:resize()
		end
	end
end

--
-- Adds a Health UnitBar to this UnitFrame
--
function UnitFrame:addUnitTextBar()
	debugPrint("Add unit text bar", self.unitName)
	
	-- values from config
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local fontSize = MinUIConfig.frames[self.unitName].unitTextFontSize
	local itemOffset = MinUIConfig.frames[self.unitName].itemOffset

	-- we have an anchor point
	if(self.nextAnchor) then
		-- add unit text bar
		self.bars["text"] = UnitText.new( barWidth, fontSize, self.unitName, "TOPLEFT", "BOTTOMLEFT", self.nextAnchor, 0, itemOffset )
		-- store anchor
		self.nextAnchor = self.bars["text"].frame
	-- anchor to top left of frame
	else
		-- add unit text bar
		self.bars["text"] = UnitText.new( barWidth, fontSize, self.unitName, "TOPLEFT", "TOPLEFT", self.frame, itemOffset, itemOffset )
		-- store anchor
		self.nextAnchor = self.bars["text"].frame
	end
	
	-- resize based on bars currently enabled
	self:resize()
end

--
-- Adds a Health UnitBar to this UnitFrame
--
function UnitFrame:addHealthBar()
--	print("Add health bar", self.unitName)

	
	-- values from config
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local barHeight = MinUIConfig.frames[self.unitName].barHeight
	local fontSize = MinUIConfig.frames[self.unitName].barFontSize
	local itemOffset = MinUIConfig.frames[self.unitName].itemOffset

	-- we have an anchor point
	if(self.nextAnchor) then
		-- add health bar
		self:addUnitBar( "health", barWidth, barHeight, fontSize, "TOPLEFT", "BOTTOMLEFT", self.nextAnchor, 0, itemOffset)
		-- enable it
		self.bars["health"]:setUBarEnabled(true)
		-- store anchor
		self.nextAnchor = self.bars["health"].bar
	-- anchor to top left of frame
	else
		-- add health bar
		self:addUnitBar( "health", barWidth, barHeight, fontSize, "TOPLEFT", "TOPLEFT", self.frame, itemOffset, itemOffset)
		-- enable it
		self.bars["health"]:setUBarEnabled(true)
		-- store anchor
		self.nextAnchor = self.bars["health"].bar
	end
	
	-- resize based on bars currently enabled
	self:resize()
end

--
-- A charge bar for a Mage calling class
--
function UnitFrame:addChargeBar()
	--print("Add charge Bar", self.unitName)
	
	-- values from config
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local barHeight = MinUIConfig.frames[self.unitName].mageChargeBarHeight
	local fontSize = MinUIConfig.frames[self.unitName].mageChargeFontSize
	local itemOffset = MinUIConfig.frames[self.unitName].itemOffset
	
	if(self.nextAnchor) then
		-- add resources bar
		self:addUnitBar( "charge", barWidth, barHeight, fontSize, "TOPLEFT", "BOTTOMLEFT", self.nextAnchor, 0, itemOffset)
		-- enable the bar
		self.bars["charge"]:setUBarEnabled(true)
		-- set charge colour
		self.bars["charge"]:setUBarColor(0,0.8,0.8,0.8)
		-- store anchor
		self.nextAnchor = self.bars["charge"].bar
	-- anchor to top left of frame
	else
		-- add resources bar
		self:addUnitBar( "charge", barWidth, barHeight, fontSize, "TOPLEFT", "TOPLEFT", self.frame, itemOffset, itemOffset)
		-- enable the bar
		self.bars["charge"]:setUBarEnabled(true)
		-- set charge colour
		self.bars["charge"]:setUBarColor(0,0.8,0.8,0.8)
		-- store anchor
		self.nextAnchor = self.bars["charge"].bar
	end
	
	-- resize based on bars currently enabled
	self:resize()
end

--
-- A resources UnitBar on this UnitFrame
-- 
-- Resource will be based on the Unit's Calling
--
function UnitFrame:addResourcesBar()
	debugPrint("Add resources Bar", self.unitName)
	
	-- values from config
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local barHeight = MinUIConfig.frames[self.unitName].barHeight
	local fontSize = MinUIConfig.frames[self.unitName].barFontSize
	local itemOffset = MinUIConfig.frames[self.unitName].itemOffset
	
	if(self.nextAnchor) then
		-- add resources bar
		self:addUnitBar( "resources", barWidth, barHeight, fontSize, "TOPLEFT", "BOTTOMLEFT", self.nextAnchor, 0, itemOffset)
		-- enable the bar
		self.bars["resources"]:setUBarEnabled(true)
		-- store anchor
		self.nextAnchor = self.bars["resources"].bar
	-- anchor to top left of frame
	else
		-- add resources bar
		self:addUnitBar( "resources", barWidth, barHeight, fontSize, "TOPLEFT", "TOPLEFT", self.frame, itemOffset, itemOffset)
		-- enable the bar
		self.bars["resources"]:setUBarEnabled(true)
		-- store anchor
		self.nextAnchor = self.bars["resources"].bar
	end
	
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
end


--
-- Add a bar to this UnitFrame
--
function UnitFrame:addUnitBar( barType, width, height, texture, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	debugPrint ("Adding Unit Bar", barType, " to ", self.unitName)

	newBar = UnitBar.new( barType, width, height, texture, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )
	
	-- store bar in unit frame
	self.bars[barType] = newBar
	
	-- resize based on bars currently enabled
	self:resize()
end



