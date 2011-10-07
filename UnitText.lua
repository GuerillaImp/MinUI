-----------------------------------------------------------------------------------------------------------------------------
--
-- UnitText Bar - supports name, calling, level, guild (at the moment)
--
-- "Extends" a UnitBar as it implements:
--
-- function XXX:isUBarEnabled()
-- function XXX:setUBarEnabled( toggle )
-- function XXX:getUBarHeight()
-- function XXX:getUBarOffsetY()
--
-- This means I can add it to a UnitFrame as a "frame" and it "just works"
--
----------------------------------------------------------------------------------------------------------------------------- 
UnitText = {}
UnitText.__index = UnitText

function UnitText.new( width, fontSize, unitName, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local utBar = {}             				-- our new object
	setmetatable(utBar, UnitText)      			-- make UnitText handle lookup
	
	utBar.anchorThis = anchorThis
	utBar.anchorParent = anchorParent
	utBar.parentItem = parentItem
	utBar.offsetX = offsetX
	utBar.offsetY = offsetY
	utBar.width = width
	utBar.unitName = unitName
	utBar.fontSize = fontSize
	utBar.enabled = true
	

	utBar.frame = UI.CreateFrame("Frame", "UnitTextBar", parentItem)
	
	-- calculate required height
	local tempFont = UI.CreateFrame("Text", "TempTextBar", utBar.frame)
	tempFont:SetFontSize(utBar.fontSize)
	tempFont:SetText("???")
	tempFont:SetVisible(false)
	utBar.height = tempFont:GetFullHeight()
	
	--print(utBar.height)
	
	utBar.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	utBar.frame:SetWidth(utBar.width)
	utBar.frame:SetHeight(utBar.height)
	utBar.frame:SetLayer(1)
	utBar.frame:SetVisible( utBar.enabled )
	--utBar.frame:SetBackgroundColor(0.0, 0.0, 1.0, 1.0)
	
	-- store the text items in this text frame
	utBar.texts = {}
	utBar.textsShadows = {}
	utBar.numTexts = 0
	
	return utBar
end

--
-- Set Background Color
--
function UnitText:setUBarColor( r,g,b,a )
	self.color = { r,g,b,a }
	self.frame:SetBackgroundColor(r,g,b,a)
end

--
-- Add a text item 
--
-- TODO: Sort these like unit bar's are when they are added (i.e. provide textItem, position)
--
function UnitText:addTextItem(textItem)
	self.texts[textItem] = UI.CreateFrame("Text", self.unitName .. "_" .. textItem .. "_text", self.frame)
	self.texts[textItem]:SetLayer(3)
	self.texts[textItem]:SetVisible( self.enabled )
	self.texts[textItem]:SetFontSize( self.fontSize )
	self.texts[textItem]:SetHeight( self.height )
	self.textsShadows[textItem] = UI.CreateFrame("Text", self.unitName .. "_" .. textItem .. "_textShadow", self.frame)
	self.textsShadows[textItem]:SetLayer(2)
	self.textsShadows[textItem]:SetVisible( self.enabled )
	self.textsShadows[textItem]:SetFontSize( self.fontSize )
	self.textsShadows[textItem]:SetFontColor( 0,0,0,1 )
	self.textsShadows[textItem]:SetHeight( self.height )
	
	-- Set Font
	if (MinUIConfig.globalTextFont) then
		self.texts[textItem]:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
		self.textsShadows[textItem]:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end
	
	
end

--
-- Update the text items within this UnitText frame
--
-- only supports name, level, calling and guild for now
--
function UnitText:updateTextItems()
	local details = Inspect.Unit.Detail(self.unitName)
	if (details) then
		local firstString = true
		local offset = 0
		local lastWidth = 0
		
		-- NOTE: Dont forget to add any new texts to this
		-- Update textsShadows
		for key,value in pairs(self.textsShadows) do
			if(key == "name") then
				if(details.name)then
					value:SetText(details.name)
				else
					value:SetText("")
				end
			elseif(key == "level")then
				if(details.level)then
					local level = "" .. details.level
					value:SetText(level)
				else
					value:SetText("")
				end
			elseif(key == "calling")then
				if(details.calling)then
					value:SetText(details.calling)
				else
					value:SetText("")
				end
			elseif(key == "guild")then
				if(details.guild)then
					local guild = "<" .. details.guild .. ">"
					value:SetText(guild)
				else
					value:SetText("")
				end
			elseif(key == "vitality")then
				if(details.vitality)then
					local vitality = "(" .. details.vitality .. "%)"
					value:SetText(vitality)
				else
					value:SetText("")
				end
			elseif(key == "planar" or key == "planarCharges") then -- added planarCharges for backwards compat with people's saved vars
				if(details.planar)then
					local planar = "<" .. details.planar .. ">"
					value:SetText(planar)
				else
					value:SetText("<0>")
				end
			end
			
			value:SetWidth(value:GetFullWidth())
			
			if(firstString) then
				offset = 0
				lastWidth = value:GetFullWidth()
				firstString = false
			else
				offset = offset + lastWidth + 5
				lastWidth = value:GetFullWidth()
			end
			
			value:SetPoint("CENTERLEFT", self.frame, "CENTERLEFT", offset+1, 2 )
			value:SetHeight(value:GetFullHeight())
		end
		
		-- Reset
		firstString = true
		offset = 0
		lastWidth = 0
		
		-- Update Texts
		for key,value in pairs(self.texts) do
			if(key == "name") then
				if(details.name)then
					value:SetText(details.name)
				else
					value:SetText("")
				end
			elseif(key == "level")then
				if(details.level)then
					local level = "" .. details.level
					value:SetText(level)
					if not (self.unitName == "player") then
						value:SetFontColor(difficultyColour(self.unitName))
					end
				else
					value:SetText("")
				end
			elseif(key == "calling")then
				if(details.calling)then
					value:SetText(details.calling)
				end
			elseif(key == "guild")then
				if(details.guild)then
					local guild = "<" .. details.guild .. ">"
					value:SetText(guild)
				else
					value:SetText("")
				end
			elseif(key == "vitality")then
				if(details.vitality)then
					local vitality = "(" .. details.vitality .. "%)"
					value:SetText(vitality)
				else
					value:SetText("")
				end
			elseif(key == "planar")then
				if(details.planar)then
					local planar = "<" .. details.planar .. ">"
					value:SetText(planar)
				else
					value:SetText("<0>")
				end
			end
			
			value:SetWidth(value:GetFullWidth())
			
			if(firstString) then
				offset = 0
				lastWidth = value:GetFullWidth()
				firstString = false
			else
				offset = offset + lastWidth + 5
				lastWidth = value:GetFullWidth()
			end
			
			--print(offset)
			value:SetPoint("CENTERLEFT", self.frame, "CENTERLEFT", offset, 0 )
			value:SetHeight(value:GetFullHeight())
		end
	else
		-- No details, set text to ""
		for key,value in pairs(self.textsShadows) do
			value:SetText("")
		end	
		for key,value in pairs(self.texts) do
			value:SetText("")
		end		
	end
end


--
-- Is the frame enabled?
--
function UnitText:isUBarEnabled()
	return self.enabled
end

--
-- Enable/Disable the frame
--
function UnitText:setUBarEnabled( toggle )
	self.enabled = toggle
	self.frame:SetVisible(toggle)
end

--
-- Get Bar Height
--
function UnitText:getUBarHeight()
	return self.height
end

--
-- Get OffsetY
--
function UnitText:getUBarOffsetY()
	return self.offsetY
end