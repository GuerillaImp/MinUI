-----------------------------------------------------------------------------------------------------------------------------
--
-- BuffBars for the UnitFrames
--
-- Acts as the anchor for buffs/debuffs
--
--
--
-----------------------------------------------------------------------------------------------------------------------------

UnitBuffBars = {}
UnitBuffBars.__index = UnitBuffBars

--
function UnitBuffBars.new( unitName, buffType, visibilityOptions, lengthThreshold, direction, width, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local uBBars = {}             			-- our new object
	setmetatable(uBBars, UnitBuffBars)      	-- make UnitBar handle lookup

	-- store values for the bar
	uBBars.width = width
	uBBars.anchorThis = anchorThis
	uBBars.anchorParent = anchorParent
	uBBars.parentItem = parentItem
	uBBars.offsetX = offsetX
	uBBars.offsetY = offsetY
	
	-- buff values
	uBBars.direction = direction
	uBBars.unitName = unitName
	uBBars.buffType = buffType
	uBBars.visibilityOptions = visibilityOptions
	uBBars.lengthThreshold = lengthThreshold
	
	uBBars.fontSize = MinUIConfig.frames[uBBars.unitName].buffFontSize
	uBBars.itemOffset = MinUIConfig.frames[uBBars.unitName].itemOffset
	uBBars.height = MinUIConfig.frames[uBBars.unitName].barHeight
	
		
	-- scale font size if we have a scale
	if ( MinUIConfig.frames[uBBars.unitName].scale ) then
		uBBars.fontSize = uBBars.fontSize * MinUIConfig.frames[uBBars.unitName].scale
	end
	
	--
	-- Buff Icon Frame Set
	--
	uBBars.buffBarFrames = {}
	-- Set of buffs sorted by time remaining
	uBBars.buffDetailsList = {}
	
	--
	-- Max buffs/debuffs
	--
	uBBars.buffsMax = 10
	if (uBBars.buffType == "buff") then
		uBBars.buffsMax = MinUIConfig.frames[uBBars.unitName].buffsMax
	elseif (uBBars.buffType == "debuff") then
		uBBars.buffsMax = MinUIConfig.frames[uBBars.unitName].debuffsMax
	elseif (uBBars.buffType == "merged") then
		uBBars.buffsMax = MinUIConfig.frames[uBBars.unitName].buffsMax
	end

	-- create the frame
	uBBars.frame = UI.CreateFrame("Frame", "buffBars_"..buffType, parentItem)
	uBBars.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBBars.frame:SetWidth(uBBars.width) -- give "breathing room" at either end
	uBBars.frame:SetHeight(uBBars.itemOffset)
	uBBars.frame:SetLayer(-1)
	uBBars.frame:SetVisible(true)
	uBBars.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	return uBBars
end

--
-- Create Frames for the maximum number of buffs currently enabled
--
function UnitBuffBars:createBarFrames()
	--functionStart("UnitBuffBars:createBarFrames")
	
	self.buffBarFrames = {}
	
	for i = 1, self.buffsMax do
		self.buffBarFrames[i] = self:createBuffBarFrame(i)
	end

	-- after creating the bar frames, lay them out
	self:layoutBarFrames()
	
	--functionEnd("UnitBuffBars:createBarFrames")
end

--
-- Layout the frames
--
function UnitBuffBars:layoutBarFrames()
	--functionStart("UnitBuffBars:layoutBarFrames")
	
	--local lastAttach = nil
	local yOffset = 0
	
	-- for each frame
	for index, buffBarFrame in ipairs(self.buffBarFrames) do
		if (self.direction == "up") then
			buffBarFrame:SetPoint("BOTTOMCENTER", self.frame, "TOPCENTER", 0, -yOffset)
		elseif (self.direction == "down") then
			buffBarFrame:SetPoint("TOPCENTER", self.frame, "BOTTOMCENTER", 0, yOffset)
		end
			
		yOffset = yOffset + self.height + self.itemOffset
	end
	
	--functionEnd("UnitBuffBars:layoutBarFrames")
end

--
-- Create a buffBar
--
function UnitBuffBars:createBuffBarFrame( frameIndex )
	-- get item values for the frame
	local itemOffset = self.itemOffset
	local fontSize = self.fontSize
	local width = self.width
	local height = self.height
	
	-- We don't have any bars remaining, so we create a new one.
	-- Our Bars are considered single objects that can be dealt with atomically. Each one has the functionality needed to update itself.
	bar = UI.CreateFrame("Frame", "Bar", MinUI.context)
	bar:SetWidth(width)
	bar:SetHeight(height)
	bar:SetVisible(false)
	bar.buffID = ""
	
	-- Set Initial Location
	if(self.direction == "up")then
		bar:SetPoint("BOTTOMCENTER", self.frame, "TOPCENTER")
	elseif(self.direction == "down")then
		bar:SetPoint("TOPCENTER", self.frame, "BOTTOMCENTER")
	end

	
	bar.text = UI.CreateFrame("Text", "Text", bar)
	bar.textShadow = UI.CreateFrame("Text", "Text", bar)
	bar.text:SetLayer(2)
	bar.textShadow:SetLayer(1)
	
	
	bar.timer = UI.CreateFrame("Text", "Timer", bar)
	bar.timerShadow = UI.CreateFrame("Text", "Timer", bar)
	bar.timer:SetLayer(2)
	bar.timerShadow:SetLayer(1)
	
	bar.timer:SetHeight(bar.text:GetFullHeight())
	bar.timerShadow:SetHeight(bar.text:GetFullHeight())
	
	
	bar.icon = UI.CreateFrame("Texture", "Icon", bar)

	-- Solid background - this is the actual "bar" part of it.
	bar.solid = UI.CreateFrame("Frame", "Solid", bar)
	bar.solid:SetLayer(-1)  -- Put it behind every other element.
	
	bar.tex = UI.CreateFrame("Texture", "Texture", bar)
	if ( MinUIConfig.barTexture ) then
		bar.tex:SetTexture("MinUI", "Media/"..MinUIConfig.barTexture..".tga")
	else
		bar.tex:SetTexture("MinUI", "Media/Aluminium.tga")
	end

	bar.tex:SetLayer(-2)
	
	
	bar.text:SetText("???")
	bar.text:SetFontSize(fontSize)
	bar.textShadow:SetFontSize(fontSize)
	bar.textShadow:SetFontColor(0,0,0,1)

	-- Set Fonts
	if not (MinUIConfig.globalTextFont == "default") then
		bar.timer:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		bar.timerShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		bar.text:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		bar.textShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end
	
	bar.text:SetHeight(bar.text:GetFullHeight())
	bar.textShadow:SetHeight(bar.text:GetFullHeight())
	
	bar.timerShadow:SetFontSize(fontSize)
	bar.timerShadow:SetFontColor(0,0,0,1)
	bar.timerShadow:SetHeight(bar.text:GetFullHeight())
	
	bar:SetHeight(bar.text:GetFullHeight())
	bar.solid:SetHeight(bar.text:GetFullHeight())
	bar.tex:SetHeight(bar.text:GetFullHeight())

	bar.icon:SetPoint("TOPLEFT", bar, "TOPLEFT") -- The icon is pinned to the top-left corner of the bar.
	bar.icon:SetPoint("BOTTOM", bar, "BOTTOM") -- Vertically, it always fills the entire bar.

	bar.text:SetPoint("TOPLEFT", bar.icon, "TOPRIGHT") -- The text is pinned to the top-right corner of the icon.
	bar.textShadow:SetPoint("TOPLEFT", bar.icon, "TOPRIGHT", 1.5, 1.5) -- The textShadow is pinned to the top-right corner of the icon. yoffset by 2
	--bar:SetPoint("BOTTOM", bar.text, "BOTTOM")  -- The bar is set to always be as high as the text is.

	bar.timer:SetPoint("TOPRIGHT", bar, "TOPRIGHT") -- The timer is pinned to the top-right corner.
	bar.timerShadow:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 1.5, 1.5) -- The timerShadow is pinned to the top-right corner. yoffset by 2

	bar.text:SetPoint("RIGHT", bar.timer, "LEFT") -- Make sure the text doesn't overrun the timer. We'll be changing the text's height based on the contents, but we'll leave the width calculated this way.

	-- Set the solid bar to fill the entire buff bar.
	bar.solid:SetPoint("CENTERLEFT", bar, "CENTERLEFT")
	--bar.solid:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
	bar.tex:SetPoint("CENTERLEFT", bar, "CENTERLEFT")
	--bar.tex:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
	bar:SetWidth( self.width )
	bar.solid:SetWidth ( self.width )
	bar.tex:SetWidth ( self.width )
	
	--
	-- Set Buff - requires a buff and a timestamp
	--
	function bar:SetBuff(buff, time)
		-- Set Debuff Color
		if buff.debuff then
			self:SetBackgroundColor(1.0, 0.0, 0.0, 0.2)
			self.solid:SetBackgroundColor(1.0, 0.0, 0.0, 0.6)
		-- Set Buff Color
		else
			self:SetBackgroundColor(0.2, 0.2, 1.0, 0.2)
			self.solid:SetBackgroundColor(0.2, 0.2,1.0,0.6)
		end
	  
		-- if we are showing all buffs/debuffs distinguish player buffs
		if(self.visibilityOptions == "all")then
			if (buff.caster == Inspect.Unit.Lookup("player")) then
				self.text:SetFontSize(fontSize)
				self.timer:SetFontSize(fontSize)
				self.textShadow:SetFontSize(fontSize)
				self.timerShadow:SetFontSize(fontSize)
			else
				self.text:SetFontSize(fontSize - 2)
				self.timer:SetFontSize(fontSize - 2)
				self.textShadow:SetFontSize(fontSize - 2)
				self.timerShadow:SetFontSize(fontSize - 2)
			end
		else
			self.text:SetFontSize(fontSize)
			self.timer:SetFontSize(fontSize)
			self.textShadow:SetFontSize(fontSize)
			self.timerShadow:SetFontSize(fontSize)
		end
		
		-- Set Heights
		self.text:SetHeight(self.text:GetFullHeight())
		self.timer:SetHeight(self.text:GetFullHeight())
		self.textShadow:SetHeight(self.text:GetFullHeight())
		self.timerShadow:SetHeight(self.text:GetFullHeight())
		self:SetHeight(self.text:GetFullHeight())
		self.solid:SetHeight(self.text:GetFullHeight())
		self.tex:SetHeight(self.text:GetFullHeight())
		
	  
	  -- Re-square and set the icon
	  self.icon:SetWidth(self.icon:GetHeight())
	  self.icon:SetTexture("Rift", buff.icon)

	  -- Display our stacking multiple.
	  if buff.stack then
		self.text:SetText(buff.name .. " (" .. buff.stack .. ")")
		self.textShadow:SetText(buff.name .. " (" .. buff.stack .. ")")
	  else
		self.text:SetText(buff.name)
		self.textShadow:SetText(buff.name)
	  end
	  
	  self.text:SetWidth(width)
	  self.textShadow:SetWidth(width)
	  
	  if buff.duration then
		self.completion = buff.begin + buff.duration
		self.duration = buff.duration
		
		-- Display everything we might have hidden.
		self.solid:SetVisible(true)
		self.tex:SetVisible(true)
		self.timer:SetVisible(true)
		self.timerShadow:SetVisible(true)
		
		--self:Tick(time)
	  else
		self.completion = nil
		
		-- This is a permanent buff without a timer, so don't show any of that.
		self.solid:SetVisible(false)
		self.tex:SetVisible(false)
		self.timer:SetVisible(false)
		self.timer:SetWidth(0)
		self.timerShadow:SetVisible(false)
		self.timerShadow:SetWidth(0)
	  end
	  
	  self.debuff = buff.debuff
	end
	
	--
	-- This is our update function, called once every frame.
	--
	function bar:Tick(time)
		if self.completion then
			local remaining = self.completion - time

			--if remaining < 0 then
			--	self.timer:SetVisible(false)
			--	self.timerShadow:SetVisible(false)
			--else
				-- Update our timer.
				--self.tex:SetPoint("RIGHT", bar, remaining / self.duration, nil)
				--self.solid:SetPoint("RIGHT", bar, remaining / self.duration, nil)
				
			local widthMultiplier = ((remaining /  self.duration))
			self.solid:SetWidth((width) * widthMultiplier)
			self.tex:SetWidth((width) * widthMultiplier)

			-- Generate the timer text string.
			if remaining >= 3600 then
				self.timerShadow:SetText(string.format("%d:%02d:%02d", math.floor(remaining / 3600), math.floor(remaining / 60) % 60, math.floor(remaining) % 60))
				self.timer:SetText(string.format("%d:%02d:%02d", math.floor(remaining / 3600), math.floor(remaining / 60) % 60, math.floor(remaining) % 60))
			else
				self.timerShadow:SetText(string.format("%d:%02d", math.floor(remaining / 60), math.floor(remaining) % 60))
				self.timer:SetText(string.format("%d:%02d", math.floor(remaining / 60), math.floor(remaining) % 60))
			end

			-- Update the width to avoid truncation.
			self.timerShadow:SetWidth(self.timer:GetFullWidth())
			self.timer:SetWidth(self.timer:GetFullWidth())
			  
			--end
		end
	end
	
	--
	-- Finally, if we're clicked, we want to cancel whatever buff is on us.
	--
	function bar.Event:RightDown()
		Command.Buff.Cancel(self.buffID)
	end
	
	return bar
end

--
-- Clear existing buffs
--
function UnitBuffBars:resetBuffs()
	for index, buffBarFrame in ipairs(self.buffBarFrames) do
		buffBarFrame:SetVisible( false )
		buffBarFrame.active = false
	end
end

--
-- Add buffs in buffDetails
--
function UnitBuffBars:addBuffs()
	-- Re-add buffs from buffDetails till we hit our max frames
	local index = 1
	local buffBarFrame = nil
	for _, buffDetails in ipairs(self.buffDetailsList) do
		if (index < self.buffsMax) then
			buffBarFrame = self.buffBarFrames[index]
			-- Show the buffIcon and set the data.
			buffBarFrame:SetVisible( true )
			buffBarFrame.active = true
			buffBarFrame.buffID = buffDetails.buffID
			buffBarFrame:SetBuff( buffDetails, Inspect.Time.Frame() )
			index = index + 1
		else
			return -- we can't add anymore
		end
	end
end

--
-- Sort the Buffs by Time Remaining
--
function UnitBuffBars:sortBuffDetails()
	-- sort on time
	table.sort(
		self.buffDetailsList,
		function (a, b)
			--if(self.buffType == "merged") then
			if (a.debuff ~= b.debuff) then
				return b.debuff
			end
			--end
		
			if a.duration and b.duration then return a.remaining > b.remaining end
			if not a.duration and not b.duration then return false end
			return not a.duration
		end
	)
end

--
-- Animate buff bars
--
function UnitBuffBars:animate(time)
	--functionStart("UnitBuffBars:animate")
	for index, buffBarFrame in ipairs(self.buffBarFrames) do
		if(buffBarFrame.active)then
			buffBarFrame:Tick(time)
		end
	end
end


--
-- Remove Buff
--
function UnitBuffBars:removeBuff ( buffID, curTime )
	local indexToRemove = -1
	local index = 1
	for _,buffDetails in pairs(self.buffDetailsList)do
		if(buffDetails.buffID == buffID)then
			indexToRemove = index
		end
		index = index + 1
	end
	
	if not ( indexToRemove == -1 )then
		table.remove(self.buffDetailsList, indexToRemove)
	end
end

--
-- Resync all buffs
--
function UnitBuffBars:syncBuffs( curTime )
	-- inspect buffs for unitName
	local buffList = Inspect.Buff.List(self.unitName)
	-- has a change occured?
	local changeHasOccured = false
	
	-- insert all buffs on the unit
	if ( buffList ) then
		-- iterate accross the new buffs to check for new ones to add
		for buffID,_ in pairs(buffList) do
			-- Get the details table of the given buffID (for this unit)
			local newBuffDetails = Inspect.Buff.Detail(self.unitName, buffID)
			
			-- Does this buff meet the current filters/critera?
			if ( self:showBuff ( newBuffDetails ) ) then
				-- If we have buff details then...
				if ( newBuffDetails ) then
					-- We need to store this in the table for later
					newBuffDetails.buffID = buffID
					
					-- do we already have it?
					local buffExistsInOldDetails = false
					-- iterate accross old buffs to see if the buff already exists
					for _,buffDetails in pairs(self.buffDetailsList)do
						if(buffDetails.buffID == newBuffDetails.buffID)then
							buffExistsInOldDetails = true
						end
					end

					-- if we didn't have it, then add it
					if not (buffExistsInOldDetails) then
						-- Insert the new buff into the buffDetails array of buffs
						table.insert(self.buffDetailsList, newBuffDetails)
						changeHasOccured = true
					end
				end
			end
		end
		
		-- iterate across the old buffs, to check for ones to remove that are no longer present
		local index = 1
		local indexesToRemove = {}
		for _,buffDetails in pairs(self.buffDetailsList)do
			local buffExistsInNewDetails = false
			for buffID,_ in pairs(buffList) do
				if(buffID == buffDetails.buffID)then
					buffExistsInNewDetails = true
				end
			end
			
			-- if the buff doesn't exist in the new list, then list it to remove
			if not (buffExistsInNewDetails) then
				table.insert(indexesToRemove, index)
			end
			
			index = index+1
		end
		
		-- remove all that we are supposed ta
		for _,index in pairs(indexesToRemove)do
			table.remove(self.buffDetailsList, index)
			changeHasOccured = true
		end
	else
		-- clear the details list (otherwise things wont readd if we switch back to the same target straight away)
		self.buffDetailsList = {}
		self:resetBuffs()
	end
	
	-- only update if something has actually changed
	if(changeHasOccured)then	
		-- Reset frame icons
		self:resetBuffs()
		
		-- sort the buffs
		self:sortBuffDetails()

		-- layout the buffs
		self:addBuffs()
	end
end

--
-- Return true or false depending on if this buff meets the visibility/treshold settings
-- for this buff frame
--
function UnitBuffBars:showBuff ( buff )
	--functionStart("UnitBuffBars:showBuff")
	
	-- Is it a debuff?
	if (buff.debuff) then
		-- Are showing debuffs?
		if (self.buffType == "debuffs") then
			-- All debuffs?
			if(self.visibilityOptions == "all") then
				-- Check the debuff is lessthan/equal to threshold length
				if(buff.duration) then
					if(buff.duration <= self.lengthThreshold)then
						return true
					end
				-- or we have auras
				elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
					return true
				end
			-- Or player debuffs?
			elseif (self.visibilityOptions == "player") then
				-- Check debuff was cast by player
				if (buff.caster == Inspect.Unit.Lookup("player")) then
					-- Check the buff is lessthan/equal to threshold length
					if(buff.duration) then
						if(buff.duration <= self.lengthThreshold)then
							return true
						end
					-- or we have auras
					elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
						return true
					end
				end
			end
		-- If we have merged buffs/debuffs (we dont use the self visibility/threshold stuff)
		elseif (self.buffType == "merged") then
			-- Showing all debuffs
			if(MinUIConfig.frames[self.unitName].debuffVisibilityOptions == "all") then
				-- Check the debuff is lessthan/equal to threshold length
				if(buff.duration) then
					if(buff.duration <= MinUIConfig.frames[self.unitName].debuffThreshold) then
						return true
					end
				-- or we have auras
				elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
					return true
				end
			-- Showing player debuffs
			elseif (MinUIConfig.frames[self.unitName].debuffVisibilityOptions == "player") then
				-- Check debuff was cast by player
				if (buff.caster == Inspect.Unit.Lookup("player")) then
					-- Check the buff is lessthan/equal to threshold length
					if(buff.duration) then
						if(buff.duration <= MinUIConfig.frames[self.unitName].debuffThreshold)then
							return true
						end
					-- or we have auras
					elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
						return true
					end
				end
			end
		end
	else
		-- if we are showing buffType buffs
		if (self.buffType == "buffs") then
			-- Showing all buffs
			if(self.visibilityOptions == "all") then
				-- Check the buff is lessthan/equal to threshold length
				if(buff.duration)then
					if(buff.duration <= self.lengthThreshold)then
						return true
					end
				-- or if we have auras
				elseif(MinUIConfig.frames[self.unitName].buffAuras)then
					return true
				end	
			-- Showing player buffs
			elseif (self.visibilityOptions == "player") then
				-- Check buff was cast by player
				if (buff.caster == Inspect.Unit.Lookup("player")) then
					-- Check the buff is lessthan/equal to threshold length
					-- Check the debuff is lessthan/equal to threshold length
					if(buff.duration)then
						if(buff.duration <= self.lengthThreshold)then
							return true
						end
					-- or if we have auras
					elseif(MinUIConfig.frames[self.unitName].buffAuras)then
						return true
					end							
				end
			end
		-- If we have merged buffs/debuffs (we dont use the self visibility/threshold stuff)
		elseif (self.buffType == "merged") then
			-- Showing all debuffs
			if(MinUIConfig.frames[self.unitName].buffVisibilityOptions == "all") then
				----debugPrint(buff.duration)
				-- Check the debuff is lessthan/equal to threshold length
				if(buff.duration) then
					if(buff.duration <= MinUIConfig.frames[self.unitName].buffThreshold) then
						return true
					end
				-- or if we have auras
				elseif(MinUIConfig.frames[self.unitName].buffAuras)then
					return true
				end						
			-- Showing player debuffs
			elseif (MinUIConfig.frames[self.unitName].buffVisibilityOptions == "player") then
				-- Check debuff was cast by player
				if (buff.caster == Inspect.Unit.Lookup("player")) then
					-- Check the buff is lessthan/equal to threshold length
					if(buff.duration) then
						if(buff.duration <= MinUIConfig.frames[self.unitName].buffThreshold)then
							return true
						end
					end
				-- or if we have auras
				elseif(MinUIConfig.frames[self.unitName].buffAuras)then
					return true
				end						
			end
		end
		
	end
	
	--functionEnd("UnitBuffBars:showBuff")
	
	-- if we made it here, the buff just didnt cut it :P
	return false
end