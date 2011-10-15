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
	uFrame.castBar = nil
	
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
	uFrame.bottomRightIcon:SetPoint("TOPLEFT", uFrame.frame, "BOTTOMRIGHT", -7.5,-7.5) 
	uFrame.bottomRightIcon:SetWidth(15)
	uFrame.bottomRightIcon:SetHeight(15)
	uFrame.bottomRightIcon:SetLayer(4)
	uFrame.bottomRightIcon:SetVisible(true)
	
	uFrame.topRightIcon = UI.CreateFrame("Texture", uFrame.unitName.."_bottomLeftIcon", uFrame.frame)
	uFrame.topRightIcon:SetPoint("BOTTOMLEFT",  uFrame.frame, "TOPRIGHT", -7.5,7.5)
	uFrame.topRightIcon:SetWidth(15)
	uFrame.topRightIcon:SetHeight(15)
	uFrame.topRightIcon:SetLayer(4)
	uFrame.topRightIcon:SetVisible(false)
	uFrame.topRightIcon:SetTexture("MinUI", "Media/Icons/InCombat.png")

	
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
	table.insert(Event.Unit.Detail.Health, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "health" ) end, "MinUI", uFrame.unitName.."_updateHealth"})
	table.insert(Event.Unit.Detail.HealthMax, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "health" ) end, "MinUI", uFrame.unitName.."_updateHealth"})
	table.insert(Event.Unit.Detail.Mana, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "resources" ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.ManaMax, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "resources" ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.Power, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "resources" ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.Energy, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "resources" ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.EnergyMax, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "resources"  ) end, "MinUI", uFrame.unitName.."_updateResources"})
	table.insert(Event.Unit.Detail.Combo, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "combo" ) end, "MinUI", uFrame.unitName.."_updateComboPointsBar"})
	table.insert(Event.Unit.Detail.ComboUnit, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "combo" ) end, "MinUI", uFrame.unitName.."_updateComboPointsBar"})
	table.insert(Event.Unit.Detail.Charge, {function ( unitIDs ) uFrame:refreshBarValues( unitIDs, "charge" ) end, "MinUI", uFrame.unitName.."_updateChargeBar"})
	
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

function UnitFrame:setInCombat(toggle)
	if(toggle)then
		self.topRightIcon:SetVisible(true)
	else
		self.topRightIcon:SetVisible(false)
	end
end

-- Animate things that need "fast" updates (castbar, frame delta, flashing, etc)
function UnitFrame:animate ( )
	if ( self.visible ) then
		if(self.castBar)then
			self.castBar:animate()
		end
	end
end

-- Animate buff timers
function UnitFrame:animateBuffTimers ( time )
	if ( self.visible ) then
		if(self.buffs) then
			self.buffs:animate( time )
		end
		if(self.debuffs)  then
			self.debuffs:animate( time )
		end
	end
end


--
-- Unit Changed
--
function UnitFrame:unitChanged( )
	
	
	-- Get our UnitID
	local unitID = Inspect.Unit.Lookup(self.unitName)
	
	--print ("Unit Changed - name/id ", self.unitName, unitID )	
	
	--
	-- Ensure the values on the bars update to the new target's details
	--
	self:refreshUnitFrame( unitID )
	
	--
	-- Ensure the buffs are reset then update to match the new target
	--
	if(self.buffs)then
		self.buffs:resyncBuffs( Inspect.Time.Frame(), unitID )
	end
	if(self.debuffs)then
		self.debuffs:resyncBuffs( Inspect.Time.Frame(), unitID )
	end
	
	--
	-- Make the CastBar update
	--
	if(self.castBar)then
		if(unitID)then
			local unitIDsForCastBar = {}
			local unitCastBar = Inspect.Unit.Castbar( unitID )
			
			if(unitCastBar)then
				unitIDsForCastBar[unitID] = true
			else
				unitIDsForCastBar[unitID] = false
			end
			
			--print("updating castbar for ", unitID, unitCastBar )
			self.castBar:updateCastbar( unitIDsForCastBar )
		end
	end
end

--
-- Update the UnitFrame's icons
--
function UnitFrame:updateIcons( unitIDs )
	-- get the ID of the unit represented by this frame currently
	local frameUnitID = Inspect.Unit.Lookup(self.unitName)
	-- check to see if this frame actually updated
	for unitID, value in pairs (unitIDs) do
		if ( unitID == frameUnitID ) then
			local unitDetails = Inspect.Unit.Detail(self.unitName)
			if(unitDetails)then
				local role = unitDetails.role
				if(role)then
					self.bottomRightIcon:SetVisible(true)
					if(role=="dps")then
						self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/dps.png")
					elseif(role=="support")then
						self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/Support.png")
					elseif(role=="heal")then
						self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/Heals.png")
					elseif(role=="tank")then
						self.bottomRightIcon:SetTexture("MinUI", "Media/Roles/Tank.png")
					else
						self.bottomRightIcon:SetVisible(false)
					end
				else
					--print("no role")
					self.bottomRightIcon:SetVisible(false)
				end	
			end
	
		end
	end
end

function UnitFrame:addCastBar( castBarType )
	--print("castbar ", castBarType )
	if ( castBarType == "above" ) then
		self.castBar = UnitCastBar.new( self.unitName, MinUIConfig.frames[self.unitName].barWidth, MinUIConfig.frames[self.unitName].barHeight,"BOTTOMLEFT","TOPLEFT", self.frame, MinUIConfig.frames[self.unitName].itemOffset, -MinUIConfig.frames[self.unitName].itemOffset)
	elseif ( castBarType == "below" ) then
		self.castBar = UnitCastBar.new( self.unitName, MinUIConfig.frames[self.unitName].barWidth, MinUIConfig.frames[self.unitName].barHeight,"TOPLEFT","BOTTOMLEFT", self.frame, MinUIConfig.frames[self.unitName].itemOffset, MinUIConfig.frames[self.unitName].itemOffset)
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
function UnitFrame:refreshUnitFrame ( unitID )
	if(unitID)then
		local unitDetails = Inspect.Unit.Detail( unitID )
		--print (unitDetails)
		
		-- set the frame to visible, because we have an ID - but we might not yet have the details
		-- due to Rift's system of not providing things immediately, when you ask for them so kindly
		-- yes im looking at you pet's that dont give detials when summoned >:-|
		self:setUFrameVisible(true)
	
		--
		-- Unit Details - if we have them, then update them
		-- Otherwise the Events will update the frame through their callbacks
		-- 
		if(unitDetails) then
			-- add the unitID of this frame to the a table of unitIDs to update
			-- because the updateXXXXX( unitIDs ) commands require
			-- a table of IDs that have updated to check against and will only
			-- update if the ID of the updated unit matches this frame's unitID
			local unitIDs = {}
			local unitID = Inspect.Unit.Lookup(self.unitName)
			unitIDs[unitID] = true

			
			self.calling = unitDetails.calling
			self:setUFrameVisible(true)
			self:updateReactionColoring(unitDetails.relation)
			self:refreshBarValues( unitIDs, "all" )
			self:updateIcons( unitIDs )
		end
	else
		self:setUFrameVisible(false)
	end
end

--
-- Refresh the bar values
--
function UnitFrame:refreshBarValues( unitIDs, barToUpdate )
	if( unitIDs and barToUpdate ) then
		local updateFrame = false
		-- get the ID of the unit represented by this frame currently
		local frameUnitID = Inspect.Unit.Lookup(self.unitName)
		-- check to see if this frame actually updated
		for unitID, value in pairs (unitIDs) do
			if ( unitID == frameUnitID ) then
				updateFrame = true
			end
		end

		--
		-- refresh bars as required
		--
		if(updateFrame)then
			for _,barType in pairs(self.barsEnabled) do
				-- only update what is actually enabled on this unit frame
				if(barType == "health" and (barToUpdate == "health" or barToUpdate == "all")) then
					--print( "refreshing ", barType, " on ", self.unitName )
					self:updateHealth( unitIDs )
				end
				if(barType == "resources" and (barToUpdate == "resources" or barToUpdate == "all")) then
					--print( "refreshing ", barType, " on ", self.unitName )
					self:updateResources( unitIDs )
				end
				if(barType == "comboPointsBar" and (barToUpdate == "combo" or barToUpdate == "all")) then
					--print( "refreshing ", barType, " on ", self.unitName )
					self:updateComboPointsBar( unitIDs )
				end
				if(barType == "text" and (barToUpdate == "text" or barToUpdate == "all")) then
					--print( "refreshing ", barType, " on ", self.unitName )
					self:updateUnitTextBar( unitIDs )
				end
				if(barType == "charge"and (barToUpdate == "charge" or barToUpdate == "all")) then
					--print( "refreshing ", barType, " on ", self.unitName )
					self:updateChargeBar( unitIDs )
				end
			end
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
function UnitFrame:addBuffs( viewType, buffType, visibilityOptions, lengthThreshold, location )
	local buffs = nil
	local barWidth = MinUIConfig.frames[self.unitName].barWidth
	local xOffset = MinUIConfig.frames[self.unitName].itemOffset
	local widthOffset = MinUIConfig.frames[self.unitName].itemOffset
	local attachPoint = self.frame
	local buffView = viewType
	
	--print ( "creating buff type, ", buffView)
	
	-- if this unit has a scale value
	if(MinUIConfig.frames[self.unitName].scale)then
		barWidth = barWidth * MinUIConfig.frames[self.unitName].scale
	end

	-- check to see if we should actually attach to the castbar rather than the frame itself
	-- attach to the castbar if we are both above/below the unit
	local castBar = MinUIConfig.frames[self.unitName].castbar
	if ( castBar ) then
		if ( location == castBar ) then
			attachPoint = self.castBar:getFrame()
			xOffset = 0 -- cast bar is already offset correctly on the x value
		end
	end
	
	-- create bar in correct location
	if( location == "above") then
		if(buffView == "icon")then
			buffs = UnitBuffIcons.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "up", barWidth-(widthOffset), "BOTTOMCENTER", "TOPCENTER", attachPoint, xOffset, 0 )
		elseif(buffView == "bar")then
			buffs = UnitBuffBars.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "up", barWidth-(widthOffset), "BOTTOMCENTER", "TOPCENTER", attachPoint, xOffset, 0 )
		end
	elseif ( location == "below") then	
		if(buffView == "icon")then
			buffs = UnitBuffIcons.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "down", barWidth-(widthOffset), "TOPCENTER", "BOTTOMCENTER", attachPoint, xOffset, 0 )
		elseif(buffView == "bar")then
			buffs = UnitBuffBars.new( self.unitName, buffType, visibilityOptions, lengthThreshold, "down", barWidth-(widthOffset), "TOPCENTER", "BOTTOMCENTER", attachPoint, xOffset, 0 )
		end
	end
	
	-- store frame
	if (buffType == "buffs")then
		self.buffs = buffs
	elseif (buffType == "debuffs")then
		self.debuffs = buffs
	elseif(buffType == "merged") then
		self.buffs = buffs -- just store here
	end
end
--
-- Update the Unit's Text Values
--
function UnitFrame:updateUnitTextBar( unitIDs )
	-- get the ID of the unit represented by this frame currently
	local frameUnitID = Inspect.Unit.Lookup(self.unitName)
	-- check to see if this frame actually updated
	for unitID, value in pairs (unitIDs) do
		if ( unitID == frameUnitID ) then
			local bar = self.bars["text"]
			-- if this frame has a health bar
			if (bar) then
				bar:updateTextItems()
			end
		end
	end
end

--
-- Update the Combo Points Bar
--
function UnitFrame:updateComboPointsBar( )
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
		debugPrint("creating enabled bars, ", barType)
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
	debugPrint("Add charge Bar", self.unitName)
	
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
	-- if this unit has a scale value
	if(MinUIConfig.frames[self.unitName].scale)then
		width = width * MinUIConfig.frames[self.unitName].scale
		height = height * MinUIConfig.frames[self.unitName].scale
		fontSize = fontSize * MinUIConfig.frames[self.unitName].scale
	end
	
	newBar = UnitBar.new( barType, width, height, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )
	
	-- store bar in unit frame
	self.bars[barType] = newBar
	
	-- resize based on bars currently enabled
	self:resize()
end