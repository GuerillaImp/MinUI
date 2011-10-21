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
--		x number: the x offset
--		y number: y offset
--		anchorPointSelf string: the point on the panel that shall anchor to the anchorItem expects rift style TOPCENTER, LEFT, etc
--		anchorItem table: frame this panel anchors on, expects a rift frame
--		anchorPointParent string: the point on the anchorItem shall the panel anchor on
--
function Panel.new( anchorPointSelf, anchor, anchorPointParent, x, y, padding, width, height, bgColor, layer  )
	local panel = {}             		-- our new object
	setmetatable(panel, Panel)      	-- make Panel handle lookup
	

	-- Store Values for the Panel
	panel.anchorPointSelf = anchorPointSelf
	panel.anchor = anchor
	panel.anchorPointParent = anchorPointParent
	panel.width = width
	panel.height = height
	panel.padding = padding
	panel.layer = layer
	
	-- Create the frame
	panel.frame = UI.CreateFrame("Frame", "Panel", anchor )
	panel.frame:SetPoint(anchorPointSelf, anchor, anchorPointParent, x, y )
	panel.frame:SetWidth(panel.width)
	panel.frame:SetHeight(panel.height)
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
-- Set Point Wrapper
--
function Panel:SetPoint( anchorSelf, anchor, anchorItem, xOffset, yOffset )
	self.frame:SetPoint( anchorSelf, anchor, anchorItem, xOffset, yOffset ) 
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
-- Toggle the panel's visiblity
--
function Panel:SetVisible( toggle )
	self.frame:SetVisible( toggle )
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
	itemToAdd:SetPoint( anchorSelf, self.frame, anchorPanel, xOffset + self.padding, yOffset + self.padding )
end


