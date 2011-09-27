local function init()
	-- MinUI 
	MinUI = {}
	MinUI.context = UI.CreateContext("MinUIContext")

	-- Unit Frames
	MinUI.frames = {}

	-- Defaults
	MinUI.defaults = {}
	MinUI.defaults.barWidth = 250
	MinUI.defaults.barHeight = 30
	MinUI.defaults.offset = 2
	MinUI.defaults.unitFrameWidth = 254
	MinUI.defaults.unitFrameHeight = (MinUI.defaults.barHeight*2)+ (MinUI.defaults.offset*2)

end



-- update the given unitName
local function update(unitName)
	-- get details
	local details = Inspect.Unit.Detail(unitName)
	
	-- if we have anything
	if details then
		local calling = details.calling
		local health = details.health
		local healthMax = details.healthMax
		local healthRatio = health/healthMax
		local healthPercent = math.floor(healthRatio * 100)
		
		-- init power vars
		local power = 0
		local powerMax = 0
		local powerRatio = 1
		local powerPercent = 0
		
		-- update based on class
		if calling == "rogue" then
			power = details.energy
			powerMax = 100
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif calling == "mage" or calling == "cleric" then
			power = details.mana
			powerMax = details.manaMax
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		elseif calling == "warrior" then
			power = details.power
			powerMax = 100
			powerRatio = power/powerMax
			powerPercent = math.floor(powerRatio * 100)
		end
		
		local name = details.name
		
		-- update texts
		MinUI.frames[unitName]["healthText"]:SetText(string.format("%s/%s (%s%%)", health, healthMax, healthPercent))
		MinUI.frames[unitName]["powerText"]:SetText(string.format("%s/%s (%s%%)", power, powerMax, powerPercent))
		MinUI.frames[unitName]["nameText"]:SetText(name)
		MinUI.frames[unitName]["healthBar"]:SetWidth(MinUI.defaults.barWidth * healthRatio)
		MinUI.frames[unitName]["powerBar"]:SetWidth(MinUI.defaults.barWidth * powerRatio)
		
		MinUI.frames[unitName]["unitFrame"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
		
		-- health color
		if healthPercent >= 50 then
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
		elseif healthPercent < 50 and healthPercent >= 25 then
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.3, 0.3, 0.0, 1.0)
		elseif healthPercent < 25 then
			MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
		end
		
		-- colour based on class
		if calling == "rogue" then
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.3, 0.0, 0.3, 1.0)
		elseif calling == "mage" or calling == "cleric" then
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.3, 1.0)
		elseif calling == "warrior" then
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
		else
			MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end
	else
		MinUI.frames[unitName]["unitFrame"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		MinUI.frames[unitName]["healthText"]:SetText("")
		MinUI.frames[unitName]["powerText"]:SetText("")
		MinUI.frames[unitName]["nameText"]:SetText("")
		MinUI.frames[unitName]["healthBar"]:SetWidth(MinUI.defaults.barWidth)
		MinUI.frames[unitName]["powerBar"]:SetWidth(MinUI.defaults.barWidth)
		MinUI.frames[unitName]["powerBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		MinUI.frames[unitName]["healthBar"]:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	end
	
end

local function makeFrameVisible(unitName)
	MinUI.frames[unitName]["unitFrame"]:SetVisible(true)
end

-- relocate a frame
local function moveUnitFrame(unitName, x, y)
	MinUI.frames[unitName]["unitFrame"]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x,y )
end


-- create unit frame for "unitName"
local function createUnitFrame(unitName)
	print("creating frame ... ", unitName)
	
	-- get for setting up combo points/etc when required details
	local details = Inspect.Unit.Detail(unitName)
	local calling 
	if details then
		calling = details.calling
	else
		calling = "no_target"
	end
	
	local unitFrame = UI.CreateFrame("Frame", "unitFrame", MinUI.context)
	local healthBar = UI.CreateFrame("Frame", "healthBar", unitFrame)
	local healthText = UI.CreateFrame("Text", "healthText", healthBar)
	local powerBar = UI.CreateFrame("Frame", "powerBar", unitFrame)
	local powerText = UI.CreateFrame("Text", "powerTExt", powerBar)
	local nameText = UI.CreateFrame("Text", "nameText", unitFrame)
	
	-- center new frame
	unitFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0.0, 0.0)
	unitFrame:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
	
	-- bar for health
	healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", MinUI.defaults.offset, MinUI.defaults.offset)
	healthBar:SetVisible(true)
	healthBar:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
	healthBar:SetLayer(-1)
	healthBar:SetWidth(MinUI.defaults.barWidth)
	healthBar:SetHeight(MinUI.defaults.barHeight)
	
	healthText:SetFontSize(14)
	healthText:SetPoint("CENTERLEFT", healthBar, "CENTERLEFT", 0, 0)
	healthText:SetLayer(1)
	healthText:SetWidth(MinUI.defaults.barWidth)
	healthText:SetHeight(MinUI.defaults.barHeight)
	
	-- bar for power
	powerBar:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", MinUI.defaults.offset, -MinUI.defaults.offset)
	powerBar:SetVisible(true)
	
	-- colour based on class
	if calling == "rogue" then
		powerBar:SetBackgroundColor(0.3, 0.0, 0.3, 1.0)
	elseif calling == "mage" or calling == "cleric" then
		powerBar:SetBackgroundColor(0.0, 0.0, 0.3, 1.0)
	elseif calling == "warrior" then
		powerBar:SetBackgroundColor(0.3, 0.0, 0.0, 1.0)
	else
		powerBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	end
		
	powerBar:SetLayer(-1)
	powerBar:SetWidth(MinUI.defaults.barWidth)
	powerBar:SetHeight(MinUI.defaults.barHeight)
	
	powerText:SetFontSize(14)
	powerText:SetPoint("CENTERLEFT", powerBar, "CENTERLEFT", 0, 0)
	powerText:SetLayer(1)
	powerText:SetWidth(MinUI.defaults.barWidth)
	powerText:SetHeight(MinUI.defaults.barHeight)
	
	
	-- bar for name	
	nameText:SetFontSize(14)
	nameText:SetPoint("TOPCENTER", unitFrame, "TOPCENTER", 0, -20)
	nameText:SetLayer(1)
	nameText:SetWidth(MinUI.defaults.barWidth)
	nameText:SetHeight(MinUI.defaults.barHeight)
	
	unitFrame:SetHeight(MinUI.defaults.unitFrameHeight)
	unitFrame:SetWidth(MinUI.defaults.unitFrameWidth)
	
	-- store the frame
	MinUI.frames[unitName] = {}
	MinUI.frames[unitName]["unitFrame"] = unitFrame
	MinUI.frames[unitName]["healthBar"] = healthBar
	MinUI.frames[unitName]["healthText"] = healthText
	MinUI.frames[unitName]["powerBar"] = powerBar
	MinUI.frames[unitName]["powerText"] = powerText
	MinUI.frames[unitName]["nameText"] = nameText
	
	-- update frame
	update(unitName)
	makeFrameVisible(unitName)
end


local function updateTarget()
	update("player.target")
end

-- on health update event
local function updateUnitHealth()
	--print("health update")
	update("player")
	update("player.target")
end

local function updateUnitEnergy()
	--print("energy update")
	update("player")
	update("player.target")
end

local function updateUnitMana()
	--print("mana update")
	update("player")
	update("player.target")
end



-----------------------------------------------------------------------------------------------------------------------------
--
-- Event Hooks
--
-----------------------------------------------------------------------------------------------------------------------------

table.insert(Event.Unit.Detail.Health, {updateUnitHealth, "MinUI", "updateUnitHealth"})
table.insert(Event.Unit.Detail.Mana, {updateUnitMana, "MinUI", "updateUnitMana"})
table.insert(Event.Unit.Detail.Energy, {updateUnitEnergy, "MinUI", "updateUnitEnergy"})
table.insert(Event.Ability.Target, {updateTarget, "MinUI", "updateUnitEnergy"})

-----------------------------------------------------------------------------------------------------------------------------
--
-- Helpers
--
-----------------------------------------------------------------------------------------------------------------------------

if not strsplit then strsplit = function  (s, delimiter)  
  assert (type (delimiter) == "string" and string.len (delimiter) > 0,
          "bad delimiter")  
  local start = 1
  local t = {}  
  while true do
    local pos = string.find (s, delimiter, start, true) 
    if not pos then
      break
    end       
    table.insert (t, string.sub (s, start, pos - 1))
    start = pos + string.len (delimiter)
  end 
  table.insert (t, string.sub (s, start))     
  return t
end -- function split
end

-----------------------------------------------------------------------------------------------------------------------------
--
-- Console Commands
--
-----------------------------------------------------------------------------------------------------------------------------

-- Create a frame
local function muiCreate(input)
	createUnitFrame(input)
end

-- Move a frame
local function muiMove(input)
	local args = strsplit(input, " ")
	print("args",args[1],args[2],args[3])
	moveUnitFrame(args[1],tonumber(args[2]),tonumber(args[3]))
end

-- add slash commands
table.insert(Command.Slash.Register("muicreate"), {muiCreate, "MinUI", "muiCreate"})
table.insert(Command.Slash.Register("muimove"), {muiMove, "MinUI", "muiMove"})

-----------------------------------------------------------------------------------------------------------------------------
--
-- Init
--
-----------------------------------------------------------------------------------------------------------------------------
init();


