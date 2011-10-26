--
-- Bar Widget by Grantus
-- 
-- A Rift UI Frame extension that has a resizable solid component (which may be textured).
-- Can be vertical or horizontal.
--
--
Bar = {}
Bar.__index = Bar

--
-- Bar:new()
--
-- @params
--		width number: the width of the new bar
--		height number: the height of the new bar
--		orientation string: vertical or horizontal, the way the bar lays out
--		bgColor table: the color of the background, expects a table with T.r, T.g, T.bar, T.a set to numbers
--		barColor table: the color of the bar, expects a table with T.r, T.g, T.bar, T.a set to numbers
--		texturePath string: path of the texture to use
--		context table: the rift ui context used to create the bar
--
function Bar.new( width, height, orientation, direction, bgColor, barColor, texturePath, context, layer )
	local bar = {}             	-- our new object
	setmetatable(bar, Bar)    	-- make Bar handle lookup
	
	-- Create the frame itself - this part holds the other components
	-- That constitute a "bar" and is the background
	-- Does not SetPoint as all widgets in grUF should be placed in a container
	-- Containers essentially act like Java Swing Panels woth horizontal and vertical box layouts
	bar.frame = UI.CreateFrame("Frame", "BarFrame", context )
	bar.frame:SetWidth(width)
	bar.frame:SetHeight(height)
	bar.frame:SetBackgroundColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	bar.frame:SetLayer(layer)
	bar.frame:SetVisible(false)
	
	-- Store vars
	bar.width = width
	bar.height = height
	bar.bgColor = bgColor
	bar.barColor = barColor
	bar.texturePath = texturePath
	bar.orientation = orientation
	bar.direction = direction
	bar.layer = layer
	
	-- Create textured component that resizes
	bar.texture = UI.CreateFrame("Texture", "BarTexture", bar.frame)
	bar.texture:SetTexture("gUF", bar.texturePath )
	bar.texture:SetWidth(bar.width)
	bar.texture:SetHeight(bar.height)
	bar.texture:SetLayer(bar.layer+1)

	-- Create solid component that resizes
	bar.solid = UI.CreateFrame("Frame", "BarSolid", bar.frame)
	bar.solid:SetWidth(bar.width)
	bar.solid:SetHeight(bar.height)
	bar.solid:SetLayer(bar.layer+2)
	bar.solid:SetBackgroundColor(barColor.r,barColor.g,barColor.b,barColor.a)
	
	-- orientation based on direction and orientation
	if ( bar.orientation == "horizontal" and bar.direction  == "right" ) then
		bar.solid:SetPoint("CENTERLEFT", bar.frame, "CENTERLEFT", 0, 0 )
		bar.texture:SetPoint("CENTERLEFT", bar.frame, "CENTERLEFT", 0, 0 )
	elseif ( bar.orientation == "horizontal " and bar.direction  == "left" ) then
		bar.solid:SetPoint("CENTERRIGHT", bar.frame, "CENTERRIGHT", 0, 0 )
		bar.texture:SetPoint("CENTERRIGHT", bar.frame, "CENTERRIGHT", 0, 0 )
	elseif ( bar.orientation == "vertical" and bar.direction  == "up" ) then
		bar.solid:SetPoint("BOTTOMCENTER", bar.frame, "BOTTOMCENTER", 0, 0 )
		bar.texture:SetPoint("BOTTOMCENTER",bar.frame, "BOTTOMCENTER", 0, 0 )
	elseif ( bar.orientation == "vertical" and bar.direction  == "down" ) then
		bar.solid:SetPoint("TOPCENTER", bar.frame, "TOPCENTER", 0, 0 )
		bar.texture:SetPoint("TOPCENTER", bar.frame, "TOPCENTER", 0, 0 )	
	end
		 
	return bar
end

--
-- Get layer of this box
--
function Bar:GetLayer()
	return (self.layer+2) -- accounting for texture and solid bar
end

--
-- SetPoint of Bar
--
-- @params
--		anchorSelf string: the point on the Box that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		newParent table: frame this Box anchors on, expects a rift frame
--		anchorParent string: the point on the anchor shall the Box anchor on
--		xOffset number: the x offset
--		yOffset number: the y offset
--
function Bar:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	--print ( "bar set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.frame:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- Toggle the Bar's Visibility
--
function Bar:SetVisible(toggle)
	self.frame:SetVisible(toggle)
end

--
-- Sets the current value of the bar, which will cause the solid and texture components to resize as a percentage of the 
-- width or height of the bar
--
-- @params
--		ratio number: the ratio of the total width or height the solid/texture components should fill, to function correctly
--					  you should give a number between 0.0 and 1.0					
--
--
function Bar:SetCurrentValue( ratio )
	local width =  self.width * ratio
	local height =  self.height * ratio
	
	if ( self.orientation == "horizontal" ) then
		--print("new width", width)
		self.solid:SetWidth( width )
		self.texture:SetWidth( width )
	elseif ( self.orientation == "vertical" ) then
		--print("new width", width)
		self.solid:SetHeight( height )
		self.texture:SetHeight( height )
	end
end

--
-- Return a handle to the RiftUI frame this bar is built upon
-- 
-- Used to layout items mostly
--
function Bar:GetFrame()
	return self.frame
end

--
-- get width of the bar
--
function Bar:GetWidth()
	return self.width
end

--
-- set width of the bar
--
function Bar:SetWidth( newWidth )
	self.width = newWidth
	self.frame:SetWidth(self.width)
end

--
-- get height of the bar
--
function Bar:GetHeight()
	return self.height
end

--
-- set height of the bar
--
function Bar:SetHeight( newHeight )
	self.height = newHeight
	self.frame:SetHeight(self.width)
end

--
-- set background color of the bar
-- 
-- @params
--		bgColor table: the color of the background, expects a table with T.r, T.g, T.bar, T.a set to numbers
--
function Bar:SetBGColor( bgColor )	
	--print(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	self.bgColor = bgColor
	self.frame:SetBackgroundColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
end

--
-- set color of the bars
-- 
-- @params
--		barColor table: the color of the bar, expects a table with T.r, T.g, T.bar, T.a set to numbers
--
function Bar:SetBarColor ( barColor )
	--print(barColor.r,barColor.g,barColor.b,barColor.a)
	self.barColor = barColor
	self.solid:SetBackgroundColor(barColor.r,barColor.g,barColor.b,barColor.a)
end

--
-- set the texture of the bar
--
-- @params
--		texturePath string: the path of the texture
--
function Bar:SetTexture ( resourceDir, texturePath )
	self.texturePath = texturePath
	self.texture:SetTexture( resourceDir, texturePath)
end
