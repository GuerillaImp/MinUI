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
	uFrame.itemOffset = MinUIConfig.frames[uFrame.unitName].itemOffset
	
	-- buffbars
	uFrame.buffs = nil
	uFrame.debuffs = nil

	-- the next "thing" a UnitBar (or equivillent) should anchor on
	uFrame.nextAnchor = nil
	
	-- unit bars this frame will attempt to add/update as required
	uFrame.barsEnabled = {}

	-- unit frame bars
	uFrame.bars = {}
	
	-- create the frame
	uFrame.frame = UI.CreateFrame("Frame", uFrame.unitName, parentItem)
	uFrame.frame:SetPoint("TOPLEFT", parentItem, "TOPLEFT", x, y ) -- frames from top left of scren
	uFrame.frame:SetWidth(uFrame.width)
	uFrame.frame:SetHeight(uFrame.height)
	uFrame.frame:SetLayer(0)
	uFrame.frame:SetVisible(uFrame.visible)
	
	-- create a castbar
	uFrame.castBar = UnitCastBar.new( uFrame.unitName, MinUIConfig.frames[uFrame.unitName].barWidth, MinUIConfig.frames[uFrame.unitName].barHeight,"TOPLEFT","BOTTOMLEFT", uFrame.frame, 0, MinUIConfig.frames[uFrame.unitName].barHeight)
	
	--
	-- frame background
	--
	
	local configColor = MinUIConfig.backgroundColor
	if(configColor)then
		uFrame.frame:SetBackgroundColor(configColor.r,configColor.g,configColor.b,configColor.a)
	else
		uFrame.frame:SetBackgroundColor(0,0,0,0.3)
	end
	
	uFrame.highlightBar = UI.CreateFrame("Frame", "highlightbar_"..uFrame.unitName, uFrame.frame )
	uFrame.highlightBar:SetPoint("TOPCENTER", uFrame.frame, "BOTTOMCENTER", 0, 0 )
	uFrame.highlightBar:SetWidth(uFrame.width)
	uFrame.highlightBar:SetHeight(MinUIConfig.frames[uFrame.unitName].itemOffset)
	uFrame.highlightBar:SetLayer(0)
	uFrame.highlightBar:SetVisible(uFrame.visible)
	uFrame.highlightBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	--
	-- Icons for Role - XXX: Replace this with one of the new anchors mayhap
	--
	uFrame.bottomRightIcon = UI.CreateFrame("Texture", uFrame.unitName.."_bottomRightIcon", uFrame.frame)
	uFrame.bottomRightIcon:SetPoint("BOTTOMRIGHT", uFrame.frame, "BOTTOMRIGHT", -uFrame.itemOffset,-uFrame.itemOffset) -- top right icon
	uFrame.bottomRightIcon:SetWidth(15)
	uFrame.bottomRightIcon:SetHeight(15)
	uFrame.bottomRightIcon:SetLayer(1)
	uFrame.bottomRightIcon:SetVisible(true)
	
	uFrame.bottomLeftIcon = UI.CreateFrame("Texture", uFrame.unitName.."_bottomLeftIcon", uFrame.frame)
	uFrame.bottomLeftIcon:SetPoint("BOTTOMLEFT",  uFrame.frame, "BOTTOMLEFT", uFrame.itemOffset, -uFrame.itemOffset) -- top left icon
	uFrame.bottomLeftIcon:SetWidth(15)
	uFrame.bottomLeftIcon:SetHeight(15)
	uFrame.bottomLeftIcon:SetLayer(1)
	uFrame.bottomLeftIcon:SetVisible(false)

	
	--
	-- Make the frame restricted such that we can ues mouesover macros on them
	--
	-- Eventually
	--
	--uFrame.frame:SetSecureMode("restricted")
	--uFrame.frame:SetMouseoverUnit(uFrame.unitName)

	--
	-- Register UnitName Changes to be handled within the frame
	--
	uFrame.unitChangedEventTable = nil
	uFrame.unitChangedEventTable = Library.LibUnitChange.Register(uFrame.unitName)
	table.insert(uFrame.unitChangedEventTable, {function() uFrame:unitChanged() end, "MinUI", uFrame.unitName.."_unitChanged"})
	
	--
	-- Unit Changes
	--
	-- XXX: For now dont bother checking if it's the correct frame because focus/and tot dont ever seem to appear in the UnitID
	-- 
	-- But when they do, this will make the frames more efficient
	--
	table.insert(Event.Unit.Detail.Health, {function ( unitIDs ) uFrame:updateHealth( unitIDs ) end, "MinUI", uFrame.unitName.."_updateHealth"})
	table.insert(Event.Unit.Detail.HealthMax, {function ( unitIDs ) uFrame:updateHealth( unitIDs ) end, "MinUI", uFrame.unitName.."_updateHealth"})
	table.insert(Event.Unit.Detail.Mana, {function ( unitIDs ) uFrame:updateResources( unitIDs ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.ManaMax, {function ( unitIDs ) uFrame:updateResources( unitIDs ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.Power, {function ( unitIDs ) uFrame:updateResources( unitIDs ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.Energy, {function ( unitIDs ) uFrame:updateResources( unitIDs ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.EnergyMax, {function ( unitIDs ) uFrame:updateResources( unitIDs ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.Combo, {function ( unitIDs ) uFrame:updateComboPointsBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateComboPointsBar"})
	table.insert(Event.Unit.Detail.ComboUnit, {function ( unitIDs ) uFrame:updateComboPointsBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateComboPointsBar"})
	table.insert(Event.Unit.Detail.Charge, {function ( unitIDs ) uFrame:updateChargeBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateChargeBar"})
	
	-- text items that may have updated
	table.insert(Event.Unit.Detail.Planar, {function ( unitIDs ) uFrame:updateUnitTextBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateTextBar"})
	table.insert(Event.Unit.Detail.Vitality, {function ( unitIDs ) uFrame:updateUnitTextBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateTextBar"})
	table.insert(Event.Unit.Detail.Level, {function ( unitIDs ) uFrame:updateUnitTextBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateTextBar"})
	table.insert(Event.Unit.Detail.Guild, {function ( unitIDs ) uFrame:updateUnitTextBar( unitIDs ) end, "MinUI", uFrame.unitName.."_updateTextBar"})
	
	-- things that effect icons
	table.insert(Event.Unit.Detail.Role, {function ( unitIDs ) uFrame:updateIcons( unitIDs ) end, "MinUI", uFrame.unitName.."_updateIcons"})
	
	
	--
	-- Mouse Interaction Code
	--
	-- For now we just support dragging of frames when unlocked
	--
	function uFrame.frame.Event:LeftDown()
		if(MinUI.secureMode) then
			return
		end
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
			self:SetBackgroundColor(0.3,0.0,0.0,0.6)
		end
	end
	
	function uFrame.frame.Event:MouseMove()
		if(MinUI.secureMode) then
			return
		end
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
	
	-- mouse hover colors
	function uFrame.frame.Event:MouseIn()
		--if(uFrame.visible)then
			uFrame.highlightBar:SetBackgroundColor(1.0, 1.0, 0.0, 0.3)
		--end
	end
	function uFrame.frame.Event:MouseOut()
		--if(uFrame.visible)then
			uFrame.highlightBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		--end
	end
	
	function uFrame.frame.Event:LeftUp()
		if(MinUI.secureMode) then
			return
		end
		if(MinUIConfig.unitFramesLocked == false) then
			if self.MouseDown then
				self.MouseDown = false
				uFrame.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
							
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
-- Animation Loop
--
function UnitFrame:animate( )
	local curTime = Inspect.Time.Frame()
	--
	-- Anything that needs updating, should get done here :-)
	--
	if ( self.visible ) then
		-- Animate Visible Buff Bars
		if(self.buffs) then
			self.buffs:animate(curTime)
		end
		if(self.debuffs)  then
			self.debuffs:animate(curTime)
		end
		
		-- animate cast bar
		if(self.castBar)then
			self.castBar:animate()
		end
	end
end

--
-- Unit Changed
--
function UnitFrame:unitChanged( )
	debugPrint ("Unit Changed ", self.unitName )
	--
	-- Ensure the values on the bars update to the new target's details
	--
	self:refresh()
	--
	-- Ensure the buffsbars are reset then update
	--
	self:resetBuffBars()
	self:updateBuffBars( )	
end

--
-- Update the UnitFrame's icons
--
function UnitFrame:updateIcons()

	local unitDetails = Inspect.Unit.Detail(self.unitName)
	if(unitDetails)then
		local role = unitDetails.role
		if(role)then
			self.bottomRightIcon:SetVisible(true)
			if(role=="dps")then
				self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/dps.tga")
			elseif(role=="support")then
				self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/support.tga")
			elseif(role=="heal")then
				self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/heals.tga")
			elseif(role=="tank")then
				self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/tank.tga")
			else
				self.bottomRightIcon:SetVisible(false)
			end
		else
			--print("no role")
			self.bottomRightIcon:SetVisible(false)
		end	
	end
end

--
-- Set UFrame Background
--
-- Due to restricted mode we can't actually "hide" the frame itself using SetVisible, 
-- so instead we shall set opacity to 0 on the frame, and ask everything else (which should be in "normal" mode)
-- to hide using SetVisible
--
--
function UnitFrame:setUFrameVisible (toggle)
	debugPrint("setting ", self.unitName, " to visible ", toggle)
	-- store visiblity
	self.visible = toggle
	self.frame:SetVisible(self.visible)
	
	--
	-- Secure Mode Workaround?
	--
	
	-- if in secure mode we can't set things to invisible
	--if(MinUI.secureMode)then -- for now, fuck it.
		-- make things visible
		--[[if(self.visible)then
			self.frame:SetBackgroundColor(0,0,0,0.3)
			for _,barType in pairs(self.barsEnabled) do
				if(self.bars[barType])then
					self.bars[barType]:setUBarEnabled(true)
				end
			end
		-- hide everything
		else
			self.frame:SetBackgroundColor(0,0,0,0.3)
			for _,barType in pairs(self.barsEnabled) do
				if(self.bars[barType])then
					--self.bars[barType]:setUBarEnabled(false)
					--self.bars[barType]:setUBarColorAlpha(0,0,0,0) -- eventually we will disable them
				end
			end
		end]]
	-- if not, we can :-)
	--[[else]]
	-- dont forget to re-enable everything else :)
	--[[if(self.visible)then
		for _,barType in pairs(self.barsEnabled) do
			if(self.bars[barType])then
				self.bars[barType]:setUBarEnabled(true)
			end
		end
	else
		for _,barType in pairs(self.barsEnabled) do
			if(self.bars[barType])then
				self.bars[barType]:setUBarEnabled(false)
			end
		end
	end]]
	
	--end
end

--
-- Is the frame visible?
-- 
function UnitFrame:isUFrameVisible()
	return self.visible
end

--
-- Make the UnitFrame update all of it's values (or hide if there are 
-- no longer details for it)
-- 
--
function UnitFrame:refresh ( )
	local unitDetails = Inspect.Unit.Detail(self.unitName)
	
	if(unitDetails)then
		debugPrint("we have details for ", self.unitName)
	end

	--
	-- Unit Details
	-- 
	if(unitDetails) then
		self.calling = unitDetails.calling
		self:setUFrameVisible(true)
		self:updateReactionColoring(unitDetails.relation)
		self:refreshBarValues()
		self:updateIcons()
	else
		self:setUFrameVisible(false)
	end
end

--
-- Refresh the bar values
--
function UnitFrame:refreshBarValues()
	--
	-- refresh all of our bars
	--
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
			self:updateUnitTextBar()
		end
		if(barType == "charge") then
			self:updateChargeBar()
		end
	end
end

--
-- Update the Unit Frame's reaction coloring
--
function UnitFrame:updateReactionColoring( relation )
	-- Set Reaction Coloring of Target/etc but not player
	if not ( self.unitName == "player" ) then
		-- Colour the unit text background based on reaction (if one exists)
		if (self.bars["text"])then
			if ( relation == "friendly" ) then
				self.bars["text"]:setUBarColor(0,1,0, 0.1)
			elseif( relation == "hostile" ) then
				self.bars["text"]:setUBarColor(1,0,0.0,0.1)
			elseif( relation == "none" ) then
				self.bars["text"]:setUBarColor(0,0,0.0,0.0)
			else
				self.bars["text"]:setUBarColor(1,1,0.0,0.1)
			end
		end
	end
end

--
-- Add Buff Bars to the UnitFrame
--
-- buffType == buff/debuff/meged
-- visibilityOptions == player/all/curable
-- lengthThreshold == max time (i.e 30 secs or less)
--
--
function UnitFrame:addBuffBars( buffType, visibilityOptions, lengthThreshold, location )
	local bbars = nil
	
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	
	--print("pre scale buff width", barWidth)
	-- if this unit has a scale value
	if(MinUIConfig.frames[self.unitName].scale)then
		barWidth = barWidth * MinUIConfig.frames[self.unitName].scale
	end
	--print("post scale buff width", barWidth)
	
	-- create bar in correct location
	if( location == "above") then
		--bbars = UnitBuffBars.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "up", barWidth, "BOTTOMCENTER", "TOPCENTER", self.frame, 0, 0 )
		bbars = UnitBuffIcons.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "up", barWidth, "BOTTOMCENTER", "TOPCENTER", self.frame, 0, 0 )
	elseif ( location == "below") then
		--bbars = UnitBuffBars.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "down", barWidth, "TOPCENTER", "BOTTOMCENTER", self.frame, 0, 0 )
		bbars = UnitBuffIcons.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "down", barWidth, "TOPCENTER", "BOTTOMCENTER", self.frame, 0, 0 )
	end
	
	-- store frame
	if (buffType == "buffs")then
		self.buffs = bbars
	elseif (buffType == "debuffs")then
		self.debuffs = bbars
	elseif(buffType == "merged") then
		self.buffs = bbars -- just store here
	end
end

--
-- Resets the buff bar to contain no buffs
--
function UnitFrame:resetBuffBars()
	if(self.buffs) then
		debugPrint("resetBuffBars buffs on ", self.unitName)
		self.buffs:resetBuffBars(Inspect.Time.Frame())
	end
	if(self.debuffs)  then
		debugPrint("resetBuffBars buffs on ", self.unitName)
		self.debuffs:resetBuffBars(Inspect.Time.Frame())
	end
end

--
-- Refresh the buffs to update for new buffs/debuffs
--
function UnitFrame:updateBuffBars( )
	if (self.visible) then
		if(self.buffs) then
			debugPrint("updateBuffBars buffs on ", self.unitName)
			self.buffs:update(Inspect.Time.Frame())
		end
		if(self.debuffs)  then
			debugPrint("updateBuffBars debuffs on ", self.unitName)
			self.debuffs:update(Inspect.Time.Frame())
		end
	end
end

--
-- Update the Unit's Text Values
--
function UnitFrame:updateUnitTextBar()
	local bar = self.bars["text"]
	-- if this frame has a health bar
	if (bar) then
		bar:updateTextItems()
	end
end

--
-- Update the Combo Points Bar
--
function UnitFrame:updateComboPointsBar()
	local bar = self.bars["comboPointsBar"]
	if (bar) then
		-- combo points only available for player
		local unitDetails = Inspect.Unit.Detail("player")
		if (unitDetails) then
			-- rogues need to pin their combo points to the correct target
			if ( MinUI.playerCalling == "rogue" ) then
				if( unitDetails.comboUnit ) then
					local unit = Inspect.Unit.Lookup(unitDetails.comboUnit)
					------debugPrint("combo points are on ", unit, unitDetails.comboUnit)
					if ( unit == "player.target" ) then
						local points = unitDetails.combo
						------debugPrint ( points ) 
						bar:updateComboPoints(points)
					else
						bar:updateComboPoints(0)
					end
				else
					bar:updateComboPoints(0)
				end
			-- warriors just add points to the bar (which by default is on the player frame)
			else
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
	local bar = self.bars["health"]
	-- if this frame has a health bar
	if (bar) then
		local unitDetails = Inspect.Unit.Detail(self.unitName)
		local healthPercent = 0
		if (unitDetails) then
			local health = unitDetails.health
			-- guard against wierdness when zoning
			if (health) then
				local healthMax = unitDetails.healthMax
				if (healthMax) then
					local healthRatio = health/healthMax
					healthPercent = math.ceil(healthRatio * 100) -- lets be more optimistic :P
					
					
					local healthText = ""
					if(health >= 1000000)then
						healthText = healthText ..  string.format("%.2fm", health / 1000000)
					elseif(health >= 10000)then
						healthText = healthText ..  string.format("%.2fk", health / 1000)
					else
						healthText = healthText ..  string.format("%s", health)
					end
					if(healthMax >= 1000000)then
						healthText = healthText ..  string.format(" / %.2fm", healthMax / 1000000)
					elseif(healthMax >= 10000)then
						healthText = healthText ..  string.format(" / %.2fk", healthMax / 1000)
					else
						healthText = healthText ..  string.format(" / %s", healthMax)
					end
					
					local healthPercentText = string.format("(%s%%)", healthPercent)
					
					bar:setUBarLeftText(healthText)
					bar:setUBarWidthRatio(healthRatio)
					bar:setUBarRightText(healthPercentText)
				end
			end
		else
			-- No details, set text to ""
			bar:setUBarLeftText("")
			bar:setUBarWidthRatio(1)
			bar:setUBarRightText("")
		end
		
							
		-- set correct color
		self:updateHealthBarColor(healthPercent)
	end
end

--
-- Update the Charge Bar of this Unit Frame
--
function UnitFrame:updateChargeBar( )
	local bar = self.bars["charge"]
	-- if this frame has a charge bar
	if (bar) then
		local unitDetails = Inspect.Unit.Detail(self.unitName)
		if (unitDetails) then
			local charge = unitDetails.charge
			-- guard against wierdness when zoning
			if (charge) then
				local chargeMax = 100 -- TODO: can mages go over 100 charge?
				local chargeRatio = charge/chargeMax
				local chargePercent = math.floor(chargeRatio * 100)
				
				local chargeText = string.format("%s/%s", charge,chargeMax)
				------debugPrint(chargeText)
				bar:setUBarLeftText(chargeText)
				bar:setUBarWidthRatio(chargeRatio)
				bar:setUBarRightText("")
			end
		else
			-- No details, set text to ""
			bar:setUBarLeftText("")
			bar:setUBarWidthRatio(1)
			bar:setUBarRightText("")
		end
	end
end


--
-- Update the Resources Bar of this Unit Frame
--
function UnitFrame:updateResources( )
	local bar = self.bars["resources"]
	-- if we have an energy bar
	if (bar) then
		local unitDetails = Inspect.Unit.Detail(self.unitName)
		if (unitDetails) then
			if(self.calling == "rogue") then
				local energy = unitDetails.energy
				-- guard against wierdness when zoning
				if (energy) then
					local energyMax = unitDetails.energyMax
					if (energyMax) then
						local energyRatio = energy/energyMax
						local energyPercent = math.floor(energyRatio * 100)
						
						local energyText = string.format("%s/%s", energy, energyMax)
						bar:setUBarLeftText(energyText)
						bar:setUBarWidthRatio(energyRatio)
						bar:setUBarRightText("")
					end
				end
			elseif(self.calling == "warrior") then
				local power = unitDetails.power
				-- guard against wierdness when zoning
				if (power) then
					local powerMax = 100
					local powerRatio = power/powerMax
					local powerPercent = math.floor(powerRatio * 100)

					local powerText = string.format("%s/%s", power, powerMax)
					bar:setUBarLeftText(powerText)
					bar:setUBarWidthRatio(powerRatio)
					bar:setUBarRightText("")
				end
			elseif(self.calling == "cleric" or self.calling == "mage") then
				local mana = unitDetails.mana
				-- guard against wierdness when zoning
				if (mana) then
					local manaMax = unitDetails.manaMax
					if (manaMax) then
						local manaRatio = mana/manaMax
						local manaPercent = math.floor(manaRatio * 100)
						
						-- Convert large numbers to small versions
						local manaText = ""
						if(mana >= 1000000)then
							manaText = manaText ..  string.format("%.2fm", mana / 1000000)
						elseif(mana >= 10000)then
							manaText = manaText ..  string.format("%.2fk", mana / 1000)
						else
							manaText = manaText ..  string.format("%s", mana)
						end
						if(manaMax >= 1000000)then
							manaText = manaText ..  string.format(" / %.2fm", manaMax / 1000000)
						elseif(manaMax >= 10000)then
							manaText = manaText ..  string.format(" / %.2fk", manaMax / 1000)
						else
							manaText = manaText ..  string.format(" / %s", manaMax)
						end
						
						local manaPercentText = string.format("(%s%%)", manaPercent)
						
						bar:setUBarLeftText(manaText)
						bar:setUBarRightText(manaPercentText)
						bar:setUBarWidthRatio(manaRatio)
					end
				end
			-- No Calling
			else
				bar:setUBarLeftText("")
				bar:setUBarRightText("")
				bar:setUBarWidthRatio(1)
			end
		else
			-- No details, set text to ""
			self.calling = "moo"
			bar:setUBarLeftText("")
			bar:setUBarWidthRatio(1)
			bar:setUBarRightText("")
		end
		
		-- set correct color
		self:updateResourcesBarColor()
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
		self.bars["resources"]:setUBarColor( 1.0, 0, 1.0)
	elseif (self.calling == "warrior") then
		self.bars["resources"]:setUBarColor( 1.0, 0.5, 0 )
	elseif (self.calling == "mage" or self.calling == "cleric") then
		self.bars["resources"]:setUBarColor( 0, 0.5, 1.0 )
	else
		self.bars["resources"]:setUBarColorAlpha( 0, 0, 0, 0)
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
		self.bars["health"]:setUBarColor( 0.0, 0.7, 0.0)
	elseif(percentage >= 33 and percentage <= 66) then
		self.bars["health"]:setUBarColor( 0.7, 0.7, 0.0)
	elseif(percentage >= 1 and percentage <= 33) then
		self.bars["health"]:setUBarColor( 0.7, 0.0, 0.0)
	else
		self.bars["health"]:setUBarColorAlpha( 0.0, 0.0, 0.0, 0.0)
	end
end

--
-- Set Frame Calling
--
function UnitFrame:setUFrameCalling ( calling )
	self.calling = calling
	----debugPrint("Set ", self.unitName, " to calling ", self.calling)
end

--
-- Signal to the UnitFrame that we want these frames
--
function UnitFrame:enableBar( position, barType )
	self.barsEnabled[position] = barType
end

--
-- Initialise all the bars this frame has been told to enable
--
function UnitFrame:createEnabledBars()
	for _,barType in pairs(self.barsEnabled) do
		print("creating enabled bars, ", barType)
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
	-- values from config
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local fontSize = MinUIConfig.frames[self.unitName].unitTextFontSize
	local itemOffset = MinUIConfig.frames[self.unitName].itemOffset

	-- if this unit has a scale value
	if(MinUIConfig.frames[self.unitName].scale)then
		barWidth = barWidth * MinUIConfig.frames[self.unitName].scale
		fontSize = fontSize * MinUIConfig.frames[self.unitName].scale
	end
	
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
	print("Add charge Bar", self.unitName)
	
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
	----debugPrint("Add resources Bar", self.unitName)
	
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
function UnitFrame:addUnitBar( barType, width, height, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	----debugPrint ("Adding Unit Bar", barType, " to ", self.unitName)

	--print ("pre scale", width,height,fontSize)
	-- if this unit has a scale value
	if(MinUIConfig.frames[self.unitName].scale)then
		width = width * MinUIConfig.frames[self.unitName].scale
		height = height * MinUIConfig.frames[self.unitName].scale
		fontSize = fontSize * MinUIConfig.frames[self.unitName].scale
	end
	--print ("post scale", width,height,fontSize)

	newBar = UnitBar.new( barType, width, height, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )
	
	-- store bar in unit frame
	self.bars[barType] = newBar
	
	-- resize based on bars currently enabled
	self:resize()
end