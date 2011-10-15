-----------------------------------------------------------------------------------------------------------------------------
--
-- BuffBars for the UnitFrames
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
	
	--debugPrint("creating buff bars for ",unitName, buffType, visibilityOptions, lengthThreshold, direction)
	
	-- store values for the bar
	uBIcons.width = width
	uBIcons.anchorThis = anchorThis
	uBIcons.anchorParent = anchorParent
	uBIcons.parentItem = parentItem
	uBIcons.offsetX = offsetX
	uBIcons.offsetY = offsetY
	uBIcons.fontSize = 12
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
	
	-- store buffs
	uBIcons.activeBuffIcons = {}
	uBIcons.zombieBuffIcons = {}
	uBIcons.numActiveBars = 0

	-- create the frame
	uBIcons.frame = UI.CreateFrame("Frame", "buffIcons_"..buffType, parentItem)
	uBIcons.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBIcons.frame:SetWidth(uBIcons.width + (uBIcons.itemOffset*2)) -- give "breathing room" at either end
	uBIcons.frame:SetHeight(uBIcons.itemOffset)
	uBIcons.frame:SetLayer(-1)
	uBIcons.frame:SetVisible(true)
	uBIcons.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	
	-- calculate max icons per "row"
	uBIcons.maxIconsPerRow = math.floor(uBIcons.width / 32)
	uBIcons.curIconsInRow = 0
	uBIcons.numRows = 0
	
	--
	-- A Buff Hath Changed
	--
	table.insert(Event.Buff.Add, {function( unitID ) uBIcons:resyncBuffs ( Inspect.Time.Frame(), unitID ) end, "MinUI",  "MinUI_unitBuffIcons_buffAdd_"..uBIcons.unitName})
	table.insert(Event.Buff.Change, {function( unitID ) uBIcons:resyncBuffs ( Inspect.Time.Frame(), unitID ) end, "MinUI",  "MinUI_unitBuffIcons_buffChange_"..uBIcons.unitName})
	table.insert(Event.Buff.Remove, {function( unitID ) uBIcons:resyncBuffs ( Inspect.Time.Frame(), unitID )  end, "MinUI",  "MinUI_unitBuffIcons_buffRemove_"..uBIcons.unitName})
	
	
	--debugPrint(uBIcons)
	return uBIcons
end

--
-- Create or Add Existing Buff Bar to the UnitBuffIcons Anchor
--
function UnitBuffIcons:addBuffIcon(buff, time)

	-- attempt to reuse an old bar
	local buffIcon = table.remove(self.zombieBuffIcons)
	
	local unitName = self.unitName
	local width = self.width
	local fontSize = self.fontSize
	local itemOffset = self.itemOffset
	
	-- if no bar exist in our pool of bars then create one
	if not buffIcon then
		-- We don't have any bars remaining, so we create a new one.
		-- Our Bars are considered single objects that can be dealt with atomically. Each one has the functionality needed to update itself.
		buffIcon = UI.CreateFrame("Frame", "Bar", MinUI.context)
		buffIcon:SetWidth(32)
		buffIcon:SetHeight(32)
		buffIcon:SetBackgroundColor(0,0,0,0.5)

		-- Set location
		if(self.direction == "up")then
			buffIcon:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT")
		elseif(self.direction == "down")then
			buffIcon:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
		end
		
		buffIcon.timer = UI.CreateFrame("Text", "Timer", buffIcon)
		buffIcon.timer:SetLayer(4)
		buffIcon.timer:SetFontSize(12)
		buffIcon.timer:SetFontColor(1,1,1,1)
		
		buffIcon.timerShadow = UI.CreateFrame("Text", "Timer", buffIcon)
		buffIcon.timerShadow:SetLayer(3)
		buffIcon.timerShadow:SetFontSize(12)
		buffIcon.timerShadow:SetFontColor(0,0,0,1)
		
		buffIcon.stack = UI.CreateFrame("Text", "Timer", buffIcon)
		buffIcon.stack:SetLayer(4)
		buffIcon.stack:SetPoint("CENTER",buffIcon,"CENTER")
		buffIcon.stack:SetVisible(false)
		buffIcon.stack:SetFontColor(1,1,1,1)
		buffIcon.stack:SetFontSize(14)

		buffIcon.stackShadow = UI.CreateFrame("Text", "Timer", buffIcon)
		buffIcon.stackShadow:SetLayer(3)
		buffIcon.stackShadow:SetPoint("CENTER",buffIcon,"CENTER",1,1)
		buffIcon.stackShadow:SetVisible(false)
		buffIcon.stackShadow:SetFontColor(0,0,0,1)
		buffIcon.stackShadow:SetFontSize(14)
		
		buffIcon.icon = UI.CreateFrame("Texture", "Icon", buffIcon)
		buffIcon.icon:SetLayer(1)
		buffIcon.icon:SetPoint("TOPLEFT", buffIcon, "TOPLEFT")
		buffIcon.icon:SetWidth(32)
		buffIcon.icon:SetHeight(32)

		buffIcon.tex = UI.CreateFrame("Texture", "tex", buffIcon)
		buffIcon.tex:SetTexture("MinUI", "Media/Icons/buff.png")
		buffIcon.tex:SetLayer(2)
		buffIcon.tex:SetPoint("TOPLEFT", buffIcon, "TOPLEFT")
		buffIcon.tex:SetWidth(32)
		buffIcon.tex:SetHeight(32)

		-- Set Fonts
		if not (MinUIConfig.globalTextFont == "default") then
			buffIcon.timer:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
			buffIcon.timerShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
			buffIcon.stack:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
			buffIcon.stackShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		end
		
		buffIcon.timer:SetText("0s")
		buffIcon.stack:SetText("(0)")
		
		
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
		buffIcon.icon:SetPoint("BOTTOMRIGHT", buffIcon, "BOTTOMRIGHT")
		
		
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

				self:Tick(time)
			else
				self.completion = nil

				-- This is a permanent buff without a timer, so don't show any of that.
				self.timer:SetVisible(false)
				self.timer:SetWidth(0)
				self.timerShadow:SetVisible(false)
				self.timerShadow:SetWidth(0)
			end

			self.debuff = buff.debuff
			self.buffid = buff.id
		end
		
		--
		-- This is our update function, called once every frame.
		--
		function buffIcon:Tick(time)
			if self.completion then
				local remaining = self.completion - time

				if remaining < 0 then
					self.timer:SetVisible(false)
					self.timerShadow:SetVisible(false)
				else
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
				  
				end
			end
		end
		
		--
		-- Finally, if we're clicked, we want to cancel whatever buff is on us.
		--
		function buffIcon.Event:RightDown()
		  Command.Buff.Cancel(self.buffid)
		end
	end
	
	table.insert(self.activeBuffIcons, buffIcon)

	-- Show the buffIcon and set the data.
	buffIcon:SetVisible(true)
	buffIcon:SetBuff(buff, time)
	
	-- 
	-- LAYOUT BUFFICON
	--
	
	-- if we have hit the end of a row, increment number of rows and reset curIconsInRow counter
	if(self.curIconsInRow >= self.maxIconsPerRow)then
		self.numRows = self.numRows + 1
		self.curIconsInRow = 0 
	end
	
	-- calcualte the Y offset based on number of rows
	local rowYOffset = ((32+buffIcon.timer:GetFullHeight())*self.numRows)
	
	if (self.direction == "up") then
		buffIcon:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", (32+itemOffset)*self.curIconsInRow, -rowYOffset)
	elseif (self.direction == "down") then
		buffIcon:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", (32+itemOffset)*self.curIconsInRow, rowYOffset)
	end
	
	-- increment icons in row
	self.curIconsInRow = self.curIconsInRow + 1
end

--
-- Animate buff bars
--
function UnitBuffIcons:animate(time)
	for _, buffIcon in ipairs(self.activeBuffIcons) do
		buffIcon:Tick(time)
	end
end

--
-- Reset buff bars
--
function UnitBuffIcons:resetBuffs()
	----debugPrint("resetting buff bars on ", self.unitName)
	
	for _, buffIcon in pairs(self.activeBuffIcons) do
		table.insert(self.zombieBuffIcons, buffIcon)
		buffIcon:SetVisible(false)
		-- This is our first buffIcon, so we're pinning it to the unit frame it belongs too
		if (self.direction == "up") then
			buffIcon:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, 0)
		elseif (self.direction == "down") then
			buffIcon:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", 0, 0)
		end
	end
	
	self.curIconsInRow = 0
	self.numRows = 0

	self.activeBuffIcons = {}
	self.lastAttach = nil
end

-- 
-- Update the Buff Bars
--
function UnitBuffIcons:resyncBuffs( time, unitID )
	local frameUnitID = Inspect.Unit.Lookup(self.unitName)
	
	-- if we actually have a unit 
	if (frameUnitID and unitID) then
		-- if they match
		if (frameUnitID == unitID) then
			--print("resyncBuffs on " , self.unitName)
			
			-- inspect buffs for unitName
			local bufflist = Inspect.Buff.List(self.unitName)

			-- If we don't get anything, then we don't currently have information about the player.
			-- This may happen when the player is logging in or teleporting long distances.
			if bufflist then  
				local buffdetails = Inspect.Buff.Detail(self.unitName, bufflist)
				self:resetBuffs()
				
				local buffCount = 0
				local debuffCount = 0
				
				-- We want to order buffs by their time remaining
				-- splitting apart buffs and debuffs.
				local bbars = {}
				for id, buff in pairs(buffdetails) do
					buff.id = id  -- Make a copy of the ID, because we'll need it
					
					--
					-- Only Show the buffs that this UnitBuffBar is watching
					-- Based on VisibilityOptions, BuffType and Threshold Time
					--
					if (buff.debuff) then
						-- If we are showing buffType debuffs
						if (self.buffType == "debuffs") then
							if (debuffCount < MinUIConfig.frames[self.unitName].debuffsMax) then
								-- Showing all debuffs
								if(self.visibilityOptions == "all") then
									--debugPrint(buff.duration)
									-- Check the debuff is lessthan/equal to threshold length
									if(buff.duration) then
										if(buff.duration <= self.lengthThreshold)then
											table.insert(bbars, buff)
											debuffCount = debuffCount + 1 
										end
									-- or we have auras
									elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
										table.insert(bbars, buff)
										debuffCount = debuffCount + 1 
									end
								-- Showing player debuffs
								elseif (self.visibilityOptions == "player") then
									-- Check debuff was cast by player
									if (buff.caster == Inspect.Unit.Lookup("player")) then
										-- Check the buff is lessthan/equal to threshold length
										if(buff.duration) then
											if(buff.duration <= self.lengthThreshold)then
												table.insert(bbars, buff)
											end
										-- or we have auras
										elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
											table.insert(bbars, buff)
										end
									end
								end
								
								--print("debuff count " , debuffCount )
							end
						-- If we have merged buffs/debuffs (we dont use the self visibility/threshold stuff)
						elseif (self.buffType == "merged") then
							if (debuffCount < MinUIConfig.frames[self.unitName].debuffsMax) then
								-- Showing all debuffs
								if(MinUIConfig.frames[self.unitName].debuffVisibilityOptions == "all") then
									--debugPrint(buff.duration)
									-- Check the debuff is lessthan/equal to threshold length
									if(buff.duration) then
										if(buff.duration <= MinUIConfig.frames[self.unitName].debuffThreshold) then
											table.insert(bbars, buff)
											debuffCount = debuffCount + 1 
										end
									-- or we have auras
									elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
										table.insert(bbars, buff)
										debuffCount = debuffCount + 1 
									end
								-- Showing player debuffs
								elseif (MinUIConfig.frames[self.unitName].debuffVisibilityOptions == "player") then
									-- Check debuff was cast by player
									if (buff.caster == Inspect.Unit.Lookup("player")) then
										-- Check the buff is lessthan/equal to threshold length
										if(buff.duration) then
											if(buff.duration <= MinUIConfig.frames[self.unitName].debuffThreshold)then
												table.insert(bbars, buff)
												debuffCount = debuffCount + 1 
											end
										-- or we have auras
										elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
											table.insert(bbars, buff)
											debuffCount = debuffCount + 1 
										end
									end
								end
								
								--print("debuff count " , debuffCount )
							end
						end
					else
						-- if we are showing buffType buffs
						if (self.buffType == "buffs") then
							if (buffCount < MinUIConfig.frames[self.unitName].buffsMax) then
								-- Showing all buffs
								if(self.visibilityOptions == "all") then
									--debugPrint(buff.duration)
									-- Check the buff is lessthan/equal to threshold length
									if(buff.duration)then
										if(buff.duration <= self.lengthThreshold)then
											table.insert(bbars, buff)
											buffCount = buffCount + 1 
										end
									-- or if we have auras
									elseif(MinUIConfig.frames[self.unitName].buffAuras)then
										table.insert(bbars, buff)
										buffCount = buffCount + 1 
									end	
								-- Showing player buffs
								elseif (self.visibilityOptions == "player") then
									-- Check buff was cast by player
									if (buff.caster == Inspect.Unit.Lookup("player")) then
										-- Check the buff is lessthan/equal to threshold length
										-- Check the debuff is lessthan/equal to threshold length
										if(buff.duration)then
											if(buff.duration <= self.lengthThreshold)then
												table.insert(bbars, buff)
												buffCount = buffCount + 1 
											end
										-- or if we have auras
										elseif(MinUIConfig.frames[self.unitName].buffAuras)then
											table.insert(bbars, buff)
											buffCount = buffCount + 1 
										end							
									end
								end
								
								--print("buff count " , buffCount )
							end
						-- If we have merged buffs/debuffs (we dont use the self visibility/threshold stuff)
						elseif (self.buffType == "merged") then
							if (buffCount < MinUIConfig.frames[self.unitName].buffsMax) then
								-- Showing all debuffs
								if(MinUIConfig.frames[self.unitName].buffVisibilityOptions == "all") then
									--debugPrint(buff.duration)
									-- Check the debuff is lessthan/equal to threshold length
									if(buff.duration) then
										if(buff.duration <= MinUIConfig.frames[self.unitName].buffThreshold) then
											table.insert(bbars, buff)
											buffCount = buffCount + 1 
										end
									-- or if we have auras
									elseif(MinUIConfig.frames[self.unitName].buffAuras)then
										table.insert(bbars, buff)
										buffCount = buffCount + 1 
									end						
								-- Showing player debuffs
								elseif (MinUIConfig.frames[self.unitName].buffVisibilityOptions == "player") then
									-- Check debuff was cast by player
									if (buff.caster == Inspect.Unit.Lookup("player")) then
										-- Check the buff is lessthan/equal to threshold length
										if(buff.duration) then
											if(buff.duration <= MinUIConfig.frames[self.unitName].buffThreshold)then
												table.insert(bbars, buff)
												buffCount = buffCount + 1 
											end
										end
									-- or if we have auras
									elseif(MinUIConfig.frames[self.unitName].buffAuras)then
										table.insert(bbars, buff)
										buffCount = buffCount + 1 
									end						
								end
								
								--print("buff count " , buffCount )
							end
						end
					end
				end

				-- sort on time
				table.sort(
					bbars, function (a, b)
						if(self.buffType == "merged") then
							 if (a.debuff ~= b.debuff) then
								return b.debuff
							end
						end
					
						if a.duration and b.duration then return a.remaining > b.remaining end
						if not a.duration and not b.duration then return false end
						return not a.duration
					end
				)
				
				
				-- Now that we have the ordering, we just add the bars one at a time. Done!
				for k, buff in ipairs(bbars) do
					self:addBuffIcon(buff, time)
				end
			else
				self:resetBuffs()
			end
		end
	else
		self:resetBuffs()
	end
end