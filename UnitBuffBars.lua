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
function UnitBuffBars.new( unitName, buffType, visibilityOptions, lengthThreshold, direction, width, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local uBBars = {}             			-- our new object
	setmetatable(uBBars, UnitBuffBars)      	-- make UnitBar handle lookup
	
	print("creating buff bars for ",unitName, buffType, visibilityOptions, lengthThreshold, direction)
	
	-- store values for the bar
	uBBars.width = width
	uBBars.fontSize = fontSize
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
	
	-- store buffs
	uBBars.activeBuffBars = {}
	uBBars.zombieBuffBars = {}

	-- create the frame
	uBBars.frame = UI.CreateFrame("Frame", "buffBars_"..buffType, parentItem)
	uBBars.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBBars.frame:SetWidth(uBBars.width)
	uBBars.frame:SetHeight(25)
	uBBars.frame:SetLayer(1)
	uBBars.frame:SetVisible(true)
	uBBars.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
	
	print(uBBars)
	return uBBars
end

--
-- Create or Add Existing Buff Bar to the UnitBuffBars Anchor
--
function UnitBuffBars:addBuffBar(buff, time)

	-- attempt to reuse an old bar
	local bar = table.remove(self.zombieBuffBars)
	
	-- if no bar exist in our pool of bars then create one
	if not bar then
		-- We don't have any bars remaining, so we create a new one.
		-- Our Bars are considered single objects that can be dealt with atomically. Each one has the functionality needed to update itself.
		bar = UI.CreateFrame("Frame", "Bar", MinUI.context)

		-- Set location
		bar:SetPoint("BOTTOMCENTER", self.frame, "TOPCENTER")

		bar.text = UI.CreateFrame("Text", "Text", bar)
		bar.text:SetLayer(1)
		bar.timer = UI.CreateFrame("Text", "Timer", bar)
		bar.icon = UI.CreateFrame("Texture", "Icon", bar)

		-- Solid background - this is the actual "bar" part of it.
		bar.solid = UI.CreateFrame("Frame", "Solid", bar)
		bar.solid:SetLayer(-1)  -- Put it behind every other element.
		
		bar.text:SetText("???")
		bar.text:SetFontSize(14)
		bar.text:SetHeight(bar.text:GetFullHeight())
		bar:SetHeight(bar.text:GetFullHeight())
		bar.solid:SetHeight(bar.text:GetFullHeight())

		bar.icon:SetPoint("TOPLEFT", bar, "TOPLEFT") -- The icon is pinned to the top-left corner of the bar.
		bar.icon:SetPoint("BOTTOM", bar, "BOTTOM") -- Vertically, it always fills the entire bar.

		bar.text:SetPoint("TOPLEFT", bar.icon, "TOPRIGHT") -- The text is pinned to the top-right corner of the icon.
		--bar:SetPoint("BOTTOM", bar.text, "BOTTOM")  -- The bar is set to always be as high as the text is.

		bar.timer:SetPoint("TOPRIGHT", bar, "TOPRIGHT") -- The timer is pinned to the top-right corner.

		bar.text:SetPoint("RIGHT", bar.timer, "LEFT") -- Make sure the text doesn't overrun the timer. We'll be changing the text's height based on the contents, but we'll leave the width calculated this way.

		-- Set the solid bar to fill the entire buff bar.
		bar.solid:SetPoint("TOPLEFT", bar, "TOPLEFT")
		bar.solid:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
		bar:SetWidth(MinUIConfig.unitFrameBarWidth + MinUIConfig.unitFrameOffset*2)
		
		--
		-- Set Buff - requires a buff and a timestamp
		--
		function bar:SetBuff(buff, time)
		  if buff.debuff then
			self:SetBackgroundColor(0.5, 0.0, 0.0, 0.3)
			self.solid:SetBackgroundColor(0.5, 0.0, 0.0)
			self.text:SetFontSize(14)
			self.timer:SetFontSize(14)
			self.text:SetHeight(self.text:GetFullHeight())
			self:SetHeight(self.text:GetFullHeight())
			self.solid:SetHeight(self.text:GetFullHeight())
		  else
			-- Buffs are blue-themed.
			self:SetBackgroundColor(0.2, 0.2, 0.6, 0.3)
			self.solid:SetBackgroundColor(0.2, 0.2, 0.6)
			if (buff.caster == Inspect.Unit.Lookup("player")) then
				self.text:SetFontSize(14)
				self.timer:SetFontSize(14)
			else
				self.text:SetFontSize(10)
				self.timer:SetFontSize(10)
			end
			self.text:SetHeight(self.text:GetFullHeight())
			self:SetHeight(self.text:GetFullHeight())
			self.solid:SetHeight(self.text:GetFullHeight())
		  end
		  
		  -- Re-square and set the icon
		  self.icon:SetWidth(self.icon:GetHeight())
		  self.icon:SetTexture("Rift", buff.icon)

		  -- Display our stacking multiple.
		  if buff.stack then
			self.text:SetText(buff.name .. " (" .. buff.stack .. ")")
		  else
			self.text:SetText(buff.name)
		  end
		  
		  if buff.duration then
			self.completion = buff.begin + buff.duration
			self.duration = buff.duration
			
			-- Display everything we might have hidden.
			self.solid:SetVisible(true)
			self.timer:SetVisible(true)
			
			self:Tick(time)
		  else
			self.completion = nil
			
			-- This is a permanent buff without a timer, so don't show any of that.
			self.solid:SetVisible(false)
			self.timer:SetVisible(false)
			self.timer:SetWidth(0)
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
				else
				  -- Update our timer.
					self.solid:SetPoint("RIGHT", bar, remaining / self.duration, nil)
	
				  -- Generate the timer text string.
				  if remaining >= 3600 then
					self.timer:SetText(string.format("%d:%02d:%02d", math.floor(remaining / 3600), math.floor(remaining / 60) % 60, math.floor(remaining) % 60))
				  else
					self.timer:SetText(string.format("%d:%02d", math.floor(remaining / 60), math.floor(remaining) % 60))
				  end
				  
				  -- Update the width to avoid truncation.
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
		bar:SetPoint("BOTTOMCENTER", self.frame, "TOPCENTER", 0, -10)
	else
		-- This isn't our first bar, so we pin it to the last bar.
		if self.lastAttach.debuff ~= buff.debuff then
		  -- We're the first debuff, so add a gap between us and the last bar.
		  bar:SetPoint("BOTTOMCENTER", self.lastAttach, "TOPCENTER", 0, -5)
		else
		  -- Otherwise, we're flush with the last bar.
		  bar:SetPoint("BOTTOMCENTER", self.lastAttach, "TOPCENTER", 0, -2)
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
	--print("resetting buff bars on ", self.unitName)
	
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
			
			-- only add buffs that this buffbar unit is watching
			if (buff.debuff) then
				if (self.buffType == "debuffs") then
					table.insert(bbars, buff)
				end
			else
				if (self.buffType == "buffs") then
					table.insert(bbars, buff)
				end
			end
		end

		-- sort on time
		table.sort(
			bbars, function (a, b)
				--if a.debuff ~= b.debuff then
				--  return b.debuff
				--end
				
				if a.duration and b.duration then return a.remaining > b.remaining end
				if not a.duration and not b.duration then return false end
				return not a.duration
			end
		)
		
		
		-- Now that we have the ordering, we just add the bars one at a time. Done!
		for k, buff in ipairs(bbars) do
			-- if the buff is a debuff...
			--if ( buff.debuff ) then
				-- if the frame is configured to show only player cast debuffs
				--if(MinUIConfig.showPlayerDebuffsOnly[unitName] == true) then
				--	if (buff.caster == Inspect.Unit.Lookup("player")) then
						self:addBuffBar(buff, time)
				--	end
				-- if the frame is configured to show all debuffs
				--elseif(MinUIConfig.showAllDebuffs[unitName] == true) then
				--	addBuffBar(unitName, buff, time)
				--end
			-- the buff is a buff :P
			--else
				-- if the frame is configured to show only player cast buffs
				--if(MinUIConfig.showPlayerBuffsOnly[unitName] == true) then
				--	if (buff.caster == Inspect.Unit.Lookup("player")) then
				--		addBuffBar(unitName, buff, time)
				--	end
				-- if the frame is configured to show all buffs
				--elseif(MinUIConfig.showAllBuffs[unitName] == true) then
					--self:addBuffBar(buff, time)
				--end
			--end
		end
	end
end

-- refresh bars
local function update(time)
	addBuffsToUnitFrame( time)
end