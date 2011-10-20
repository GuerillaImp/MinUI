-----------------------------------------------------------------------------------------------------------------------------
--
-- A container: A simple frame to hold things, this will autosize to fit what it holds.
--
----------------------------------------------------------------------------------------------------------------------------- 
Container = {}
Container.__index = Container

--
-- Create a container
--
-- @params
--		x: x offset
--		y: y offset
--		anchorPointSelf: the point on the container that shall anchor to the anchorItem
--		anchorItem: frame this container anchors on
--		anchorPointParent: the point on the anchorItem shall the container anchor on
--
function Container.new( x, y, anchorPointSelf, anchorItem, anchorPointParent, bgColor  )
	local cont = {}             		-- our new object
	setmetatable(cont, Container)      	-- make Container handle lookup
	
	-- Store Values for the Container
	cont.width = width
	cont.height = height
	cont.x = x
	cont.y = y
	cont.anchorItem = anchorItem
	cont.visible = true
	cont.locked = true
	cont.bgColor = bgColor
	
	-- create the frame
	cont = UI.CreateFrame("Frame", cont.unitName, parentItem)
	cont:SetPoint(anchorPointSelf, anchorItem, anchorPointParent, x, y )
	cont:SetWidth(cont.width)
	cont:SetHeight(cont.height)
	cont:SetLayer(0)
	cont:SetVisible(cont.visible)
	cont:SetBackgroundColor(cont.bgColor.r,cont.bgColor.g,cont.bgColor.b,cont.bgColor.a)
end

function Container:getX()
end

function Container:setX( x )
end

function Container:getY()
end

function Container:setY( y )
end

function Container:getAnchor()
end

function Container:setAnchor(anchorPointSelf, anchorItem, anchorPointParent)
end



