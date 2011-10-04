-----------------------------------------------------------------------------------------------------------------------------
--
-- A Bar Class
--
----------------------------------------------------------------------------------------------------------------------------- 
UnitBar = {}
UnitBar.__index = UnitBar

--
-- Create a Bar for a Unit Frame
--
-- name: bar name (i.e "healthBarPlayer")
-- width:
-- height:
-- texture:
-- fontSize:
-- anchorPoint:
-- parentItem:
-- offsetX:
-- offsetY:
--
function UnitBar.new( name, width, height, texture, fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )
	local uBar = {}             		-- our new object
	setmetatable(uBar, UnitBar)      	-- make UnitBar handle lookup
	
	-- store values for the bar
	uBar.width = width
	uBar.height = height
	uBar.fontSize = fontSize
	uBar.anchorThis = anchorThis
	uBar.anchorParent = anchorParent
	uBar.parentItem = parentItem
	uBar.offsetX = offsetX
	uBar.offsetY = offsetY
	uBar.texture = texture
	uBar.enabled = false
	
	-- create the bar
	uBar.bar = UI.CreateFrame("Texture", name, parentItem)
	uBar.bar:SetTexture("MinUI",texture .. ".tga")
	uBar.bar:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBar.bar:SetWidth(uBar.width)
	uBar.bar:SetHeight(uBar.height)
	uBar.bar:SetLayer(1)
	uBar.bar:SetVisible(uBar.enabled)
	uBar.bar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	
	-- create the text
	uBar.text = UI.CreateFrame("Text", name .. "_text", uBar.bar )
	uBar.text:SetPoint( "CENTERLEFT", uBar.bar, "CENTERLEFT", offsetX, 0 )
	uBar.text:SetWidth(uBar.width)
	uBar.text:SetHeight(uBar.height)
	uBar.text:SetLayer(2)
	uBar.text:SetVisible(true)
	uBar.text:SetFontSize(fontSize)
	
	return uBar
end

--
-- Set the Unit Bar's Texture
--
function UnitBar:setUBarTexture( texture )
	self.texture = texture
	self.bar:SetTexture("MinUI",texture .. ".tga")
	self.bar:SetLayer(1)
end

--
-- Is the bar enabled?
--
function UnitBar:isUBarEnabled()
	return self.enabled
end

--
-- Enable/Disable the bar
--
function UnitBar:setUBarEnabled( toggle )
	self.enabled = toggle
	self.bar:SetVisible(toggle)
end

--
--
--
function UnitBar:getUBarOffsetY()
	return self.offsetY
end

--
-- set text
--
function UnitBar:setUBarText(text)
	--print "setting ubartext"
	self.text:SetText(text)
	self.text:SetWidth(self.width)
	self.text:SetHeight(self.height)
	self.text:SetPoint( "CENTERLEFT", self.bar, "CENTERLEFT", self.offsetX, 0 )
	self.text:SetLayer(2)
	self.text:SetVisible(true)
	
end

--
-- set height
--
function UnitBar:setUBarHeight(height)
	self.height = height
	self.bar:SetHeight(self.height)
end

--
-- get height
--
function UnitBar:getUBarHeight()
	return self.height
end

--
-- set width
--
function UnitBar:setUBarWidth(width)
	self.width = width
	self.bar:SetWidth(self.width)
end

--
-- get width
--
function UnitBar:getUBarWidth()
	return self.width
end

--
-- Toggle Bar Visibility
--
function UnitBar:setUBarVisible(toggle)
	self.enabled = toggle
	self.bar:SetVisible(self.enabled)
end

--
-- grow/shrink the bar based on width given the percentage of "thing" this bar is watching
--
function UnitBar:setUBarWidthRatio( ratio )
	self.bar:SetWidth(self.width * ratio)
end
