--
-- Box Widget by Grantus
--
-- An wrapper on a Rift Frame that will autosize to fit what it holds and lay items out horizontally or vertically.
-- 

Box = {}
Box.__index = Box

--
-- Create a Box
--
-- @params
-- 		padding number: padding between item
--		bgColor table: {r=1,g=1,b=1,a=1} table
--		layout string: horizontal or vertical 
--		direction string: up and down (vertical only), left or right (horizontal only)
--		layer number: what layer of the context shall this be rendered in?
--
function Box.new( padding, bgColor, layout, direction, context, layer )
	local box = {}             		-- our new object
	setmetatable(box, Box)      	-- make Box handle lookup
	
	
	-- Create the frame
	box.frame = UI.CreateFrame("Frame", "Box", context )
	box.frame:SetWidth(padding*2)
	box.frame:SetHeight(padding*2)
	box.frame:SetLayer(layer)
	box.frame:SetVisible(false)
	box.frame:SetBackgroundColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	
	box.texture = UI.CreateFrame("Texture", "BoxTexture", context)
	box.texture:SetVisible(false)
	box.texture:SetLayer(layer+1)
	
	-- Store Values for the Box
	box.layout = layout
	box.padding = padding
	box.layer = layer
	box.direction = direction
	box.width = box.padding*2
	box.height = box.padding*2
	box.textured = false
	
	--print("new box ", box.layout, box.direction)
	
	-- Store the items that the Box holds, used to layout the items
	box.items = {} -- list of items in the Box
	box.itemCount = 0 -- count
	box.lastItem = nil -- the last item added (acts as the anchor for the next item)
	
	return box
end


--
-- Set a Texture to fill the background of this Box
--
function Box:SetTexture ( texturePath )
	if(texturePath)then
		self.texture:SetTexture("gUF", texturePath)
		self.texture:SetWidth(self.width)
		self.texture:SetHeight(self.height)
		self.texture:SetPoint( "TOPLEFT", self.frame, "TOPLEFT", 0, 0 ) 
		self.textured = true
	end
end


--
-- Return the base RiftUI Frame for the box
--
function Box:GetFrame()
	return self.frame
end

--
-- Get layer of this box
--
function Box:GetLayer()
	if not self.textured then
		return self.layer
	else
		return self.layer+1
	end
end

--
-- SetPoint of Box
--
-- @params
--		anchorSelf string: the point on the Box that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		newParent table: frame this Box anchors on, expects a rift frame
--		anchorParent string: the point on the anchor shall the Box anchor on
--		xOffset number: the x offset
--		yOffset number: the y offset
--
function Box:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	--print ( "Box set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.frame:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- Toggle the Box's visiblity
--
function Box:SetVisible( toggle )
	--print ( "box set visible", toggle )
	
	self.frame:SetVisible( toggle )
	
	if self.textured then
		self.texture:SetVisible( toggle )
	end

	for _,item in pairs(self.items)do
		item:SetVisible( toggle )
	end
end

--
-- Get x offset for the Box
--
function Box:GetX()
	return self.x
end

--
-- Set x offset for the Box
--
function Box:SetX( x )
	self.x = x
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get y offset for the Box
--
function Box:GetY()
	return self.y
end

--
-- Set y offset for the Box
--
function Box:SetY( y )
	self.y = y
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
--
--
function Box:GetWidth()
	return self.width
end

--
--
--
function Box:GetHeight()
	return self.height
end

--
-- Resize to fit the items in the Box
--
function Box:ClearSize()
	local widthRequired = 0
	local heightRequired = 0
	
	local maxWidth = 0
	local maxHeight = 0
	
	if ( self.layout == "vertical" ) then
		-- calculate size requirements
		for index,item in ipairs(self.items) do
			heightRequired = heightRequired + item:GetHeight() + self.padding
			
			if(item:GetWidth() > maxWidth)then
				maxWidth = item:GetWidth()
			end
		end
		
		-- resize
		self.frame:SetWidth( maxWidth + self.padding*2 )
		self.frame:SetHeight( heightRequired + self.padding )
		self.width = maxWidth + self.padding*2
		self.height = heightRequired + self.padding
	elseif ( self.layout == "horizontal" ) then
		-- calculate size requirements
		for index,item in ipairs(self.items) do
			widthRequired = widthRequired + item:GetWidth() + self.padding
			
			if(item:GetHeight() > maxHeight)then
				maxHeight = item:GetHeight()
			end
		end
		
		-- resize
		self.frame:SetWidth( widthRequired + self.padding )
		self.frame:SetHeight( maxHeight + self.padding*2 )
		self.width = widthRequired + self.padding
		self.height = maxHeight + self.padding*2
	end
	
	-- set texture width if required
	if self.textured then
		self.texture:SetWidth(self.width)
		self.texture:SetHeight(self.height)
	end
end

--
-- Add an widget to this Box
--
-- @params
--		itemToAdd table: The grUF Widget to add to this Box
--
function Box:AddItem( itemToAdd )
	-- If another item has been added attach to it
	if(self.lastItem)then
		--print("attaching to previous item")
		
		if ( self.layout == "vertical" and self.direction == "up" ) then
			itemToAdd:SetPoint( "BOTTOMLEFT", self.lastItem:GetFrame(), "TOPLEFT", 0, -self.padding )
		elseif ( self.layout == "vertical" and self.direction == "down" ) then
			itemToAdd:SetPoint( "TOPLEFT", self.lastItem:GetFrame(), "BOTTOMLEFT", 0, self.padding   )
		elseif ( self.layout == "horizontal" and self.direction == "right" ) then	
			itemToAdd:SetPoint( "TOPLEFT", self.lastItem:GetFrame(), "TOPRIGHT", self.padding, 0 )
		elseif ( self.layout == "horizontal" and self.direction == "left" ) then
			itemToAdd:SetPoint( "TOPRIGHT", self.lastItem:GetFrame(), "TOPLEFT",  -self.padding, 0  )
		end
	-- Attach to the frame itself
	else
		--print("attaching to root item")
		
		if ( self.layout == "vertical" and self.direction == "up" ) then
			itemToAdd:SetPoint( "BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.padding, -self.padding )
		elseif ( self.layout == "vertical" and self.direction == "down" ) then
			itemToAdd:SetPoint( "TOPLEFT", self.frame, "TOPLEFT", self.padding, self.padding )
		elseif ( self.layout == "horizontal" and self.direction == "right" ) then
			itemToAdd:SetPoint( "TOPLEFT", self.frame, "TOPLEFT", self.padding, self.padding )
		elseif ( self.layout == "horizontal" and self.direction == "left" ) then
			itemToAdd:SetPoint( "TOPRIGHT", self.frame, "TOPRIGHT", -self.padding, self.padding )
		end
	end
	
	-- Store the new item
	self.itemCount = self.itemCount + 1
	self.items[self.itemCount] = itemToAdd
	self.lastItem = itemToAdd
	
	-- Resize to fit items boxained within
	self:ClearSize()
end