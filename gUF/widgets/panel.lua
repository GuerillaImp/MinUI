--
-- Panel Widget by Grantus
--
-- An wrapper on a Rift Frame that enables users to add things into a Panel
-- 

Panel = {}
Panel.__index = Panel

--
-- Create a panel
--
-- @params
--
--
function Panel.new( width, height, bgColor, context, layer  )
	local panel = {}             		-- our new object
	setmetatable(panel, Panel)      	-- make Panel handle lookup
	

	-- Store Values for the Panel
	panel.width = width
	panel.height = height
	panel.layer = layer
	
	-- Items in this panel
	panel.items = {}
	panel.itemCount = 0 -- count
	
	-- Create the frame
	panel.frame = UI.CreateFrame("Frame", "Panel", context )
	panel.frame:SetWidth(panel.width )
	panel.frame:SetHeight(panel.height )
	panel.frame:SetLayer(panel.layer)
	panel.frame:SetVisible(false)
	panel.frame:SetBackgroundColor(bgColor.r,bgColor.g,bgColor.b,bgColor.a)
	
	return panel
end

--
-- Get layer of this box
--
function Panel:GetLayer()
	return self.layer
end

--
-- SetPoint of Panel
--
-- @params
--		anchorSelf string: the point on the Box that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		newParent table: frame this Box anchors on, expects a rift frame
--		anchorParent string: the point on the anchor shall the Box anchor on
--		xOffset number: the x offset
--		yOffset number: the y offset
--
function Panel:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset )
	print ( "panel set point ", anchorSelf, newParent, anchorParent, xOffset, yOffset )
	self.frame:SetPoint( anchorSelf, newParent, anchorParent, xOffset, yOffset ) 
end

--
-- Get Frame
--
function Panel:GetFrame()
	return self.frame
end

--
--
--
function Panel:SetWidth ( width )
	self.width = width
	self.frame:SetWidth(self.width)
end

--
--
--
function Panel:GetWidth ( )
	return self.width
end

--
--
--
function Panel:SetHeight ( height )
	self.height = height
	self.frame:SetWidth(self.height)
end

--
--
--
function Panel:GetHeight ( )
	return self.height
end

--
-- Remove item at given index (if it exists)
--
function Panel:RemoveItem ( itemIndex ) 
	if(self.items[itemIndex])then
		local itemRemoved = table.remove (self.items, itemIndex)
		itemRemoved:SetVisible(false)
		itemRemoved:SetPoint("TOPLEFT", gUF.context, "TOPLEFT", 0,0)
		self.itemCount = self.itemCount - 1
	end
end

--
-- Toggle the Panel's visiblity
--
function Panel:SetVisible( toggle )
	self.frame:SetVisible( toggle )
	
	for _,item in pairs(self.items)do
		item:SetVisible( toggle )
	end
end

--
-- Get x offset for the panel
--
function Panel:GetX()
	return self.x
end

--
-- Set x offset for the panel
--
function Panel:SetX( x )
	self.x = x
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get y offset for the panel
--
function Panel:GetY()
	return self.y
end

--
-- Set y offset for the panel
--
function Panel:SetY( y )
	self.y = y
	self.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Get anchor
--
function Panel:GetAnchor()
	return self.anchor
end

--
-- Set anchor for the panel
--
function Panel:SetAnchor( anchorPointSelf, anchor, anchorPointParent, x, y )
	self.x = x
	self.y = y
	self.frame:SetPoint( anchorPointSelf, anchor, anchorPointParent, x, y )
end

--
-- Add an item to this panel
--
-- @params
--		itemToAdd table: The grUF Widget to add to this panel
--		anchorSelf string: The RiftUI anchor point for the item on itself
--		anchorPanel string: The RiftUI anchor point for the item on the panel
--		xOffset number: The xOffset that the item will be used to attach the new item
--		yOffset number: The yOffset that the item will be used to attach the new item
--
function Panel:AddItem( itemToAdd, anchorSelf, anchorPanel, xOffset, yOffset )
	itemToAdd:SetPoint( anchorSelf, self.frame, anchorPanel, xOffset, yOffset )
	
	self.itemCount = self.itemCount + 1
	self.items[self.itemCount] = itemToAdd
end


