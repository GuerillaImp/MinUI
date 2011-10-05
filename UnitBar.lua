-----------------------------------------------------------------------------------------------------------------------------
--
-- A UnitBar Class
--
-- This basic unit bar has a solid bar, width, and text items.
--
-- Other items such as UnitComboBar and UnitText "kinda" implement this as an interface by providing:
-- function XXX:isUBarEnabled()
-- function XXX:setUBarEnabled( toggle )
-- function XXX:getUBarHeight()
-- function XXX:getUBarOffsetY()  
--
-- These functions enable the UnitFrame to transparently add them as "bars" and resize accordingly
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
-- texture: disabled for now
-- fontSize:
-- anchorPoint:
-- parentItem:
-- offsetX:
-- offsetY:
--
function UnitBar.new( name, width, height,fontSize, anchorThis, anchorParent, parentItem, offsetX, offsetY  )
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
	uBar.enabled = false -- TODO phase this out kinda useless
	uBar.color = {}

	-- create the bar
	uBar.bar = UI.CreateFrame("Frame", name, parentItem)
	uBar.bar:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBar.bar:SetWidth(uBar.width)
	uBar.bar:SetHeight(uBar.height)
	uBar.bar:SetLayer(1)
	uBar.bar:SetVisible(uBar.enabled)
	uBar.bar:SetBackgroundColor(0.0, 0.0, 0.0, 0.5)
	
	-- create the text
	uBar.text = UI.CreateFrame("Text", name .. "_text", uBar.bar )
	uBar.text:SetPoint( "CENTERLEFT", uBar.bar, "CENTERLEFT", 0, 0 )
	uBar.text:SetWidth(uBar.width)
	uBar.text:SetHeight(uBar.height)
	uBar.text:SetLayer(3)
	uBar.text:SetVisible(true)
	uBar.text:SetFontSize(fontSize)
	
	-- text shadow
	uBar.textShadow = UI.CreateFrame("Text", name .. "_text", uBar.bar )
	uBar.textShadow:SetPoint( "CENTERLEFT", uBar.bar, "CENTERLEFT", 1, 2 )
	uBar.textShadow:SetWidth(uBar.width)
	uBar.textShadow:SetHeight(uBar.height)
	uBar.textShadow:SetLayer(2)
	uBar.textShadow:SetVisible(true)
	uBar.textShadow:SetFontSize(fontSize)
	uBar.textShadow:SetFontColor(0,0,0,1)
	

	
	return uBar
end

--
-- Set the Unit Bar's Texture
--[[
function UnitBar:setUBarTexture( texture )
	self.texture = texture
	self.bar:SetTexture("MinUI",texture .. ".tga")
	self.bar:SetLayer(1)
end]]

function UnitBar:setUBarColor( r,g,b,a )
	self.color = { r,g,b,a }
	self.bar:SetBackgroundColor(r,g,b,a)
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
	self.textShadow:SetText(text)
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
