--
-- Text Widget by Grantus
--
-- An wrapper on a Rift Text Frame that will autoresize to fit the text it contains or truncate based on user settings
-- Will also fake text outline and shadows by using a copy of itself as a shadow/outline
-- 
-- For now outline and shadow are the same because outline doesnt function as I would like
--

Text = {}
Text.__index = Text

--
-- Create a new Text Widget
--
-- @params
--		font string: the font to use
--		fontSize number: the size of the font
--		fontColor table: font color, expects a table with T.r, T.g, T.bar, T.a set to font color
--		mode string: truncate or grow
--		maxSize number: max string length for truncating text items only
--		style string: normal, shadow or outline
--
--
function Text.new( font, fontSize, fontColor, mode, maxSize, style, context, layer  )
	local text = {}             	-- our new object
	setmetatable(text, Text)    	-- make Text handle lookup
	
	-- Store vars
	text.font = font
	text.fontSize = fontSize
	text.mode = mode
	text.style = style
	text.maxSize = maxSize
	text.curText = ""
	text.fontColor = fontColor	
	text.layer = layer

	-- Create text frame
	text.frame = UI.CreateFrame("Text", "Text", context)
	text.frame:SetFont("gUF", text.font)
	text.frame:SetFontColor(fontColor.r,fontColor.g,fontColor.b,fontColor.a)
	text.frame:SetFontSize(text.fontSize)
	text.frame:SetLayer(text.layer+1)
	
	-- Create shadow or outline text frame
	if ( text.style == "shadow" ) then
		text.shadow = UI.CreateFrame("Text", "Text", context)
		text.shadow:SetFont("gUF", text.font)
		text.shadow:SetFontSize(text.fontSize)
		text.shadow:SetFontColor(0,0,0,1)
		text.shadow:SetLayer(text.layer)
	elseif ( text.style == "outline" ) then
		text.outline = UI.CreateFrame("Text", "Text", context)
		text.outline:SetFont("gUF", text.font)
		text.outline:SetFontSize(text.fontSize)
		text.outline:SetFontColor(0,0,0,1)
		text.outline:SetLayer(text.layer)
	end
	
	-- Set max size or grow to fit a string of maxSize
	if ( text.mode == "truncate" ) then
		local tempString = "0"
		for i=1,maxSize do
			tempString = tempString .. "0"
		end
		text.frame:SetText(tempString)
		text.frame:SetWidth(text.frame:GetFullWidth())
		text.frame:SetHeight(text.frame:GetFullHeight())
		
		if ( text.style == "shadow" ) then
			text.shadow:SetWidth(text.frame:GetFullWidth())
			text.shadow:SetHeight(text.frame:GetFullHeight())
		elseif ( text.style == "outline" ) then
			text.outline:SetWidth(text.frame:GetFullWidth())
			text.outline:SetHeight(text.frame:GetFullHeight())
		end
	elseif ( text.mode == "grow" ) then	
		text.frame:SetText("")
		text.frame:SetWidth(text.frame:GetFullWidth())
		text.frame:SetHeight(text.frame:GetFullHeight())
		
		if ( text.style == "shadow" ) then
			text.shadow:SetWidth(text.frame:GetFullWidth())
			text.shadow:SetHeight(text.frame:GetFullHeight())
		elseif ( text.style == "outline" ) then
			text.outline:SetWidth(text.frame:GetFullWidth())
			text.outline:SetHeight(text.frame:GetFullHeight())
		end
	end
	
	return text
end

--
-- Set Point wrapper
--
function Text:SetPoint( anchorSelf, anchor, anchorItem, xOffset, yOffset )
	self.frame:SetPoint( anchorSelf, anchor, anchorItem, xOffset, yOffset )
	
	if(self.style=="shadow")then
		self.shadow:SetPoint( anchorSelf, anchor, anchorItem, xOffset+1, yOffset+1 )
	elseif(self.style=="outline")then
		self.outline:SetPoint( anchorSelf, anchor, anchorItem, xOffset+1, yOffset+1 )
	end
end


--
-- Get layer of this box
--
function Text:GetLayer()
	return (self.layer+1) -- accounting for shadows
end

--
-- Return a handle to the RiftUI frame this bar is built upon
-- 
-- Used to layout items mostly
--
function Text:GetFrame()
	return self.frame
end

--
-- Set Text on this frame
--
-- @params
--		text string: the new text
--
function Text:SetText( text )
	self.frame:SetText(text)
	
	-- check style and update if needed
	if( self.style == "shadow" ) then
		self.shadow:SetText(text)
	elseif ( self.style == "outline" ) then
		self.outline:SetText(text)
	end
	
	-- grow to fit if needed
	if ( self.mode == "grow" ) then
		self.frame:SetWidth(self.frame:GetFullWidth())
		self.frame:SetHeight(self.frame:GetFullHeight())
		if ( self.style == "shadow" ) then
			self.shadow:SetWidth(self.frame:GetFullWidth())
			self.shadow:SetHeight(self.frame:GetFullHeight())
		elseif ( self.style == "outline" ) then
			self.outline:SetWidth(self.frame:GetFullWidth())
			self.outline:SetHeight(self.frame:GetFullHeight())
		end
	end
end


