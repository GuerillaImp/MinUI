-- MinUI 
MinUI = {}
MinUI.context = UI.CreateContext("MinUIContext")

-- Unit Frames
MinUI.frames = {}

MinUI.defaults = {}
MinUI.defaults.barWidth = 300


-- bugs:
-- 
-- for some reason the player frame is creted twice, on top of eachother...
-- one will update, the other seems to be lost forever :/
--
--
--
--

-- update the given unitName
local function update(unitName)
	-- get details
	local details = Inspect.Unit.Detail(unitName)
	
	print("updating ... ", unitName)
	
	if details then
		local health = details.health
		local healthMax = details.healthMax
		local name = details.name
		local healthRatio = health/healthMax
		local healthPercent = math.floor(healthRatio * 100)
		
		-- update texts
		MinUI.frames[unitName]["unitFrame"]:SetVisible(true)
		MinUI.frames[unitName]["healthText"]:SetText(string.format("%s/%s (%s%%)", health, healthMax, healthPercent))
		MinUI.frames[unitName]["nameText"]:SetText(name)
		MinUI.frames[unitName]["healthBar"]:SetWidth(MinUI.defaults.barWidth * healthRatio)
	else
		print("no details for that unit")
		MinUI.frames[unitName]["unitFrame"]:SetVisible(false)

	end
end

-- create unit frame for "unitName"
local function createUnitFrame(unitName)
	print("creating frame ... ", unitName)

	local unitFrame = UI.CreateFrame("Frame", "unitFrame", MinUI.context)
	local healthBar = UI.CreateFrame("Frame", "healthBar", unitFrame)
	local healthText = UI.CreateFrame("Text", "healthText", healthBar)
	local nameBar = UI.CreateFrame("Frame", "nameBar", unitFrame)
	local nameText = UI.CreateFrame("Text", "nameText", nameBar)
	
	-- center new frame
	unitFrame:SetPoint("TOPCENTER", UIParent, 0.5, 0.5)
	unitFrame:SetVisible(false)
	unitFrame:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
	
	-- bar for health
	healthBar:SetPoint("BOTTOMCENTER", unitFrame, "BOTTOMCENTER", 0,0)
	healthBar:SetVisible(true)
	healthBar:SetBackgroundColor(0.0, 0.3, 0.0, 1.0)
	healthBar:SetLayer(-1)
	healthBar:SetWidth(MinUI.defaults.barWidth)
	healthBar:SetHeight(25)
	
	healthText:SetFontSize(14)
	healthText:SetPoint("CENTERLEFT", healthBar, "CENTERLEFT", 0, 0)
	healthText:SetLayer(1)
	healthText:SetWidth(MinUI.defaults.barWidth)
	healthText:SetHeight(25)
	
	-- bar for name
	nameBar:SetPoint("TOPCENTER", unitFrame, "TOPCENTER", 0,0)
	nameBar:SetVisible(true)
	nameBar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	nameBar:SetLayer(-1)
	nameBar:SetWidth(MinUI.defaults.barWidth)
	nameBar:SetHeight(25)
	
	nameText:SetFontSize(14)
	nameText:SetPoint("CENTERLEFT", nameBar, "CENTERLEFT", 0, 0)
	nameText:SetLayer(1)
	nameText:SetWidth(MinUI.defaults.barWidth)
	nameText:SetHeight(25)
	
	unitFrame:SetHeight(50)
	unitFrame:SetWidth(MinUI.defaults.barWidth)
	
	-- store the frame
	MinUI.frames[unitName] = {}
	MinUI.frames[unitName]["unitFrame"] = unitFrame
	MinUI.frames[unitName]["healthBar"] = healthBar
	MinUI.frames[unitName]["healthText"] = healthText
	MinUI.frames[unitName]["nameBar"] = nameBar
	MinUI.frames[unitName]["nameText"] = nameText
end

-- relocate a frame
local function moveUnitFrame(unitName, x, y)
	MinUI.frames[unitName]["unitFrame"]:SetPoint("TOPCENTER", UIParent, x,y )
end

-- setup the ui
local function setupUI()
	print("setup ui")
	
	createUnitFrame("player")
	createUnitFrame("player.target")
	
	moveUnitFrame("player", 0.3, 0.5)
	moveUnitFrame("player.target", 0.7, 0.5)
	
	update("player")
end

-- load user variables
local function loadVars()
	print("load user variables")

	-- setup UI
	setupUI()
end

-- load user variables
local function saveVars()
	print("save user variables")
end

-- on health update event
local function updateUnitHealthText()
	print("health update")
	update("player")
	update("player.target")
end

-- on change target/update target
local function updateTarget()
	print("target update")
	update("player.target")
end

-- handle slash
local function handleSlash(param)
	print("recieved = ", param)
end

-----------------------------------------------------------------------------------------------------------------------------
--
-- Event Hooks
--
-----------------------------------------------------------------------------------------------------------------------------

-- Handle loading/saving user variables
table.insert(Event.Addon.SavedVariables.Load.End, {loadVars, "MinUI", "Load saved variables"})
table.insert(Event.Addon.SavedVariables.Save.Begin, {saveVars, "MinUI", "Save saved variables"})

-- update on health events
table.insert(Event.Unit.Detail.Health, {updateUnitHealthText, "MinUI", "Update health values"})

-- target added/changed
table.insert(Event.Ability.Target, {updateTarget, "MinUI", "Update target values"})

-----------------------------------------------------------------------------------------------------------------------------
--
-- Slash Command Registers --
--
-----------------------------------------------------------------------------------------------------------------------------
table.insert(Command.Slash.Register("mui"), 
	{
		function (params)
			handle_slash_command(params)
		end, 
		"MinUI", 
		"Minimalist UI slash commands."
	}
)