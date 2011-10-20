-----------------------------------------------------------------------------------------------------------------------------
--
-- Buff Icons for the UnitFrames
--
-- Acts as the anchor for buffs/debuffs
--
-----------------------------------------------------------------------------------------------------------------------------

UnitBuffIcons = {}
UnitBuffIcons.__index = UnitBuffIcons

--
function UnitBuffIcons.new( unitName, buffType, visibilityOptions, lengthThreshold, direction, width, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local uBIcons = {}             			-- our new object
	setmetatable(uBIcons, UnitBuffIcons)      	-- make UnitBar handle lookup
	
	-- store values for the bar
	uBIcons.width = width
	uBIcons.anchorThis = anchorThis
	uBIcons.anchorParent = anchorParent
	uBIcons.parentItem = parentItem
	uBIcons.offsetX = offsetX
	uBIcons.offsetY = offsetY
	uBIcons.fontSize = 12
	uBIcons.iconSize = 32
	uBIcons.unitName = unitName
	uBIcons.itemOffset = MinUIConfig.frames[uBIcons.unitName].itemOffset
	
	-- buff values
	uBIcons.direction = direction
	uBIcons.buffType = buffType
	uBIcons.visibilityOptions = visibilityOptions
	uBIcons.lengthThreshold = lengthThreshold
		
	-- scale font size if we have a scale
	if ( MinUIConfig.frames[uBIcons.unitName].scale ) then
		uBIcons.fontSize = uBIcons.fontSize * MinUIConfig.frames[uBIcons.unitName].scale
	end
	
	--
	-- Buff Icon Frame Set
	--
	uBIcons.buffIconFrames = {}
	-- Set of buffs sorted by time remaining
	uBIcons.buffDetailsList = {}
	
	--
	-- Max buffs/debuffs
	--
	uBIcons.buffsMax = 10
	if (uBIcons.buffType == "buff") then
		uBIcons.buffsMax = MinUIConfig.frames[uBIcons.unitName].buffsMax
	elseif (uBIcons.buffType == "debuff") then
		uBIcons.buffsMax = MinUIConfig.frames[uBIcons.unitName].debuffsMax
	elseif (uBIcons.buffType == "merged") then
		uBIcons.buffsMax = MinUIConfig.frames[uBIcons.unitName].buffsMax
	end

	--
	-- Create the container frame
	--
	uBIcons.frame = UI.CreateFrame("Frame", "buffIcons_"..buffType, parentItem)
	uBIcons.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBIcons.frame:SetWidth(uBIcons.width + (uBIcons.itemOffset*2)) -- give "breathing room" at either end
	uBIcons.frame:SetHeight(uBIcons.itemOffset)
	uBIcons.frame:SetLayer(-1)
	uBIcons.frame:SetVisible(true)
	uBIcons.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)

	--
	-- Calculate max icons per "row"
	--
	uBIcons.maxIconsPerRow = math.floor(uBIcons.width / uBIcons.iconSize)
	uBIcons.curIconsInRow = 0
	uBIcons.numRows = 0

	return uBIcons
end

--
-- Create Frames for the maximum number of buffs currently enabled
--
function UnitBuffIcons:createIconFrames()
	--functionStart("UnitBuffIcons:createIconFrames")

	self.buffIconFrames = {}
	
	for i = 1, self.buffsMax do
		self.buffIconFrames[i] = self:createBuffIconFrame(i)
	end

	-- after creating the icon frames, lay them out
	self:layoutIconFrames()
	
	--functionEnd("UnitBuffIcons:createIconFrames")
end

--
-- Layout the frames
--
function UnitBuffIcons:layoutIconFrames()
	--functionStart("UnitBuffIcons:layoutIconFrames")
	
	local rowCount = 0
	local curIcon = 0
	
	local xOffset = 0
	local yOffset = 0
	
	-- for each frame, layout based on index/row
	for index,buffIconFrame in ipairs(self.buffIconFrames) do
		if ( curIcon == self.maxIconsPerRow ) then
			-- increment row
			rowCount = rowCount + 1
			-- reset x offset / curIcon
			xOffset = 0
			curIcon = 0
		else
			-- calculat x offset
			xOffset = curIcon * (self.iconSize+self.itemOffset)
		end
		-- calculate y offset
		yOffset = rowCount * (self.iconSize + self.itemOffset + buffIconFrame.timer:GetFullHeight())
	
		-- add buff icon
		if (self.direction == "up") then
			buffIconFrame:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", xOffset,-yOffset)
		elseif (self.direction == "down") then
			buffIconFrame:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", xOffset,yOffset)
		end
		
		-- increment icon number
		curIcon = curIcon + 1
	end
	
	--functionEnd("UnitBuffIcons:layoutIconFrames")
end

--
-- Create An empty Buff Icon Frame
--
-- params: requires a frame index, this will determine the location of the frame
--
function UnitBuffIcons:createBuffIconFrame( frameIndex )
	--functionStart("UnitBuffIcons:createBuffIconFrame")
	
	-- get item offset
	local itemOffset = self.itemOffset
	local fontSize = self.fontSize
	
	-- Each Buff Icon contains the functions require to set a buff / tick / etc
	local buffIcon = UI.CreateFrame("Frame", "Bar", MinUI.context)
	buffIcon:SetWidth(self.iconSize)
	buffIcon:SetHeight(self.iconSize)
	buffIcon:SetBackgroundColor(1,0,0,0.5)
	buffIcon:SetVisible(false)
	buffIcon.active = false -- used to check whether to tick the buff or not
	buffIcon.buffID = ""
	
	-- Set location
	if(self.direction == "up")then
		buffIcon:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT")
	elseif(self.direction == "down")then
		buffIcon:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
	end

	buffIcon.timer = UI.CreateFrame("Text", "Timer", buffIcon)
	buffIcon.timer:SetLayer(4)
	buffIcon.timer:SetFontSize(fontSize)
	buffIcon.timer:SetFontColor(1,1,1,1)

	buffIcon.timerShadow = UI.CreateFrame("Text", "Timer", buffIcon)
	buffIcon.timerShadow:SetLayer(3)
	buffIcon.timerShadow:SetFontSize(fontSize)
	buffIcon.timerShadow:SetFontColor(0,0,0,1)

	buffIcon.stack = UI.CreateFrame("Text", "Timer", buffIcon)
	buffIcon.stack:SetLayer(4)
	buffIcon.stack:SetPoint("CENTER",buffIcon,"CENTER")
	buffIcon.stack:SetVisible(true)
	buffIcon.stack:SetFontColor(1,1,1,1)
	buffIcon.stack:SetFontSize(fontSize)

	buffIcon.stackShadow = UI.CreateFrame("Text", "Timer", buffIcon)
	buffIcon.stackShadow:SetLayer(3)
	buffIcon.stackShadow:SetPoint("CENTER",buffIcon,"CENTER",1,1)
	buffIcon.stackShadow:SetVisible(true)
	buffIcon.stackShadow:SetFontColor(0,0,0,1)
	buffIcon.stackShadow:SetFontSize(fontSize)

	buffIcon.icon = UI.CreateFrame("Texture", "Icon", buffIcon)
	buffIcon.icon:SetLayer(1)
	buffIcon.icon:SetPoint("TOPLEFT", buffIcon, "TOPLEFT")
	buffIcon.icon:SetWidth(self.iconSize)
	buffIcon.icon:SetHeight(self.iconSize)

	buffIcon.tex = UI.CreateFrame("Texture", "tex", buffIcon)
	buffIcon.tex:SetTexture("MinUI", "Media/Icons/buff.png")
	buffIcon.tex:SetLayer(2)
	buffIcon.tex:SetPoint("TOPLEFT", buffIcon, "TOPLEFT")
	buffIcon.tex:SetWidth(self.iconSize)
	buffIcon.tex:SetHeight(self.iconSize)

	-- Set Fonts
	if not (MinUIConfig.globalTextFont == "default") then
		buffIcon.timer:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		buffIcon.timerShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		buffIcon.stack:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		buffIcon.stackShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end

	buffIcon.timer:SetText("0s")
	buffIcon.stack:SetText("("..frameIndex..")")

	buffIcon.timer:SetHeight(buffIcon.timer:GetFullHeight())
	buffIcon.timer:SetWidth(buffIcon.timer:GetFullWidth())
	buffIcon.timerShadow:SetHeight(buffIcon.timer:GetFullHeight())
	buffIcon.timerShadow:SetWidth(buffIcon.timer:GetFullWidth())
	buffIcon.stack:SetHeight(buffIcon.stack:GetFullHeight())
	buffIcon.stack:SetWidth(buffIcon.stack:GetFullWidth())
	buffIcon.stackShadow:SetHeight(buffIcon.stack:GetFullHeight())
	buffIcon.stackShadow:SetWidth(buffIcon.stack:GetFullWidth())

	-- icon fills the buffIcon
	buffIcon.icon:SetPoint("TOPLEFT", buffIcon, "TOPLEFT")

	if(self.direction == "up")then
		buffIcon.timer:SetPoint("BOTTOMCENTER", buffIcon, "TOPCENTER", 0, -itemOffset )
		buffIcon.timerShadow:SetPoint("BOTTOMCENTER", buffIcon, "TOPCENTER", 1.5, -itemOffset+1.5) 
	else
		buffIcon.timer:SetPoint("TOPCENTER", buffIcon, "BOTTOMCENTER",0,itemOffset)
		buffIcon.timerShadow:SetPoint("TOPCENTER", buffIcon, "BOTTOMCENTER", 1.5, itemOffset-1.5) 
	end

	--
	-- Set Buff - requires a buff and a timestamp
	--
	function buffIcon:SetBuff(buff, time)
		-- if we are showing all buffs/debuffs distinguish player buffs
		if(self.visibilityOptions == "all")then
			if (buff.caster == Inspect.Unit.Lookup("player")) then
				self.timer:SetFontSize(fontSize)
				self.timerShadow:SetFontSize(fontSize)
			else
				self.timer:SetFontSize(fontSize -2)
				self.timerShadow:SetFontSize(fontSize -2)
			end
		else
			self.timer:SetFontSize(fontSize)
			self.timerShadow:SetFontSize(fontSize)
		end
		
		if(buff.debuff)then
			if(buff.disease)then
				self.tex:SetTexture("MinUI", "Media/Icons/disease.png")
			elseif(buff.curse)then
				self.tex:SetTexture("MinUI", "Media/Icons/curse.png")
			elseif(buff.poison)then
				self.tex:SetTexture("MinUI", "Media/Icons/poison.png")
			else
				self.tex:SetTexture("MinUI", "Media/Icons/debuff.png")
			end
		else
			self.tex:SetTexture("MinUI", "Media/Icons/buff.png")
		end
		
		if(buff.stack)then
			buffIcon.stack:SetText("("..buff.stack..")")
			buffIcon.stackShadow:SetText("("..buff.stack..")")
			
			buffIcon.stack:SetWidth(buffIcon.stack:GetFullWidth())
			buffIcon.stack:SetHeight(buffIcon.stack:GetFullHeight())
			buffIcon.stackShadow:SetWidth(buffIcon.stack:GetFullWidth())
			buffIcon.stackShadow:SetHeight(buffIcon.stack:GetFullHeight())
			
			buffIcon.stack:SetVisible(true)
			buffIcon.stackShadow:SetVisible(true)
		else
			buffIcon.stack:SetText("")
			buffIcon.stackShadow:SetText("")
			buffIcon.stack:SetVisible(false)
			buffIcon.stackShadow:SetVisible(true)
		end

		-- Set the icon
		self.icon:SetTexture("Rift", buff.icon)
	  
		if buff.duration then
			self.completion = buff.begin + buff.duration
			self.duration = buff.duration

			-- Display everything we might have hidden.
			self.timer:SetVisible(true)
			self.timerShadow:SetVisible(true)

			--self:Tick(time)
		else
			self.completion = nil

			-- This is a permanent buff without a timer, so don't show any of that.
			self.timer:SetVisible(false)
			self.timer:SetWidth(0)
			self.timerShadow:SetVisible(false)
			self.timerShadow:SetWidth(0)
		end

		self.debuff = buff.debuff
	end
	
	--
	-- Update timers, etc
	--
	function buffIcon:Tick(time)
		-- if the buff has a completion time
			if (self.completion) then
				local remaining = self.completion - time

				-- remove any expired buffs - NLR, the sync code should pick this up every update threshold time
				--if (remaining < 0) then
					--self:removeBuff(buffIconFrame.buffID)
				-- just tick along normal buffs
				--else
					-- Update our timer.
					local hours = math.floor(remaining / 3600)
					local minutes = math.floor(remaining / 60)
					local seconds = math.floor(remaining) % 60


					if(hours > 0)then
						self.timerShadow:SetText(string.format("%dh", hours))
						self.timer:SetText(string.format("%dh", hours))
					elseif(minutes > 0)then
						self.timerShadow:SetText(string.format("%dm", minutes))
						self.timer:SetText(string.format("%dm", minutes))
					elseif(seconds > 0)then
						self.timerShadow:SetText(string.format("%ds", seconds))
						self.timer:SetText(string.format("%ds", seconds))
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
	function buffIcon.Event:RightDown()
	  Command.Buff.Cancel(self.buffID)
	end
	
	-- Return the new icon
	return buffIcon
end


--
-- Reset existing buffs
--
function UnitBuffIcons:resetBuffs()	
	for index, buffIconFrame in ipairs(self.buffIconFrames) do
		buffIconFrame:SetVisible( false )
		buffIconFrame.active = false
	end
end

--
-- Add buffs in buffDetails
--
function UnitBuffIcons:addBuffs()
	-- Re-add buffs from buffDetails till we hit our max frames
	local index = 1
	local buffIconFrame = nil
	for _, buffDetails in ipairs(self.buffDetailsList) do
		if (index < self.buffsMax) then
			buffIconFrame = self.buffIconFrames[index]
			-- Show the buffIcon and set the data.
			buffIconFrame:SetVisible( true )
			buffIconFrame.active = true
			buffIconFrame.buffID = buffDetails.buffID
			buffIconFrame:SetBuff( buffDetails, Inspect.Time.Frame() )
			index = index + 1
		else
			return -- we can't add anymore
		end
	end
end

--
-- Sort the Buffs by Time Remaining
--
function UnitBuffIcons:sortBuffDetails ()	
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
-- Animate buff icons
--
function UnitBuffIcons:animate(time)
	for index, buffIconFrame in ipairs(self.buffIconFrames) do
		if(buffIconFrame.active)then
			buffIconFrame:Tick(time)
		end
	end
end

--
-- Remove Buff
--
function UnitBuffIcons:removeBuff ( buffID )
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
function UnitBuffIcons:syncBuffs ( curTime )
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
	-- no buffs
	else
		-- clear the details list (otherwise things wont readd if we switch back to the same target straight away)
		self.buffDetailsList = {}
		-- Reset frame icons
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
function UnitBuffIcons:showBuff ( buff ) 
	--functionStart("UnitBuffIcons:showBuff")
	
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
	
	--functionEnd("UnitBuffIcons:showBuff")
	
	-- if we made it here, the buff just didnt cut it :P
	return false
end