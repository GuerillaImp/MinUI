-----------------------------------------------------------------------------------------------------------------------------
--
-- MinUI Global Settings/Values
--
----------------------------------------------------------------------------------------------------------------------------- 
MinUI = {}
MinUI.context = UI.CreateContext("MinUIContext")

-- Unit Frames
MinUI.frames = {}

-- Buff Control
MinUI.resyncBuffs = false

-- spam control
MinUI.debugging = false

-- store this
MinUI.playerCalling = "unknown"
MinUI.playerDetails = false
MinUI.initialised = false

-----------------------------------------------------------------------------------------------------------------------------
--
-- Values that Control the Way Things Look
--
----------------------------------------------------------------------------------------------------------------------------- 
-- frames
MinUI.unitFrameBarWidth = 250
MinUI.unitFrameBarHeight = 25
MinUI.unitFrameOffset = 2
MinUI.comboPointsBarHeight = 5
-- buffs
MinUI.playersDebuffsOnly = true -- player's debuffs only on target 

-- TOODO use this to determine which frames to show buffs/debuffs on
MinUI.showDebuffsOn = {"player","player.target"}
MinUI.showBuffsOn = {"player.target"}

-----------------------------------------------------------------------------------------------------------------------------
--
-- Unit Frame Functions
--
-----------------------------------------------------------------------------------------------------------------------------
local function debugPrint(...)
	if( MinUI.debugging == true) then
		print(...)
	end
end
 
local function showUnitFrame(unitName)
	MinUI.frames[unitName]["unitFrame"]:SetVisible(true)
end

local function hideUnitFrame(unitName)
	MinUI.frames[unitName]["unitFrame"]:SetVisible(false)
end

local function moveUnitFrame(unitName, x, y)
	MinUI.frames[unitName]["unitFrame"]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x,y )
end

-- reset buff bars
local function resetBuffBars(unitName)
	debugPrint("resetting buff bars on ", unitName)
	
	for _, bar in pairs(MinUI.frames[unitName]["activeBuffBars"]) do
		table.insert(MinUI.frames[unitName]["zombieBuffBars"], bar)
		bar:SetVisible(false)
		bar:SetPoint("TOPCENTER", MinUI.frames[unitName]["unitFrame"], "BOTTOMCENTER")
	end

	MinUI.frames[unitName]["activeBuffBars"] = {}
	MinUI.frames[unitName]["lastAttach"] = nil
end

-- updateUnitFrame the given unitName
local function updateUnitFrame(unitName)
	-- get details
	local details = Inspect.Unit.Detail(unitName)
	local playerDetails = Inspect.Unit.Detail("player")

	-- if we have anything
	if details then
		local unitCalling = details.calling
		local health = details.health
		local healthMax = details.healthMax
		local healthRatio = health/healthMax
		local healthPercent = math.floor(healthRatio * 100)
		
		-- init power vars
		local power = 0
		local powerMax = 0
		local powerRatio = 1
		local powerPercent = 0
		
		-- player / class specific
		local rogueComboPoints = 0
		local warriorComboPoints = 0
		local mageCharge = 0
		
		if MinUI.playerCalling == "warrior" then
			warriorComboPoints = playerDetails.combo
		elseif MinUI.playerCalling == "mage" then
			mageCharge = playerDetails.charge
		elseif MinUI.playerCalling == "rogue" then
			rogueComboPoints = playerDetails.combo
		end
		
		-- updateUnitFrame based on class
		if unitCalling == "rogue" then
			power = details.energy
			powerMax = details.energyMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif unitCalling == "mage" then
			power = details.mana
			powerMax = details.manaMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif unitCalling == "cleric" then
			power = details.mana
			powerMax = details.manaMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif unitCalling == "warrior" then
			power = details.power
			powerMax = 100
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		end
		
		local name = details.name
		local level = details.level
		local unitText = name .. " - Lv " .. level .. " "
		
		if unitCalling then
			unitText = unitText .. " (" .. unitCalling .. ")"
		end
		
		local powerText = string.format("%s/%s (%s%%)", power, powerMax, powerPercent)
		local healthText = string.format("%s/%s (%s%%)", health, healthMax, healthPercent)
		
		-- updateUnitFrame texts
		MinUI.frames[unitName]["healthText"]:SetText(healthText)
		MinUI.frames[unitName]["healthTextShadow"]:SetText(healthText)
		MinUI.frames[unitName]["powerText"]:SetText(powerText)
		MinUI.frames[unitName]["powerTextShadow"]:SetText(powerText)
		MinUI.frames[unitName]["unitText"]:SetText(unitText)
		MinUI.frames[unitName]["unitTextShadow"]:SetText(unitText)
		MinUI.frames[unitName]["healthBar"]:SetWidth(MinUI.unitFrameBarWidth * healthRatio)
		MinUI.frames[unitName]["powerBar"]:SetWidth(MinUI.unitFrameBarWidth * powerRatio)
		
		-- player class specific frames
		if (MinUI.playerCalling == "rogue") then
			if(MinUI.frames[unitName]["comboPointsBar"]) then
				if (rogueComboPoints) then
					debugPrint("combo points", rogueComboPoints ) 
					local comboPointRatio = rogueComboPoints / 5
					MinUI.frames["player.target"]["comboPointsBar"]:SetWidth(MinUI.unitFrameBarWidth * comboPointRatio)
					MinUI.frames["player.target"]["comboPointsBar"]:SetHeight(MinUI.comboPointsBarHeight)
					MinUI.frames["player.target"]["comboPointsBar"]:SetBackgroundColor(1.0, 0.75, 0.14, 1.0)
					MinUI.frames["player.target"]["comboPointsBar"]:SetPoint("TOPLEFT", MinUI.frames["player.target"]["powerBar"], "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
				end
			end
		elseif (MinUI.playerCalling == "warrior") then
			if(MinUI.frames[unitName]["warriorComboPointsBar"]) then
				if (warriorComboPoints) then
					debugPrint("combo points",warriorComboPoints ) 
					local comboPointRatio = warriorComboPoints / 3
					MinUI.frames["player"]["warriorComboPointsBar"]:SetWidth(MinUI.unitFrameBarWidth * comboPointRatio)
					MinUI.frames["player"]["warriorComboPointsBar"]:SetHeight(MinUI.comboPointsBarHeight)
					MinUI.frames["player"]["warriorComboPointsBar"]:SetBackgroundColor(1.0, 0.35, 0.14, 1.0)
					MinUI.frames["player"]["warriorComboPointsBar"]:SetPoint("TOPLEFT", MinUI.frames["player"]["powerBar"], "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
				end
			end
		elseif (MinUI.playerCalling == "mage") then
			if(MinUI.frames[unitName]["mageChargeBar"]) then
				if (mageCharge) then
					debugPrint("mage charge",mageCharge ) 
					local mageChargeRatio = mageCharge / 100
					MinUI.frames["player"]["mageChargeText"]:SetText(string.format("%s", mageCharge))
					MinUI.frames["player"]["mageChargeText"]:SetPoint("CENTERRIGHT", MinUI.frames["player"]["mageChargeBar"], "CENTERRIGHT", 0, 0)
					MinUI.frames["player"]["mageChargeText"]:SetWidth(MinUI.frames["player"]["mageChargeText"]:GetFullWidth())
					MinUI.frames["player"]["mageChargeText"]:SetHeight(MinUI.frames["player"]["mageChargeText"]:GetFullWidth())
		
					MinUI.frames["player"]["mageChargeBar"]:SetWidth(MinUI.unitFrameBarWidth * mageChargeRatio)
					MinUI.frames["player"]["mageChargeBar"]:SetHeight(15)
					MinUI.frames["player"]["mageChargeBar"]:SetBackgroundColor(0.0, 0.5, 0.5, 1.0)
					MinUI.frames["player"]["mageChargeBar"]:SetPoint("TOPLEFT", MinUI.frames["player"]["powerBar"], "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
				end
			end
		end

		-- health color
		if healthPercent >= 50 then
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
		elseif healthPercent < 50 and healthPercent >= 25 then
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.3, 0.3, 0.0, 1.0)
		elseif healthPercent < 25 then
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
		end
		
		-- colour based on class
		if unitCalling == "rogue" then
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.3, 0.0, 0.3, 1.0)
		elseif unitCalling == "mage" or unitCalling == "cleric" then
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.3, 1.0)
		elseif unitCalling == "warrior" then
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
		else
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		
		showUnitFrame(unitName)
	else
		debugPrint("no details for ", unitName, " so hiding for now")
		hideUnitFrame(unitName)
		resetBuffBars(unitName)
		MinUI.frames[unitName]["healthText"]:SetText("")
		MinUI.frames[unitName]["healthTextShadow"]:SetText("")
		MinUI.frames[unitName]["powerText"]:SetText("")
		MinUI.frames[unitName]["powerTextShadow"]:SetText("")
		MinUI.frames[unitName]["unitText"]:SetText("")
		MinUI.frames[unitName]["unitTextShadow"]:SetText("")
		MinUI.frames[unitName]["healthBar"]:SetWidth(MinUI.unitFrameBarWidth)
		MinUI.frames[unitName]["powerBar"]:SetWidth(MinUI.unitFrameBarWidth)
		if(MinUI.frames[unitName]["comboPointsBar"]) then
			MinUI.frames[unitName]["comboPointsBar"]:SetWidth(MinUI.unitFrameBarWidth)
			MinUI.frames[unitName]["comboPointsBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		if(MinUI.frames[unitName]["warriorComboPointsBar"]) then
			MinUI.frames[unitName]["warriorComboPointsBar"]:SetWidth(MinUI.unitFrameBarWidth)
			MinUI.frames[unitName]["warriorComboPointsBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		
	end
end


-- create unit frame for "unitName"
local function createUnitFrame(unitName)
	debugPrint("creating frame ... ", unitName)
	
	if ( MinUI.frames[unitName] ) then
		debugPrint("unit frame already exists, not creating")
		return
	end
	
	-- use this for class colour text and other items eventually
	local details = Inspect.Unit.Detail(unitName)
	local unitCalling 
	if details then
		unitCalling = details.calling
	else
		unitCalling = "no_calling"
	end
	
	local unitFrame = UI.CreateFrame("Frame", "unitFrame", MinUI.context)
	local healthBar = UI.CreateFrame("Frame", "healthBar", unitFrame)
	local healthText = UI.CreateFrame("Text", "healthText", healthBar)
	local healthTextShadow = UI.CreateFrame("Text", "healthText", healthBar)
	local powerBar = UI.CreateFrame("Frame", "powerBar", healthBar)
	local powerText = UI.CreateFrame("Text", "powerText", powerBar)
	local powerTextShadow = UI.CreateFrame("Text", "powerTextShadow", powerBar)
	local unitText = UI.CreateFrame("Text", "unitText", unitFrame)
	local unitTextShadow = UI.CreateFrame("Text", "unitTextShadow", unitFrame)
	-- class specific
	local comboPointsBar = nil
	local warriorComboPointsBar = nil
	local mageChargeBar = nil
	local mageChargeText = nil
	
	
	-- center new frame
	unitFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0.0, 0.0)
	unitFrame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
	
	-- MinUI.frames[unitName]["unitFrame"] for health
	healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", MinUI.unitFrameOffset, MinUI.unitFrameOffset)
	healthBar:SetVisible(true)
	healthBar:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
	healthBar:SetLayer(-1)
	healthBar:SetWidth(MinUI.unitFrameBarWidth)
	healthBar:SetHeight(MinUI.unitFrameBarHeight)
	
	healthText:SetFontSize(14)
	healthText:SetPoint("CENTERLEFT", healthBar, "CENTERLEFT", 0, 0)
	healthText:SetLayer(2)
	healthText:SetWidth(MinUI.unitFrameBarWidth)
	healthText:SetHeight(MinUI.unitFrameBarHeight)
	healthTextShadow:SetFontSize(14)
	healthTextShadow:SetPoint("CENTERLEFT", healthBar, "CENTERLEFT", 1, 1)
	healthTextShadow:SetLayer(1)
	healthTextShadow:SetFontColor(0, 0, 0, 1)
	healthTextShadow:SetWidth(MinUI.unitFrameBarWidth)
	healthTextShadow:SetHeight(MinUI.unitFrameBarHeight)

	
	-- MinUI.frames[unitName]["unitFrame"] for power
	powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
	powerBar:SetVisible(true)
	powerBar:SetLayer(-1)
	powerBar:SetWidth(MinUI.unitFrameBarWidth)
	powerBar:SetHeight(MinUI.unitFrameBarHeight)
	powerBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	powerText:SetFontSize(14)
	powerText:SetPoint("CENTERLEFT", powerBar, "CENTERLEFT", 0, 0)
	powerText:SetLayer(2)
	powerText:SetWidth(MinUI.unitFrameBarWidth)
	powerText:SetHeight(MinUI.unitFrameBarHeight)
	powerTextShadow:SetFontSize(14)
	powerTextShadow:SetPoint("CENTERLEFT", powerBar, "CENTERLEFT", 1, 1)
	powerTextShadow:SetLayer(1)
	powerTextShadow:SetFontColor(0, 0, 0, 1)
	powerTextShadow:SetWidth(MinUI.unitFrameBarWidth)
	powerTextShadow:SetHeight(MinUI.unitFrameBarHeight)
	
	-- calculate width / height up to here, add more as required
	local unitFrameWidth = MinUI.unitFrameBarWidth + (MinUI.unitFrameOffset*2)
	local unitFrameHeight = (MinUI.unitFrameBarHeight*2) + (MinUI.unitFrameOffset*3)
	
	--
	-- Class specific stuff
	--
	
	-- Attach combo points to underneath target's powerbar if player is rogue and we are creating the target frame
	if (MinUI.playerCalling == "rogue" and unitName == "player.target") then
		comboPointsBar = UI.CreateFrame("Frame", "comboPointsBar", powerBar)
		comboPointsBar:SetLayer(-1)
		comboPointsBar:SetWidth(MinUI.unitFrameBarWidth)
		comboPointsBar:SetBackgroundColor(1.0, 0.0, 0.0, 0.0)
		comboPointsBar:SetHeight(MinUI.comboPointsBarHeight)
		comboPointsBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
		unitFrameHeight = unitFrameHeight + MinUI.comboPointsBarHeight + MinUI.unitFrameOffset
	-- Attach warrior combo points to underneath players powerbar since they are persistent
	elseif (MinUI.playerCalling == "warrior" and unitName == "player") then
		warriorComboPointsBar = UI.CreateFrame("Frame", "warriorComboPointsBar", powerBar)
		warriorComboPointsBar:SetLayer(-1)
		warriorComboPointsBar:SetWidth(MinUI.unitFrameBarWidth)
		warriorComboPointsBar:SetBackgroundColor(0.0, 0.0, 0.0, 1.0)
		warriorComboPointsBar:SetHeight(MinUI.comboPointsBarHeight)
		warriorComboPointsBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
		unitFrameHeight = unitFrameHeight + MinUI.comboPointsBarHeight + MinUI.unitFrameOffset
	-- Attach mage Charge combo points to underneath players powerbar since they are persistent
	elseif (MinUI.playerCalling == "mage" and unitName == "player") then
		mageChargeBar = UI.CreateFrame("Frame", "mageChargeBar", powerBar)
		mageChargeBar:SetLayer(-1)
		mageChargeBar:SetWidth(MinUI.unitFrameBarWidth)
		mageChargeBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		mageChargeBar:SetHeight(15)
		mageChargeBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, MinUI.unitFrameOffset)
		
		mageChargeText = UI.CreateFrame("Text", "mageChargeText", mageChargeBar)
		mageChargeText:SetFontSize(10)
		mageChargeText:SetLayer(2)
		mageChargeText:SetPoint("CENTERRIGHT", mageChargeBar, "CENTERRIGHT", 0, 0)
		mageChargeText:SetWidth(mageChargeText:GetFullWidth())
		mageChargeText:SetHeight(mageChargeText:GetFullWidth())
		
		unitFrameHeight = unitFrameHeight + 15 + MinUI.unitFrameOffset
	end
	
	-- MinUI.frames[unitName]["unitFrame"] for name	
	unitText:SetFontSize(14)
	unitText:SetPoint("TOPCENTER", unitFrame, "BOTTOMCENTER", 0, 0)
	unitText:SetLayer(2)
	unitText:SetWidth(MinUI.unitFrameBarWidth)
	unitText:SetHeight(MinUI.unitFrameBarHeight)
	unitTextShadow:SetFontSize(14)
	unitTextShadow:SetPoint("TOPCENTER", unitFrame, "BOTTOMCENTER", 1, 1)
	unitTextShadow:SetLayer(1)
	unitTextShadow:SetFontColor(0, 0, 0, 1)
	unitTextShadow:SetWidth(MinUI.unitFrameBarWidth)
	unitTextShadow:SetHeight(MinUI.unitFrameBarHeight)
	

	unitFrame:SetHeight(unitFrameHeight)
	unitFrame:SetWidth(unitFrameWidth)

	
	--Gumaden's Movement Code
    function unitFrame.Event:LeftDown()
		debugPrint("frame clicked", unitName)
		self.MouseDown = true
		mouseData = Inspect.Mouse()
		self.MyStartX = unitFrame:GetLeft()
		self.MyStartY = unitFrame:GetTop()
		self.StartX = mouseData.x - self.MyStartX
		self.StartY = mouseData.y - self.MyStartY
		tempX = unitFrame:GetLeft()
		tempY = unitFrame:GetTop()
		tempW = unitFrame:GetWidth()
		tempH =	unitFrame:GetHeight()
		unitFrame:ClearAll()
		unitFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", tempX, tempY)
		unitFrame:SetWidth(tempW)
		unitFrame:SetHeight(tempH)
		self:SetBackgroundColor(0.3,0.0,0.0,0.5)
	end
	function unitFrame.Event:MouseMove()
		if self.MouseDown then
			local newX, newY
			mouseData = Inspect.Mouse()
			newX = mouseData.x - self.StartX
			newY = mouseData.y - self.StartY
			unitFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", newX, newY)
		end
	end
	function unitFrame.Event:LeftUp()
		if self.MouseDown then
			self.MouseDown = false
			unitFrame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
		end
	end
	--Gumaden's Movement Code END
	
	-- save the frame
	MinUI.frames[unitName] = {}
	MinUI.frames[unitName]["unitFrame"] = unitFrame
	MinUI.frames[unitName]["healthBar"] = healthBar
	MinUI.frames[unitName]["healthText"] = healthText
	MinUI.frames[unitName]["healthTextShadow"] = healthTextShadow
	MinUI.frames[unitName]["powerBar"] = powerBar
	MinUI.frames[unitName]["powerText"] = powerText
	MinUI.frames[unitName]["powerTextShadow"] = powerTextShadow
	MinUI.frames[unitName]["unitText"] = unitText
	MinUI.frames[unitName]["unitTextShadow"] = unitTextShadow
	MinUI.frames[unitName]["comboPointsBar"] = comboPointsBar
	MinUI.frames[unitName]["warriorComboPointsBar"] = warriorComboPointsBar
	MinUI.frames[unitName]["mageChargeBar"] = mageChargeBar
	MinUI.frames[unitName]["mageChargeText"] = mageChargeText
	MinUI.frames[unitName]["activeBuffBars"] = {}
	MinUI.frames[unitName]["zombieBuffBars"] = {}
	MinUI.frames[unitName]["MinUI.playerCalling"] = MinUI.playerCalling -- used to handle when rift doesnt give us the info we need straight away
	MinUI.frames[unitName]["lastAttach"] = nil
end



-- update all the frames we have
local function updateUnitFrames()
	for key, value in pairs(MinUI.frames) do
		debugPrint("updating ",key)
		updateUnitFrame(key)
	end
end

-- add buff bar
local function addBuffBar(unitName, buff, time)
	local bar = table.remove(MinUI.frames[unitName]["zombieBuffBars"])
	
	-- for now we only add things to the player's target
	if unitName == "player.target" then
		-- if no bar exist in our pool of bars then create one
		if not bar then
			-- We don't have any bars remaining, so we create a new one.
			-- Our Bars are considered single objects that can be dealt with atomically. Each one has the functionality needed to update itself.
			bar = UI.CreateFrame("Frame", "Bar", MinUI.context)

			-- Set location
			bar:SetPoint("BOTTOMCENTER", MinUI.frames[unitName]["unitFrame"], "TOPCENTER")

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
			bar:SetWidth(MinUI.unitFrameBarWidth + MinUI.unitFrameOffset*2)
			
			-- The function that actually sets everything.
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
				-- Buffs are smaller and blue-themed.
				self:SetBackgroundColor(0.2, 0.2, 0.6, 0.3)
				self.solid:SetBackgroundColor(0.2, 0.2, 0.6)
				if (buff.caster == Inspect.Unit.Lookup("player")) then
					self.text:SetFontSize(12)
					self.timer:SetFontSize(12)
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
			
			-- This is our update function, called once every frame.
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
			
			-- Finally, if we're clicked, we want to cancel whatever buff is on us.
			function bar.Event:RightDown()
			  Command.Buff.Cancel(self.buffid)
			end
		end
		
		table.insert(MinUI.frames[unitName]["activeBuffBars"], bar)

		-- Show the bar and set the data.
		bar:SetVisible(true)
		bar:SetBuff(buff, time)
		
		-- Attach it to the right spot.
		if not MinUI.frames[unitName]["lastAttach"] then
			-- This is our first bar, so we're pinning it to the unit frame it belongs too
			bar:SetPoint("BOTTOMCENTER", MinUI.frames[unitName]["unitFrame"], "TOPCENTER", 0, -10)
		else
			-- This isn't our first bar, so we pin it to the last bar.
			if MinUI.frames[unitName]["lastAttach"].debuff ~= buff.debuff then
			  -- We're the first debuff, so add a gap between us and the last bar.
			  bar:SetPoint("BOTTOMCENTER", MinUI.frames[unitName]["lastAttach"], "TOPCENTER", 0, -5)
			else
			  -- Otherwise, we're flush with the last bar.
			  bar:SetPoint("BOTTOMCENTER", MinUI.frames[unitName]["lastAttach"], "TOPCENTER", 0, -2)
			end
		end
		
		-- store the last bar as the current attachment point
		MinUI.frames[unitName]["lastAttach"] = bar
	end
end

-- 
local function addBuffsToUnitFrame(unitName, time)
	-- inspect buffs for unitName
	local bufflist = Inspect.Buff.List(unitName)
	-- If we don't get anything, then we don't currently have information about the player.
	-- This may happen when the player is logging in or teleporting long distances.
	if bufflist then  
		local buffdetails = Inspect.Buff.Detail(unitName, bufflist)
		resetBuffBars(unitName)
		
		-- We want to order buffs by their time remaining
		-- splitting apart buffs and debuffs.
		local bbars = {}
		for id, buff in pairs(buffdetails) do
		buff.id = id  -- Make a copy of the ID, because we'll need it
		table.insert(bbars, buff)
		end

		-- sort on time
		table.sort(
			bbars, function (a, b)
				if a.debuff ~= b.debuff then
				  return b.debuff
				end
				
				if a.duration and b.duration then return a.remaining > b.remaining end
				if not a.duration and not b.duration then return false end
				return not a.duration
			end
		)
		
		-- Now that we have the ordering, we just add the bars one at a time. Done!
		for k, buff in ipairs(bbars) do
			-- if the buff is a debuff...
			if (buff.debuff) then
				if(MinUI.playersDebuffsOnly == true) then
					-- TODO: Check if the player can cleanse this buff if so show it for cleansing
					if (buff.caster == Inspect.Unit.Lookup("player")) then
						addBuffBar(unitName, buff, time)
					end
				else
					addBuffBar(unitName, buff, time)
				end
			-- we are going to show all buffs for purging
			else
				addBuffBar(unitName, buff, time)
			end
		end
	end
end

-- refresh bars
local function refresh(time)
	-- check all the frames we have / add buffs as required
	for unitName, value in pairs(MinUI.frames) do
		addBuffsToUnitFrame(unitName, time)
	end
end

local function getPlayerDetails()
	-- based on player class some things are different
	local playerDetails = Inspect.Unit.Detail("player")
	if (playerDetails) then
		MinUI.playerCalling = playerDetails.calling
	end
	
	-- did we get it yet?
	if (MinUI.playerCalling == "unknown") then
		MinUI.playerDetails = false
	else
		MinUI.playerDetails = true
	end
	
	debugPrint ("player calling is... ", MinUI.playerCalling)
end

-- setup frames
local function initialiseFrames()
	createUnitFrame("player")
	createUnitFrame("player.pet")
	createUnitFrame("player.target")
	createUnitFrame("player.target.target")

	local unitFrameWidth = MinUI.unitFrameBarWidth + (MinUI.unitFrameOffset*2)
	moveUnitFrame("player",500,600)
	moveUnitFrame("player.pet",500 -  unitFrameWidth - 10,600)
	moveUnitFrame("player.target",1200,600)
	moveUnitFrame("player.target.target",1200 + unitFrameWidth + 10,600)

	-- updates the unit frame details
	updateUnitFrames()
	--showUnitFrame("player") -- not sure why this doesn't just happen :/
end

-- resync bars / tick
local function tick()
	-- try and get calling until we do
	if (MinUI.playerDetails == false) then
		getPlayerDetails()
	else
		-- once we get the players calling initialise the frames
		if (MinUI.initialised == false) then
			initialiseFrames()
			MinUI.resyncBuffs = true
			MinUI.initialised = true
		end
		if MinUI.resyncBuffs then
			-- A recalculation has been queued, so go ahead and recalculate.
			refresh(Inspect.Time.Frame())
			MinUI.resyncBuffs = false
		else
		-- Just do a tick refresh
		local time = Inspect.Time.Frame()
			for unitName, value in pairs(MinUI.frames) do
				for _, v in ipairs(MinUI.frames[unitName]["activeBuffBars"]) do
					v:Tick(time)
				end
			end
		end
	end
end


-----------------------------------------------------------------------------------------------------------------------------
--
-- Helpers
--
-----------------------------------------------------------------------------------------------------------------------------

-- target changed
local function targetChanged()
	debugPrint("target changed")
	updateUnitFrames()
	MinUI.resyncBuffs = true
end

-----------------------------------------------------------------------------------------------------------------------------
--
-- Startup
--
-----------------------------------------------------------------------------------------------------------------------------
local function startup()
	--
	-- event hooks
	--
	
	-- UnitFrames
	table.insert(Event.Unit.Detail.Health, {updateUnitFrames, "MinUI", "updateUnitFrames"})
	table.insert(Event.Unit.Detail.Mana, {updateUnitFrames, "MinUI", "updateUnitFrames"})
	table.insert(Event.Unit.Detail.Energy, {updateUnitFrames, "MinUI", "updateUnitFrames"})
	table.insert(Event.Ability.Target, {targetChanged, "MinUI", "updateUnitFrames"})

	-- Buffs
	table.insert(Event.Buff.Add, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Change, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})
	table.insert(Event.Buff.Remove, {function () MinUI.resyncBuffs = true end, "MinUI", "refresh"})

	-- Our update event
	table.insert(Event.System.Update.Begin, {tick, "MinUI", "refresh"})
end

startup()



