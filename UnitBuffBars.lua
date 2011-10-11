-----------------------------------------------------------------------------------------------------------------------------
--
-- BuffBars for the UnitFrames
--
-- Acts as the anchor for buffs/debuffs
--
-----------------------------------------------------------------------------------------------------------------------------

UnitBuffBars = {}
UnitBuffBars.__index = UnitBuffBars

--
function UnitBuffBars.new( unitName, buffType, visibilityOptions, lengthThreshold, direction, width, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local uBBars = {}             			-- our new object
	setmetatable(uBBars, UnitBuffBars)      	-- make UnitBar handle lookup
	
	--debugPrint("creating buff bars for ",unitName, buffType, visibilityOptions, lengthThreshold, direction)
	
	-- store values for the bar
	uBBars.width = width
	uBBars.anchorThis = anchorThis
	uBBars.anchorParent = anchorParent
	uBBars.parentItem = parentItem
	uBBars.offsetX = offsetX
	uBBars.offsetY = offsetY
	uBBars.fontSize = MinUIConfig.frames[unitName].buffFontSize

	-- buff values
	uBBars.direction = direction
	uBBars.unitName = unitName
	uBBars.buffType = buffType
	uBBars.visibilityOptions = visibilityOptions
	uBBars.lengthThreshold = lengthThreshold
		
	-- scale font size if we have a scale
	if ( MinUIConfig.frames[uBBars.unitName].scale ) then
		uBBars.fontSize = uBBars.fontSize * MinUIConfig.frames[uBBars.unitName].scale
	end
	
	-- store buffs
	uBBars.activeBuffBars = {}
	uBBars.zombieBuffBars = {}

	-- create the frame
	uBBars.frame = UI.CreateFrame("Frame", "buffBars_"..buffType, parentItem)
	uBBars.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBBars.frame:SetWidth(uBBars.width + (MinUIConfig.frames[uBBars.unitName].itemOffset*2)) -- give "breathing room" at either end
	uBBars.frame:SetHeight(MinUIConfig.frames[uBBars.unitName].itemOffset)
	uBBars.frame:SetLayer(-1)
	uBBars.frame:SetVisible(true)
	uBBars.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	--debugPrint(uBBars)
	return uBBars
end

--
-- Create or Add Existing Buff Bar to the UnitBuffBars Anchor
--
function UnitBuffBars:addBuffBar(buff, time)

	-- attempt to reuse an old bar
	local bar = table.remove(self.zombieBuffBars)
	
	local unitName = self.unitName
	local width = self.width
	local fontSize = self.fontSize
	
	-- if no bar exist in our pool of bars then create one
	if not bar then
		-- We don't have any bars remaining, so we create a new one.
		-- Our Bars are considered single objects that can be dealt with atomically. Each one has the functionality needed to update itself.
		bar = UI.CreateFrame("Frame", "Bar", MinUI.context)

		-- Set location
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
		if (MinUIConfig.globalTextFont) then
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
		bar.textShadow:SetPoint("TOPLEFT", bar.icon, "TOPRIGHT", 1, 2) -- The textShadow is pinned to the top-right corner of the icon. yoffset by 2
		--bar:SetPoint("BOTTOM", bar.text, "BOTTOM")  -- The bar is set to always be as high as the text is.

		bar.timer:SetPoint("TOPRIGHT", bar, "TOPRIGHT") -- The timer is pinned to the top-right corner.
		bar.timerShadow:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 1, 2) -- The timerShadow is pinned to the top-right corner. yoffset by 2

		bar.text:SetPoint("RIGHT", bar.timer, "LEFT") -- Make sure the text doesn't overrun the timer. We'll be changing the text's height based on the contents, but we'll leave the width calculated this way.

		-- Set the solid bar to fill the entire buff bar.
		bar.solid:SetPoint("TOPLEFT", bar, "TOPLEFT")
		bar.solid:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
		bar.tex:SetPoint("TOPLEFT", bar, "TOPLEFT")
		bar.tex:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
		bar:SetWidth( self.width + MinUIConfig.frames[unitName].itemOffset )
		
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
				self:SetBackgroundColor(0.4, 0.4, 1.0, 0.2)
				self.solid:SetBackgroundColor(0.4, 0.4,1.0,0.6)
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
			
			self:Tick(time)
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
		  self.buffid = buff.id
		end
		
		--
		-- This is our update function, called once every frame.
		--
		function bar:Tick(time)
			if self.completion then
				local remaining = self.completion - time

				if remaining < 0 then
					self.timer:SetVisible(false)
					self.timerShadow:SetVisible(false)
				else
				  -- Update our timer.
					self.tex:SetPoint("RIGHT", bar, remaining / self.duration, nil)
					self.solid:SetPoint("RIGHT", bar, remaining / self.duration, nil)
	
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
				  
				end
			end
		end
		
		--
		-- Finally, if we're clicked, we want to cancel whatever buff is on us.
		--
		function bar.Event:RightDown()
		  Command.Buff.Cancel(self.buffid)
		end
	end
	
	table.insert(self.activeBuffBars, bar)

	-- Show the bar and set the data.
	bar:SetVisible(true)
	bar:SetBuff(buff, time)
	
	-- Attach it to the right spot.
	if not self.lastAttach then
		-- This is our first bar, so we're pinning it to the unit frame it belongs too
		if (self.direction == "up") then
			bar:SetPoint("BOTTOMCENTER", self.frame, "TOPCENTER", 0, 0)
		elseif (self.direction == "down") then
			bar:SetPoint("TOPCENTER", self.frame, "BOTTOMCENTER", 0, 0)
		end
	-- This isn't our first bar, so we pin it to the last bar.
	else
		if (self.direction == "up") then
			bar:SetPoint("BOTTOMCENTER", self.lastAttach, "TOPCENTER", 0, -MinUIConfig.frames[unitName].itemOffset)
		elseif (self.direction == "down") then
			bar:SetPoint("TOPCENTER", self.lastAttach, "BOTTOMCENTER", 0, MinUIConfig.frames[unitName].itemOffset)
		end
	end
	
	-- store the last bar as the current attachment point
	self.lastAttach = bar
end

--
-- Tick buff bars
--
function UnitBuffBars:tickBars(time)
	for _, bar in ipairs(self.activeBuffBars) do
		bar:Tick(time)
	end
end

--
-- Reset buff bars
--
function UnitBuffBars:resetBuffBars()
	----debugPrint("resetting buff bars on ", self.unitName)
	
	for _, bar in pairs(self.activeBuffBars) do
		table.insert(self.zombieBuffBars, bar)
		bar:SetVisible(false)
		bar:SetPoint("TOPCENTER", self.frame, "BOTTOMCENTER")
	end

	self.activeBuffBars = {}
	self.lastAttach = nil
end

-- 
-- Update the Buff Bars
--
function UnitBuffBars:update(time)
	-- inspect buffs for unitName
	local bufflist = Inspect.Buff.List(self.unitName)

	-- If we don't get anything, then we don't currently have information about the player.
	-- This may happen when the player is logging in or teleporting long distances.
	if bufflist then  
		local buffdetails = Inspect.Buff.Detail(self.unitName, bufflist)
		self:resetBuffBars(self.unitName)
		
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
					-- Showing all debuffs
					if(self.visibilityOptions == "all") then
						--debugPrint(buff.duration)
						-- Check the debuff is lessthan/equal to threshold length
						if(buff.duration) then
							if(buff.duration <= self.lengthThreshold)then
								table.insert(bbars, buff)
							end
						-- or we have auras
						elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
							table.insert(bbars, buff)
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
				-- If we have merged buffs/debuffs (we dont use the self visibility/threshold stuff)
				elseif (self.buffType == "merged") then
					-- Showing all debuffs
					if(MinUIConfig.frames[self.unitName].debuffVisibilityOptions == "all") then
						--debugPrint(buff.duration)
						-- Check the debuff is lessthan/equal to threshold length
						if(buff.duration) then
							if(buff.duration <= MinUIConfig.frames[self.unitName].debuffThreshold) then
								table.insert(bbars, buff)
							end
						-- or we have auras
						elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
							table.insert(bbars, buff)
						end
					-- Showing player debuffs
					elseif (MinUIConfig.frames[self.unitName].debuffVisibilityOptions == "player") then
						-- Check debuff was cast by player
						if (buff.caster == Inspect.Unit.Lookup("player")) then
							-- Check the buff is lessthan/equal to threshold length
							if(buff.duration) then
								if(buff.duration <= MinUIConfig.frames[self.unitName].debuffThreshold)then
									table.insert(bbars, buff)
								end
							-- or we have auras
							elseif(MinUIConfig.frames[self.unitName].debuffAuras)then
								table.insert(bbars, buff)
							end
						end
					end
				end
			else
				-- if we are showing buffType buffs
				if (self.buffType == "buffs") then
					-- Showing all buffs
					if(self.visibilityOptions == "all") then
						--debugPrint(buff.duration)
						-- Check the buff is lessthan/equal to threshold length
						if(buff.duration)then
							if(buff.duration <= self.lengthThreshold)then
								table.insert(bbars, buff)
							end
						-- or if we have auras
						elseif(MinUIConfig.frames[self.unitName].buffAuras)then
							table.insert(bbars, buff)
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
								end
							-- or if we have auras
							elseif(MinUIConfig.frames[self.unitName].buffAuras)then
								table.insert(bbars, buff)
							end							
						end
					end
				-- If we have merged buffs/debuffs (we dont use the self visibility/threshold stuff)
				elseif (self.buffType == "merged") then
					-- Showing all debuffs
					if(MinUIConfig.frames[self.unitName].buffVisibilityOptions == "all") then
						--debugPrint(buff.duration)
						-- Check the debuff is lessthan/equal to threshold length
						if(buff.duration) then
							if(buff.duration <= MinUIConfig.frames[self.unitName].buffThreshold) then
								table.insert(bbars, buff)
							end
						-- or if we have auras
						elseif(MinUIConfig.frames[self.unitName].buffAuras)then
							table.insert(bbars, buff)
						end						
					-- Showing player debuffs
					elseif (MinUIConfig.frames[self.unitName].buffVisibilityOptions == "player") then
						-- Check debuff was cast by player
						if (buff.caster == Inspect.Unit.Lookup("player")) then
							-- Check the buff is lessthan/equal to threshold length
							if(buff.duration) then
								if(buff.duration <= MinUIConfig.frames[self.unitName].buffThreshold)then
									table.insert(bbars, buff)
								end
							end
						-- or if we have auras
						elseif(MinUIConfig.frames[self.unitName].buffAuras)then
							table.insert(bbars, buff)
						end						
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
			self:addBuffBar(buff, time)
		end
	else
		self:resetBuffBars()
	end
end

-- refresh bars
local function update(time)
	addBuffsToUnitFrame( time)
end