--
-- Container Widget by Grantus
--
-- An wrapper on a Rift Frame that will autosize to fit what it holds and lay items out horizontally or vertically.
-- 

Container = {}
Container.__index = Container

--
-- Create a container
--
-- @params
--		x number: the x offset
--		y number: y offset
--		anchorPointSelf string: the point on the container that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		anchorItem table: frame this container anchors on, expects a rift frame
--		anchorPointParent string: the point on the anchorItem shall the container anchor on
--
function Container.new( x, y, anchorPointSelf, anchor, anchorPointParent, bgColor, layout  )
	local cont = {}             		-- our new object
	setmetatable(cont, Container)      	-- make Container handle lookup
	

	-- Store Values for the Container
	cont.layout = layout
	cont.anchorPointSelf = anchorPointSelf
	cont.anchor = anchor
	cont.anchorPointParent = anchorPointParent
	
	-- Store the items that the container holds, used to layout the items
	cont.items = {} -- list of items in the container
	cont.itemCount = 0 -- count
	cont.lastItem = nil -- the last item added (acts as the anchor for the next item)
	
	-- Create the frame
	cont.frame = UI.CreateFrame("Frame", "Container", anchor )
	cont.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
	cont.frame:SetWidth(100)
	cont.frame:SetHeight(100)
	cont.frame:SetLayer(0)
	cont.frame:SetVisible(false)
	cont.frame:SetBackgroundColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	
	return cont
end

--
-- Toggle the container's visiblity
--
function Container:SetVisible( toggle )
	self.frame:SetVisible( toggle )
end

--
-- Get x offset for the container
--
function Container:GetX()
	return self.x
end

--
-- Set x offset for the container
--
function Container:SetX( x )
	self.x = x
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get y offset for the container
--
function Container:GetY()
	return self.y
end

--
-- Set y offset for the container
--
function Container:SetY( y )
	self.y = y
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get anchor
--
function Container:GetAnchor()
	return self.anchor
end

--
-- Set anchor for the container
--
function Container:SetAnchor( anchorPointSelf, anchor, anchorPointParent, x, y )
	self.x = x
	self.y = y
	self.frame:SetPoint( anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Resize to fit the items in the container
--
function Container:ClearSize()
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
		self.frame:SetWidth(maxWidth)
		self.frame:SetHeight(heightRequired)
	elseif ( self.layout == "horizontal" ) then
		-- calculate size requirements
		for index,item in ipairs(self.items) do
			widthRequired = widthRequired + item:GetWidth()
			
			if(item:GetHeight() > maxHeight)then
				maxHeight = item:GetHeight()
			end
		end
		
		-- resize
		self.frame:SetWidth(widthRequired)
		self.frame:SetHeight(maxHeight)
	end
end

--
-- Add an item to this container
--
-- @params
--		itemToAdd table: The grUF Widget to add to this container
--		xOffset number: The xOffset that the item will be used to attach the new item
--		yOffset number: The yOffset that the item will be used to attach the new item
--
function Container:AddItem( itemToAdd, xOffset, yOffset, layer )
	-- If another item has been added attach to it
	if(self.lastItem)then
		print("attaching to previous item",self.lastItem:GetFrame())
		if (self.layout == "vertical") then
			itemToAdd:GetFrame():SetPoint( "TOPCENTER", self.lastItem:GetFrame(), "TOPCENTER", xOffset, yOffset )
		elseif (self.layout == "horizontal") then
			itemToAdd:GetFrame():SetPoint( "CENTERLEFT", self.lastItem:GetFrame(), "CENTERRIGHT", xOffset, yOffset )
		end
	-- Attach to the frame itself
	else
		print("attaching to root item")
		if (self.layout == "vertical") then
			itemToAdd:GetFrame():SetPoint( "TOPCENTER", self.frame, "TOPCENTER", xOffset, yOffset )
		elseif (self.layout == "horizontal") then
			itemToAdd:GetFrame():SetPoint( "CENTERLEFT", self.frame, "CENTERLEFT", xOffset, yOffset )
		end
	end
	
	itemToAdd:GetFrame():SetLayer( layer )
	
	-- Store the new item
	self.itemCount = self.itemCount + 1
	self.items[self.itemCount] = itemToAdd
	self.lastItem = itemToAdd
	
	-- Resize to fit items contained within
	self:ClearSize()
end


