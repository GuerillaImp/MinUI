--
-- Box Widget by Grantus
--
-- An wrapper on a Rift Frame that will autosize to fit what it holds and lay items out horizontally or vertically.
-- 

Box = {}
Box.__index = Box

--
-- Create a boxainer
--
-- @params
--		x number: the x offset
--		y number: the y offset
-- 		padding number: padding between item
--		anchorPointSelf string: the point on the boxainer that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		anchorItem table: frame this boxainer anchors on, expects a rift frame
--		anchorPointParent string: the point on the anchorItem shall the boxainer anchor on
--
function Box.new( anchorPointSelf, anchor, anchorPointParent, x, y, padding, bgColor, layout, layer  )
	local box = {}             		-- our new object
	setmetatable(box, Box)      	-- make Box handle lookup
	

	-- Store Values for the Box
	box.layout = layout
	box.anchorPointSelf = anchorPointSelf
	box.anchor = anchor
	box.anchorPointParent = anchorPointParent
	box.padding = padding
	box.layer = layer
	
	-- Store the items that the boxainer holds, used to layout the items
	box.items = {} -- list of items in the boxainer
	box.itemCount = 0 -- count
	box.lastItem = nil -- the last item added (acts as the anchor for the next item)
	
	-- Create the frame
	box.frame = UI.CreateFrame("Frame", "Box", anchor )
	box.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
	box.frame:SetWidth(100)
	box.frame:SetHeight(100)
	box.frame:SetLayer(box.layer)
	box.frame:SetVisible(false)
	box.frame:SetBackgroundColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	
	return box
end

--
-- Get layer of this box
--
function Box:GetLayer()
	return self.layer
end

--
-- Set Point Wrapper
--
function Box:SetPoint( anchorSelf, anchor, anchorItem, xOffset, yOffset )
	self.frame:SetPoint( anchorSelf, anchor, anchorItem, xOffset, yOffset ) 
end


--
-- Get the RiftUI Frame
--
function Box:GetFrame()
	return self.frame
end

--
-- Toggle the boxainer's visiblity
--
function Box:SetVisible( toggle )
	self.frame:SetVisible( toggle )
end

--
-- Get x offset for the boxainer
--
function Box:GetX()
	return self.x
end

--
-- Set x offset for the boxainer
--
function Box:SetX( x )
	self.x = x
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get y offset for the boxainer
--
function Box:GetY()
	return self.y
end

--
-- Set y offset for the boxainer
--
function Box:SetY( y )
	self.y = y
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get anchor
--
function Box:GetAnchor()
	return self.anchor
end

--
-- Set anchor for the boxainer
--
function Box:SetAnchor( anchorPointSelf, anchor, anchorPointParent, x, y )
	self.x = x
	self.y = y
	self.frame:SetPoint( anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Resize to fit the items in the boxainer
--
function Box:ClearSize()
	local widthRequired = 0
	local heightRequired = 0
	
	local maxWidth = 0
	local maxHeight = 0
	
	if ( self.layout == "vertical" ) then
		-- calculate size requirements
		for index,item in ipairs(self.items) do
			heightRequired = heightRequired + item:GetHeight()
			
			if(item:GetWidth() > maxWidth)then
				maxWidth = item:GetWidth()
			end
		end
		
		-- resize
		self.frame:SetWidth(maxWidth + self.padding*2 )
		self.frame:SetHeight(heightRequired + self.padding*2 )
	elseif ( self.layout == "horizontal" ) then
		-- calculate size requirements
		for index,item in ipairs(self.items) do
			widthRequired = widthRequired + item:GetWidth()
			
			if(item:GetHeight() > maxHeight)then
				maxHeight = item:GetHeight()
			end
		end
		
		-- resize
		self.frame:SetWidth(widthRequired + self.padding*2 )
		self.frame:SetHeight(maxHeight + self.padding*2 )
	end
end

--
-- Add an item to this boxainer
--
-- @params
--		itemToAdd table: The grUF Widget to add to this boxainer
--		xOffset number: The xOffset that the item will be used to attach the new item
--		yOffset number: The yOffset that the item will be used to attach the new item
--
function Box:AddItem( itemToAdd, xOffset, yOffset )
	-- If another item has been added attach to it
	if(self.lastItem)then
		print("attaching to previous item",self.lastItem:GetFrame())
		if (self.layout == "vertical") then
			itemToAdd:SetPoint( "BOTTOMLEFT", self.lastItem:GetFrame(), "TOPLEFT", xOffset, yOffset - self.padding )
		elseif (self.layout == "horizontal") then
			itemToAdd:SetPoint( "CENTERLEFT", self.lastItem:GetFrame(), "CENTERRIGHT", xOffset + self.padding, yOffset  )
		end
	-- Attach to the frame itself
	else
		print("attaching to root item")
		if (self.layout == "vertical") then
			itemToAdd:SetPoint( "TOPLEFT", self.frame, "TOPLEFT", xOffset + self.padding, yOffset + self.padding )
		elseif (self.layout == "horizontal") then	
			itemToAdd:SetPoint( "TOPLEFT", self.frame, "TOPLEFT", xOffset + self.padding, yOffset + self.padding )
		end
	end
	
	-- Store the new item
	self.itemCount = self.itemCount + 1
	self.items[self.itemCount] = itemToAdd
	self.lastItem = itemToAdd
	
	-- Resize to fit items boxained within
	self:ClearSize()
end


