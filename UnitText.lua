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

function UnitText.new( width, height, fontSize, unitName, anchorThis, anchorParent, parentItem, offsetX, offsetY )
	local utBar = {}             				-- our new object
	setmetatable(utBar, UnitText)      			-- make UnitText handle lookup
	
	utBar.anchorThis = anchorThis
	utBar.anchorParent = anchorParent
	utBar.parentItem = parentItem
	utBar.offsetX = offsetX
	utBar.offsetY = offsetY
	utBar.width = width
	utBar.height = height
	utBar.unitName = unitName
	utBar.fontSize = fontSize
	utBar.enabled = true
	
	utBar.frame = UI.CreateFrame("Frame", "UnitTextBar", parentItem)
	utBar.frame:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	utBar.frame:SetWidth(utBar.width)
	utBar.frame:SetHeight(utBar.height)
	utBar.frame:SetLayer(1)
	utBar.frame:SetVisible( utBar.enabled )
	utBar.frame:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	-- store the text items in this text frame
	utBar.texts = {}
	utBar.numTexts = 0
	
	return utBar
end

--
-- Add a text item 
--
-- TODO: Sort these like unit bar's are when they are added (i.e. provide textItem, position)
--
function UnitText:addTextItem(textItem)
	self.texts[textItem] = UI.CreateFrame("Text", self.unitName .. "_" .. textItem .. "_text", self.frame)
	self.texts[textItem]:SetLayer(2)
	self.texts[textItem]:SetVisible( self.enabled )
	self.texts[textItem]:SetFontSize( self.fontSize )
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
		for key,value in pairs(self.texts) do
			if(key == "name") then
				value:SetText(details.name)
			elseif(key == "level")then
				local level = "" .. details.level
				value:SetText(level)
				value:SetFontColor(difficultyColour(self.unitName))
			elseif(key == "calling")then
				if(details.calling)then
					value:SetText(details.calling)
				end
			elseif(key == "guild")then
				if(details.guild)then
					local guild = "<" .. details.guild .. ">"
					value:SetText(guild)
				end
			end
			
			value:SetWidth(value:GetFullWidth())
			
			if(firstString) then
				offset = 0
				firstString = false
			else
				offset = offset + value:GetFullWidth() + 5
				
			end
			
			value:SetPoint("CENTERLEFT", self.frame, "CENTERLEFT", offset, self.height/2 )
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