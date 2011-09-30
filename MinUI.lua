--
-- MinUI UnitFrames by Grantus
--

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

-- Player Calling / Initialisation
MinUI.playerCalling = "unknown"
MinUI.playerDetailsKnown = false
MinUI.initialised = false

-----------------------------------------------------------------------------------------------------------------------------
--
-- Unit Frame Functions
--
-----------------------------------------------------------------------------------------------------------------------------
local function showUnitFrame(unitName)
	MinUI.frames[unitName]["unitFrame"]:SetVisible(true)
end

local function hideUnitFrame(unitName)
	MinUI.frames[unitName]["unitFrame"]:SetVisible(false)
end

local function setUnitFrameLocation(unitName, x, y)
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


-- update with details given
local function setFrameDetails(unitName, unitDetails)
	local playerDetails = Inspect.Unit.Detail("player")
	
	-- if we have anything
	if unitDetails then
		local unitCalling = unitDetails.calling
		local health = unitDetails.health
		local healthMax = unitDetails.healthMax
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
			power = unitDetails.energy
			powerMax = unitDetails.energyMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif unitCalling == "mage" then
			power = unitDetails.mana
			powerMax = unitDetails.manaMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif unitCalling == "cleric" then
			power = unitDetails.mana
			powerMax = unitDetails.manaMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif unitCalling == "warrior" then
			power = unitDetails.power
			powerMax = 100
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		end
		
		local name = unitDetails.name
		local level = unitDetails.level
		local guild = unitDetails.guild
		local unitText = name .. " "
		
		if guild then
			unitText = unitText .. "<" .. guild .. ">"
		end
		
		unitText = unitText .. " " .. level .. " "
		
		if unitCalling then
			unitText = unitText .. " " .. unitCalling .. ""
		end
		
		
		-- Update Unit Frame Values
		if(MinUIConfig.showHealthBar[unitName]) then
			local healthText = string.format("%s/%s (%s%%)", health, healthMax, healthPercent)
			MinUI.frames[unitName]["healthText"]:SetText(healthText)
			MinUI.frames[unitName]["healthTextShadow"]:SetText(healthText)
			MinUI.frames[unitName]["healthBar"]:SetWidth(MinUIConfig.unitFrameBarWidth * healthRatio)
		end
		if(MinUIConfig.showPowerBar[unitName]) then
			local powerText = string.format("%s/%s (%s%%)", power, powerMax, powerPercent)
			MinUI.frames[unitName]["powerText"]:SetText(powerText)
			MinUI.frames[unitName]["powerTextShadow"]:SetText(powerText)		
			MinUI.frames[unitName]["powerBar"]:SetWidth(MinUIConfig.unitFrameBarWidth * powerRatio)
		end
		if(MinUIConfig.showUnitText[unitName]) then
		
			MinUI.frames[unitName]["unitText"]:SetText(unitText)
			
			if(unitDetails.relation == "friendly") then
				MinUI.frames[unitName]["unitText"]:SetFontColor(0, 0.9, 0, 1)
			elseif(unitDetails.relation == "hostile") then
				MinUI.frames[unitName]["unitText"]:SetFontColor(0.9, 0, 0, 1)
			else
				MinUI.frames[unitName]["unitText"]:SetFontColor(0.9, 0.9, 0.0, 1)
			end
			
			MinUI.frames[unitName]["unitTextShadow"]:SetText(unitText)
			MinUI.frames[unitName]["unitText"]:SetHeight( MinUI.frames[unitName]["unitText"]:GetFullHeight() )
			MinUI.frames[unitName]["unitTextShadow"]:SetHeight( MinUI.frames[unitName]["unitText"]:GetFullHeight() )
			MinUI.frames[unitName]["unitText"]:SetWidth( MinUI.frames[unitName]["unitText"]:GetFullWidth() )
			MinUI.frames[unitName]["unitTextShadow"]:SetWidth( MinUI.frames[unitName]["unitText"]:GetFullWidth() )
		end
		
		-- Player Calling Specific Frames
		if (MinUI.playerCalling == "rogue") then
			if(MinUI.frames[unitName]["comboPointsBar"]) then
				if (rogueComboPoints) then
					debugPrint("combo points", rogueComboPoints ) 
					local comboPointRatio = rogueComboPoints / 5
					if (MinUIConfig.showComboBox) then
						MinUI.frames["player.target"]["comboPointsBoxText"]:SetText(string.format("%s", rogueComboPoints))
						MinUI.frames["player.target"]["comboPointsBoxText"]:SetWidth(MinUI.frames["player.target"]["comboPointsBoxText"]:GetFullWidth() + MinUIConfig.unitFrameOffset )
						MinUI.frames["player.target"]["comboPointsBoxText"]:SetHeight(MinUI.frames["player.target"]["comboPointsBoxText"]:GetFullHeight()+ MinUIConfig.unitFrameOffset)
						MinUI.frames["player.target"]["comboPointsBox"]:SetWidth(MinUI.frames["player.target"]["comboPointsBoxText"]:GetFullWidth()+ MinUIConfig.unitFrameOffset)
						MinUI.frames["player.target"]["comboPointsBox"]:SetHeight(MinUI.frames["player.target"]["comboPointsBoxText"]:GetFullHeight()+ MinUIConfig.unitFrameOffset)
					else
						MinUI.frames["player.target"]["comboPointsBar"]:SetWidth(MinUIConfig.unitFrameBarWidth * comboPointRatio)
						MinUI.frames["player.target"]["comboPointsBar"]:SetHeight(MinUIConfig.comboPointsBarHeight)
						MinUI.frames["player.target"]["comboPointsBar"]:SetBackgroundColor(1.0, 0.75, 0.14, 1.0)
						MinUI.frames["player.target"]["comboPointsBar"]:SetPoint("TOPLEFT", MinUI.frames["player.target"]["powerBar"], "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
					end
				end
			end
		elseif (MinUI.playerCalling == "warrior") then
			if(MinUI.frames[unitName]["warriorComboPointsBar"]) then
				if (warriorComboPoints) then
					debugPrint("combo points",warriorComboPoints ) 
					local comboPointRatio = warriorComboPoints / 3
					MinUI.frames["player"]["warriorComboPointsBar"]:SetWidth(MinUIConfig.unitFrameBarWidth * comboPointRatio)
					MinUI.frames["player"]["warriorComboPointsBar"]:SetHeight(MinUIConfig.comboPointsBarHeight)
					MinUI.frames["player"]["warriorComboPointsBar"]:SetBackgroundColor(1.0, 0.35, 0.14, 1.0)
					MinUI.frames["player"]["warriorComboPointsBar"]:SetPoint("TOPLEFT", MinUI.frames["player"]["powerBar"], "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
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
		
					MinUI.frames["player"]["mageChargeBar"]:SetWidth(MinUIConfig.unitFrameBarWidth * mageChargeRatio)
					MinUI.frames["player"]["mageChargeBar"]:SetHeight(MinUIConfig.mageChargeBarHeight)
					MinUI.frames["player"]["mageChargeBar"]:SetBackgroundColor(0.0, 0.5, 0.5, 1.0)
					MinUI.frames["player"]["mageChargeBar"]:SetPoint("TOPLEFT", MinUI.frames["player"]["powerBar"], "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
				end
			end
		end

		-- Health Bar Colours
		if(MinUIConfig.showHealthBar[unitName]) then
			if healthPercent >= 50 then
				MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
			elseif healthPercent < 50 and healthPercent >= 25 then
				MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.3, 0.3, 0.0, 1.0)
			elseif healthPercent < 25 then
				MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
			end
		end
		
		-- Power Bar Colours
		if(MinUIConfig.showPowerBar[unitName]) then
			if unitCalling == "rogue" then
				MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.3, 0.0, 0.3, 1.0)
			elseif unitCalling == "mage" or unitCalling == "cleric" then
				MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.3, 1.0)
			elseif unitCalling == "warrior" then
				MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
			else
				MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
			end
		end
		
		showUnitFrame(unitName)
	-- else we have nothing about that frame (deselected or server isn't giving us info)
	else
		debugPrint("no unitDetails for ", unitName, " so hiding for now")
		hideUnitFrame(unitName)
		resetBuffBars(unitName)
		
		if(MinUIConfig.showHealthBar[unitName]) then
			MinUI.frames[unitName]["healthText"]:SetText("")
			MinUI.frames[unitName]["healthTextShadow"]:SetText("")
			MinUI.frames[unitName]["healthBar"]:SetWidth(MinUIConfig.unitFrameBarWidth)
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		
		if(MinUIConfig.showPowerBar[unitName]) then
			MinUI.frames[unitName]["powerText"]:SetText("")
			MinUI.frames[unitName]["powerTextShadow"]:SetText("")
			MinUI.frames[unitName]["powerBar"]:SetWidth(MinUIConfig.unitFrameBarWidth)
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		
		if(MinUIConfig.showUnitText[unitName]) then
			MinUI.frames[unitName]["unitText"]:SetText("")
			MinUI.frames[unitName]["unitTextShadow"]:SetText("")
		end

		if(MinUI.frames[unitName]["comboPointsBar"]) then
			MinUI.frames[unitName]["comboPointsBar"]:SetWidth(MinUIConfig.unitFrameBarWidth)
			MinUI.frames[unitName]["comboPointsBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		
		if(MinUI.frames[unitName]["warriorComboPointsBar"]) then
			MinUI.frames[unitName]["warriorComboPointsBar"]:SetWidth(MinUIConfig.unitFrameBarWidth)
			MinUI.frames[unitName]["warriorComboPointsBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
		
		
	end
end


-- updateUnitFrame the given unitName
local function updateUnitFrame(unitName)
	-- get unitDetails
	local unitDetails = Inspect.Unit.Detail(unitName)
	setFrameDetails(unitName, unitDetails)
end

-- enable me to click on the player / party members to target
local function setUnitFrameTarget(unitName, targetUnitName)
	local unitDetails = Inspect.Unit.Detail(targetUnitName)
	setFrameDetails(unitName, unitDetails)
end


-- create unit frame for "unitName"
local function createUnitFrame(unitName)
	debugPrint("creating frame ... ", unitName)
	
	-- dont create frame twice
	if ( MinUI.frames[unitName] ) then
		debugPrint("unit frame already exists, not creating")
		return
	end
	
	-- use this for class colour text and other items eventually
	local unitDetails = Inspect.Unit.Detail(unitName)
	local unitCalling 
	if unitDetails then
		unitCalling = unitDetails.calling
	else
		unitCalling = "no_calling"
	end
	
	--  Main Unit Frame
	local unitFrame = UI.CreateFrame("Frame", "unitFrame", MinUI.context)
	unitFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0.0, 0.0)
	unitFrame:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
	local unitFrameWidth = MinUIConfig.unitFrameBarWidth + (MinUIConfig.unitFrameOffset*2)	
	local unitFrameHeight = 0
	
	-- Health Bar
	local healthBar = nil
	local healthText = nil
	local healthTextShadow = nil
	

	if ( MinUIConfig.showHealthBar[unitName] ) then
		healthBar = UI.CreateFrame("Frame", "healthBar", unitFrame)
		healthText = UI.CreateFrame("Text", "healthText", healthBar)
		healthTextShadow = UI.CreateFrame("Text", "healthText", healthBar)
		
		healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", MinUIConfig.unitFrameOffset, MinUIConfig.unitFrameOffset)
		healthBar:SetVisible(true)
		healthBar:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
		healthBar:SetLayer(-1)
		healthBar:SetWidth(MinUIConfig.unitFrameBarWidth)
		healthBar:SetHeight(MinUIConfig.unitFrameBarHeight)

		healthText:SetFontSize(14)
		healthText:SetPoint("CENTERLEFT", healthBar, "CENTERLEFT", 0, 0)
		healthText:SetLayer(2)
		healthText:SetWidth(MinUIConfig.unitFrameBarWidth)
		healthText:SetHeight(MinUIConfig.unitFrameBarHeight)
		healthTextShadow:SetFontSize(14)
		healthTextShadow:SetPoint("CENTERLEFT", healthBar, "CENTERLEFT", 1, 1)
		healthTextShadow:SetLayer(1)
		healthTextShadow:SetFontColor(0, 0, 0, 1)
		healthTextShadow:SetWidth(MinUIConfig.unitFrameBarWidth)
		healthTextShadow:SetHeight(MinUIConfig.unitFrameBarHeight)
		
		unitFrameHeight = unitFrameHeight + MinUIConfig.unitFrameBarHeight + MinUIConfig.unitFrameOffset
	end
	
	-- Power Bar
	local powerBar = nil
	local powerText = nil
	local powerTextShadow = nil
	if ( MinUIConfig.showPowerBar[unitName] ) then
		powerBar = UI.CreateFrame("Frame", "powerBar", healthBar)
		powerText = UI.CreateFrame("Text", "powerText", powerBar)
		powerTextShadow = UI.CreateFrame("Text", "powerTextShadow", powerBar)
		
		powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
		powerBar:SetVisible(true)
		powerBar:SetLayer(2)
		powerBar:SetWidth(MinUIConfig.unitFrameBarWidth)
		powerBar:SetHeight(MinUIConfig.unitFrameBarHeight)
		powerBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		
		powerText:SetFontSize(14)
		powerText:SetPoint("CENTERLEFT", powerBar, "CENTERLEFT", 0, 0)
		powerText:SetLayer(4)
		powerText:SetWidth(MinUIConfig.unitFrameBarWidth)
		powerText:SetHeight(MinUIConfig.unitFrameBarHeight)
		powerTextShadow:SetFontSize(14)
		powerTextShadow:SetPoint("CENTERLEFT", powerBar, "CENTERLEFT", 1, 1)
		powerTextShadow:SetLayer(3)
		powerTextShadow:SetFontColor(0, 0, 0, 1)
		powerTextShadow:SetWidth(MinUIConfig.unitFrameBarWidth)
		powerTextShadow:SetHeight(MinUIConfig.unitFrameBarHeight)
		
		unitFrameHeight = unitFrameHeight + MinUIConfig.unitFrameBarHeight + MinUIConfig.unitFrameOffset
	end
	
	-- Unit Text
	local unitText = nil
	local unitTextShadow = nil
	if ( MinUIConfig.showUnitText[unitName] ) then
		unitText = UI.CreateFrame("Text", "unitText", unitFrame)
		unitTextShadow = UI.CreateFrame("Text", "unitTextShadow", unitFrame)
		
		unitText:SetFontSize(14)
		unitText:SetLayer(2)
		unitTextShadow:SetFontSize(14)
		unitTextShadow:SetLayer(1)
		unitTextShadow:SetFontColor(0, 0, 0, 1)
		
		unitText:SetText("???")
		unitTextShadow:SetText("???")
		
		unitText:SetHeight( unitText:GetFullHeight() )
		unitTextShadow:SetHeight( unitText:GetFullHeight() )
		unitText:SetWidth( unitText:GetFullWidth() )
		unitTextShadow:SetWidth( unitText:GetFullWidth() )
		unitText:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", MinUIConfig.unitFrameOffset, -MinUIConfig.unitFrameOffset)
		unitTextShadow:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", MinUIConfig.unitFrameOffset+1, -MinUIConfig.unitFrameOffset+1)
		
		unitFrameHeight = unitFrameHeight + unitText:GetFullHeight() 
	end
	
	-- Calling specific components
	local comboPointsBar = nil
	local comboPointsBox = nil
	local comboPointBoxText = nil
	local warriorComboPointsBar = nil
	local mageChargeBar = nil
	local mageChargeText = nil
	
	--
	-- Class specific stuff
	--
	
	-- Attach combo points to underneath target's powerbar if player is rogue and we are creating the target frame
	if (MinUI.playerCalling == "rogue" and unitName == "player.target") then
		if (MinUIConfig.showComboBox) then
			comboPointsBox = UI.CreateFrame("Frame", "comboPointsBox", unitFrame)
			comboPointsBox:SetPoint("CENTER", UIParent, "CENTER",0 , 0)
			comboPointsBox:SetLayer(-1)
			comboPointsBox:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
			
			comboPointsBoxText = UI.CreateFrame("Text", "comboPointsBox", comboPointsBox)
			comboPointsBoxText:SetLayer(1)
			comboPointsBoxText:SetFontSize(36)
			comboPointsBoxText:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
			comboPointsBoxText:SetPoint("CENTER", comboPointsBox, "CENTER", 0, 0)
			comboPointsBoxText:SetText("?")
			
			comboPointsBoxText:SetWidth(comboPointsBoxText:GetFullWidth() + MinUIConfig.unitFrameOffset )
			comboPointsBoxText:SetHeight(comboPointsBoxText:GetFullHeight()+ MinUIConfig.unitFrameOffset)
			comboPointsBox:SetWidth(comboPointsBoxText:GetFullWidth()+ MinUIConfig.unitFrameOffset)
			comboPointsBox:SetHeight(comboPointsBoxText:GetFullHeight()+ MinUIConfig.unitFrameOffset)
		else
			comboPointsBar = UI.CreateFrame("Frame", "comboPointsBar", powerBar)
			comboPointsBar:SetLayer(-1)
			comboPointsBar:SetWidth(MinUIConfig.unitFrameBarWidth)
			comboPointsBar:SetBackgroundColor(1.0, 0.0, 0.0, 0.0)
			comboPointsBar:SetHeight(MinUIConfig.comboPointsBarHeight)
			comboPointsBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
			
			unitFrameHeight = unitFrameHeight + MinUIConfig.comboPointsBarHeight + MinUIConfig.unitFrameOffset
		end
	-- Attach warrior combo points to underneath players powerbar since they are persistent
	elseif (MinUI.playerCalling == "warrior" and unitName == "player") then
		warriorComboPointsBar = UI.CreateFrame("Frame", "warriorComboPointsBar", powerBar)
		warriorComboPointsBar:SetLayer(-1)
		warriorComboPointsBar:SetWidth(MinUIConfig.unitFrameBarWidth)
		warriorComboPointsBar:SetBackgroundColor(0.0, 0.0, 0.0, 1.0)
		warriorComboPointsBar:SetHeight(MinUIConfig.comboPointsBarHeight)
		warriorComboPointsBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
		unitFrameHeight = unitFrameHeight + MinUIConfig.comboPointsBarHeight + MinUIConfig.unitFrameOffset
	-- Attach mage Charge combo points to underneath players powerbar since they are persistent
	elseif (MinUI.playerCalling == "mage" and unitName == "player") then
		mageChargeBar = UI.CreateFrame("Frame", "mageChargeBar", powerBar)
		mageChargeBar:SetLayer(-1)
		mageChargeBar:SetWidth(MinUIConfig.unitFrameBarWidth)
		mageChargeBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		mageChargeBar:SetHeight(MinUIConfig.mageChargeBarHeight)
		mageChargeBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, MinUIConfig.unitFrameOffset)
		
		mageChargeText = UI.CreateFrame("Text", "mageChargeText", mageChargeBar)
		mageChargeText:SetFontSize(12)
		mageChargeText:SetLayer(2)
		mageChargeText:SetPoint("CENTERLEFT", mageChargeBar, "CENTERLEFT", 0, 0)
		mageChargeText:SetWidth(mageChargeText:GetFullWidth())
		mageChargeText:SetHeight(mageChargeText:GetFullWidth())
		
		unitFrameHeight = unitFrameHeight + MinUIConfig.mageChargeBarHeight + MinUIConfig.unitFrameOffset
	end
	
	unitFrameHeight = unitFrameHeight + MinUIConfig.unitFrameOffset
	unitFrame:SetHeight(unitFrameHeight)
	unitFrame:SetWidth(unitFrameWidth)

	
	--Gumaden's Movement Code
    function unitFrame.Event:LeftDown()
		debugPrint("frame clicked", unitName)
		-- XXX can't actually "set" the current target from what I can gather
		--if(unitName == "player") then
		--	print("clicky")
		--	setUnitFrameTarget("player.target", "player")
		--	setUnitFrameTarget("player.target.target", "player")
		--end
				
		if(MinUIConfig.unitFramesLocked == false) then
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
						
			-- store frame placement in saved var
			MinUIFramePlacement[unitName].x = unitFrame:GetLeft()
			MinUIFramePlacement[unitName].y = unitFrame:GetTop()
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
	MinUI.frames[unitName]["comboPointsBox"] = comboPointsBox
	MinUI.frames[unitName]["comboPointsBoxText"] = comboPointsBoxText
	MinUI.frames[unitName]["warriorComboPointsBar"] = warriorComboPointsBar
	MinUI.frames[unitName]["mageChargeBar"] = mageChargeBar
	MinUI.frames[unitName]["mageChargeText"] = mageChargeText
	MinUI.frames[unitName]["activeBuffBars"] = {}
	MinUI.frames[unitName]["zombieBuffBars"] = {}
	MinUI.frames[unitName]["MinUI.playerCalling"] = MinUI.playerCalling -- used to handle when rift doesnt give us the info we need straight away
	MinUI.frames[unitName]["lastAttach"] = nil
end


--
-- Causes all of the current unit frames to update
--
local function updateUnitFrames()
	for key, value in pairs(MinUI.frames) do
		debugPrint("updating ",key)
		updateUnitFrame(key)
	end
end

--
-- Add a single buff bar to given unit frame
--
local function addBuffBar(unitName, buff, time)

	-- attempt to reuse an old bar
	local bar = table.remove(MinUI.frames[unitName]["zombieBuffBars"])
	
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

-- 
-- Cycle accross buffs that belong to the given unit frame (and display them if enabled)
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
		
		-- debug
		debugPrint("buff configuration for ", unitName)
		debugPrint("show player cast buffs only?", MinUIConfig.showPlayerBuffsOnly[unitName])
		debugPrint("show all buffs", MinUIConfig.showAllBuffs[unitName])
		debugPrint("show player cast DEbuffs only?", MinUIConfig.showPlayerDebuffsOnly[unitName])
		debugPrint("show all DEbuffs?", MinUIConfig.showAllDebuffs[unitName])
		
		-- Now that we have the ordering, we just add the bars one at a time. Done!
		for k, buff in ipairs(bbars) do
			-- if the buff is a debuff...
			if ( buff.debuff ) then
				-- if the frame is configured to show only player cast debuffs
				if(MinUIConfig.showPlayerDebuffsOnly[unitName] == true) then
					if (buff.caster == Inspect.Unit.Lookup("player")) then
						addBuffBar(unitName, buff, time)
					end
				-- if the frame is configured to show all debuffs
				elseif(MinUIConfig.showAllDebuffs[unitName] == true) then
					addBuffBar(unitName, buff, time)
				end
			-- the buff is a buff :P
			else
				-- if the frame is configured to show only player cast buffs
				if(MinUIConfig.showPlayerBuffsOnly[unitName] == true) then
					if (buff.caster == Inspect.Unit.Lookup("player")) then
						addBuffBar(unitName, buff, time)
					end
				-- if the frame is configured to show all buffs
				elseif(MinUIConfig.showAllBuffs[unitName] == true) then
					addBuffBar(unitName, buff, time)
				end
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

-- inspect for player details
local function getPlayerDetails()
	-- based on player class some things are different
	local playerDetails = Inspect.Unit.Detail("player")
	if (playerDetails) then
		MinUI.playerCalling = playerDetails.calling
	end
	
	-- did we get it yet?
	if (MinUI.playerCalling == "unknown") then
		MinUI.playerDetailsKnown = false
	else
		MinUI.playerDetailsKnown = true
	end
	
	debugPrint ("player calling is... ", MinUI.playerCalling)
end


--
-- Restore Layout Settings from Config Saved Vars
--
function loadSavedFrameLocations()
	setUnitFrameLocation("player", MinUIFramePlacement["player"].x, MinUIFramePlacement["player"].y)
	setUnitFrameLocation("player.pet", MinUIFramePlacement["player.pet"].x, MinUIFramePlacement["player.pet"].y)
	setUnitFrameLocation("player.target", MinUIFramePlacement["player.target"].x, MinUIFramePlacement["player.target"].y)
	setUnitFrameLocation("player.target.target", MinUIFramePlacement["player.target.target"].x, MinUIFramePlacement["player.target.target"].y)
end

--
-- Initialise Enabled Frames
--
local function initialiseFrames()
	debugPrint("initialising frames")
	
	createUnitFrame("player")
	createUnitFrame("player.pet")
	createUnitFrame("player.target")
	createUnitFrame("player.target.target")
	
	-- load saved settings
	loadSavedFrameLocations()
	
	-- updates the unit frame details
	updateUnitFrames()
end

--
-- Main Event Update Loop
--
local function updateLoop()
	-- Poll for player calling until we get one
	if (MinUI.playerDetailsKnown == false) then
		getPlayerDetails()
	else
		-- Once we get the player's calling initialise the frames
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
		-- Just do a Tick on the bar
		local time = Inspect.Time.Frame()
			for unitName, value in pairs(MinUI.frames) do
				for _, bar in ipairs(MinUI.frames[unitName]["activeBuffBars"]) do
					bar:Tick(time)
				end
			end
		end
	end
end

--
-- Target Changed Event Handler
--
local function targetChanged()
	debugPrint("target changed")
	updateUnitFrames()
	MinUI.resyncBuffs = true
end

--
-- Addon Loaded
--
local function addonLoaded(addon)
	if(addon == "MinUI") then
		print("MinUI 0.0.6 - development")
		print("UnitFrames loaded, type /mui for help")
	end
end

--
-- Configuration Interface
--
local function muiCommandInterface(commandline)
	local tokenCount = 0
	local command = nil
	
	-- iterate tokens in command line
	for token in string.gmatch(commandline, "[^%s]+") do
		tokenCount = tokenCount + 1
		
		-- handle commands (should always be first token)
		if(tokenCount == 1) then
			-- lock frames
			if(token == "lock") then
				lockFrames()
			-- unlock frames
			elseif(token == "unlock") then
				unlockFrames()
			-- reset all settings to defaults
			elseif(token == "resetall") then
				resetAll()
			-- print frame current settings
			elseif(token == "print") then
				command = token
			-- unknown command
			else
				printHelpText()
			end
		end
		
		-- handle frame name (second token) given to the command
		if (command) then
			if(tokenCount == 2) then
				if (command == "print") then
					showCurrentSettings(token)
				end
			end
		end
	end
	
	if (tokenCount == 0) then
		printHelpText()
	end
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
	
	-- Say hello 
	table.insert(Event.Addon.Load.End, {addonLoaded, "MinUI", "addonLoaded"})

	-- Handle User Customisation
	table.insert(Command.Slash.Register("mui"), {muiCommandInterface, "MinUI", "Slash command"})
	

	-- Our update event
	table.insert(Event.System.Update.Begin, {updateLoop, "MinUI", "refresh"})
end

startup()



