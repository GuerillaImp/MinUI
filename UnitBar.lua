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
	uBar.enabled = true
	
	uBar.curBarWidth = width

	-- Create Bar
	uBar.bar = UI.CreateFrame("Frame", name, parentItem)
	uBar.bar:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBar.bar:SetWidth(uBar.width)
	uBar.bar:SetLayer(1)
	uBar.bar:SetVisible(uBar.enabled)
	uBar.bar:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	uBar.bar:SetHeight(uBar.height)
	
	-- Create the bit that resizes
	uBar.solid = UI.CreateFrame("Frame", name.."_solid", parentItem)
	uBar.solid:SetPoint(anchorThis, parentItem, anchorParent, offsetX, offsetY )
	uBar.solid:SetWidth(uBar.width)
	uBar.solid:SetLayer(-1)
	uBar.solid:SetVisible(uBar.enabled)
	uBar.solid:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
	uBar.solid:SetHeight(uBar.height)
	 
	 
	-- create text 1
	uBar.leftText = UI.CreateFrame("Text", name .. "_text1", uBar.bar )
	uBar.leftText:SetPoint( "CENTERLEFT", uBar.bar, "CENTERLEFT", 0, 0 )
	uBar.leftText:SetLayer(3)
	uBar.leftText:SetVisible(true)
	uBar.leftText:SetFontSize(fontSize)
	uBar.leftText:SetText("???")
	uBar.leftText:SetWidth(uBar.leftText:GetFullWidth())
	uBar.leftText:SetHeight(uBar.leftText:GetFullHeight())
	-- Font: From Config
	if(MinUIConfig.globalTextFont) then
		uBar.leftText:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end
	
	-- create text shadow 1
	uBar.leftTextShadow = UI.CreateFrame("Text", name .. "_textshadow1", uBar.bar )
	uBar.leftTextShadow:SetPoint( "CENTERLEFT", uBar.bar, "CENTERLEFT", 1, 2 )
	uBar.leftTextShadow:SetLayer(2)
	uBar.leftTextShadow:SetVisible(true)
	uBar.leftTextShadow:SetFontSize(fontSize)
	uBar.leftTextShadow:SetFontColor(0,0,0,1)
	uBar.leftTextShadow:SetWidth(uBar.leftText:GetFullWidth())
	uBar.leftTextShadow:SetHeight(uBar.leftText:GetFullHeight())
	-- Font: From Config
	if(MinUIConfig.globalTextFont) then
		uBar.leftTextShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end
	
	-- create text 2
	uBar.rightText = UI.CreateFrame("Text", name .. "_text2", uBar.bar )
	uBar.rightText:SetPoint( "CENTERRIGHT", uBar.bar, "CENTERRIGHT", 0, 0 )
	uBar.rightText:SetLayer(3)
	uBar.rightText:SetVisible(true)
	uBar.rightText:SetFontSize(fontSize)
	uBar.rightText:SetText("???")
	uBar.rightText:SetWidth(uBar.rightText:GetFullWidth())
	uBar.rightText:SetHeight(uBar.rightText:GetFullHeight())
	-- Font: From Config
	if(MinUIConfig.globalTextFont) then
		uBar.rightText:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end
	
	-- create text shadow 2
	uBar.rightTextShadow = UI.CreateFrame("Text", name .. "_textshadow2", uBar.bar )
	uBar.rightTextShadow:SetPoint( "CENTERRIGHT", uBar.bar, "CENTERRIGHT", 1, 2 )
	uBar.rightTextShadow:SetLayer(2)
	uBar.rightTextShadow:SetVisible(true)
	uBar.rightTextShadow:SetFontSize(fontSize)
	uBar.rightTextShadow:SetFontColor(0,0,0,1)
	uBar.rightTextShadow:SetWidth(uBar.rightText:GetFullWidth())
	uBar.rightTextShadow:SetHeight(uBar.rightText:GetFullHeight())
	-- Font: From Config
	if(MinUIConfig.globalTextFont) then
		uBar.rightTextShadow:SetFont("MinUI", MinUIConfig.globalTextFont..".ttf")
	end
	
	-- check bar is big enough for text
	if(uBar.leftText:GetFullHeight() > uBar.height) then
		uBar.height = uBar.leftText:GetFullHeight()
		uBar.bar:SetHeight(uBar.height)
		uBar.solid:SetHeight(uBar.height)
		uBar.leftText:SetHeight(uBar.height)
		uBar.leftTextShadow:SetHeight(uBar.height)
	end
	
	return uBar
end

--
-- Set UBar Color
--
function UnitBar:setUBarColor( r,g,b )
	self.bar:SetBackgroundColor(r,g,b, 0.3)
	self.solid:SetBackgroundColor(r,g,b, 0.8)
end

function UnitBar:setUBarColorAlpha(r,g,b,a)
	self.bar:SetBackgroundColor(r,g,b,a)
	self.solid:SetBackgroundColor(r,g,b,a)
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
	self.solid:SetVisible(toggle)
end

--
--
--
function UnitBar:getUBarOffsetY()
	return self.offsetY
end

--
-- set left text
--
function UnitBar:setUBarLeftText(text)
	self.leftText:SetText(text)
	self.leftTextShadow:SetText(text)
	self.leftText:SetWidth(self.leftText:GetFullWidth())
	self.leftText:SetHeight(self.leftText:GetFullHeight())
	self.leftTextShadow:SetWidth(self.leftText:GetFullWidth())
	self.leftTextShadow:SetHeight(self.leftText:GetFullHeight())
end

--
-- set right text
--
function UnitBar:setUBarRightText(text)
	self.rightText:SetText(text)
	self.rightTextShadow:SetText(text)
	self.rightText:SetWidth(self.rightText:GetFullWidth())
	self.rightText:SetHeight(self.rightText:GetFullHeight())
	self.rightTextShadow:SetWidth(self.rightText:GetFullWidth())
	self.rightTextShadow:SetHeight(self.rightText:GetFullHeight())
	
	
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
	self.solid:SetWidth(self.width * ratio)
end
