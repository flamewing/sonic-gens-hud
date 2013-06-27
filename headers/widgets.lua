-------------------------------------------------------------------------------
--	This file is part of the Lua HUD for TASing Sega Genesis Sonic games.
--	
--	This program is free software: you can redistribute it and/or modify
--	it under the terms of the GNU Lesser General Public License as 
--	published by the Free Software Foundation, either version 3 of the 
--	License, or (at your option) any later version.
--	
--	This program is distributed in the hope that it will be useful,
--	but WITHOUT ANY WARRANTY; without even the implied warranty of
--	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--	GNU General Public License for more details.
--	
--	You should have received a copy of the GNU Lesser General Public License
--	along with this program.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--	User interface widgets for Lua in Gens.
--	Written by: Marzo Junior
-------------------------------------------------------------------------------

require("headers/lua-oo")
require("headers/input-handler")
require("headers/ui-icons")

-------------------------------------------------------------------------------
--	Generic abstract base interface: store position only.
--	Should not be used on its own.
-------------------------------------------------------------------------------
widget = class{
	x = nil,
	y = nil
}

--[[
--	Static assertion function for debugging purposes.
function widget.assert(instance)
	if instance.isa ~= nil then
		if instance:isa(widget) == true then
			return true
		end
	end
	error(debug.traceback(string.format("Error: The variable 'child' must descend from the class 'widget'.")), 0)
	return false
end
]]

function widget:add(child, dx, dy)
	error(debug.traceback(string.format("Error: Pure virtual function 'widget:add' called.")), 0)
end

--	Note: calling this from any but derived widgets with an 'add' member will
--	result in an error.
function widget:add_status_icon(dx, dy, image, objim, text, objt, border, fill)
	local icon  = Icon_widget:new(0, 0, image, objim)
	local watch = Text_widget:new(0, 0, text, objt, border, fill)
	self:add(icon , self.x + dx     , self.y + dy     )
	self:add(watch, self.x + dx + 20, self.y + dy +  4)
end

--	Move to different location.
function widget:move(x, y)
	self.x = x
	self.y = y
end

--	Create widget and set position.
function widget:construct(x, y)
	self.x = x
	self.y = y
	return self
end

-------------------------------------------------------------------------------
--	A widget which displays an image.
-------------------------------------------------------------------------------
Icon_widget = class{
	image = nil,
	draw = nil
}:extends(widget)

--	'image' can be a gdimage or a drawing function. The latter requires an
--	object to be supplied so that the function knowns what to do.
function Icon_widget:construct(x, y, image, obj)
	widget.construct(self, x, y)
	local type = type(image)
	self.image = image
	if type == "function" then
		self.draw = function (self) gui.drawimage(self.x, self.y, ui_icons[self.image(obj)]) end
	elseif type == "string" then
		self.draw = function (self) gui.drawimage(self.x, self.y, ui_icons[self.image]) end
	end
	return self
end

-------------------------------------------------------------------------------
--	A widget which displays text.
-------------------------------------------------------------------------------
Text_widget = class{
	text = nil,
	border = nil,
	fill = nil,
	draw = nil
}:extends(widget)

--	'image' can be a raw string or a function. The latter requires an
--	object to be supplied so that the function knowns what to do.
function Text_widget:construct(x, y, text, obj, border, fill)
	widget.construct(self, x, y)
	self.text = text
	self.border = border or {0, 0, 0, 0}
	self.fill = fill or {255, 255, 255, 255}
	local type = type(text)
	if type == "function" then
		self.draw = function (self) gui.text(self.x, self.y, self.text(obj), self.fill, self.border) end
	elseif type == "string" then
		self.draw = function (self) gui.text(self.x, self.y, self.text, self.fill, self.border) end
	end
	return self
end

-------------------------------------------------------------------------------
--	A container widget which draws a rectangular box.
-------------------------------------------------------------------------------
Frame_widget = class{
	w = nil,
	h = nil,
	border = nil,
	fill = nil,
	children = nil
}:extends(widget)

--	Children are added relative.
function Frame_widget:add(child, dx, dy)
	--widget.assert(child)
	child:move(self.x + dx, self.y + dy)
	table.insert(self.children, child)
end

--	Moves all children too.
function Frame_widget:move(x, y)
	local dx = x - self.x
	local dy = y - self.y
	self.x = x
	self.y = y
	for _,m in pairs(self.children) do
		m:move(m.x + dx, m.y + dy)
	end
end

--	Also draws the contained widgets.
function Frame_widget:draw()
	gui.box(self.x, self.y, self.x + self.w, self.y + self.h, self.fill, self.border)
	for _,m in pairs(self.children) do
		m:draw()
	end
	return true
end

function Frame_widget:construct(x, y, w, h, border, fill)
	widget.construct(self, x, y)
	self.w = w
	self.h = h
	self.border = border or {0, 0, 127, 255}
	self.fill = fill or {0, 0, 0, 192}
	self.children = {}
	return self
end

-------------------------------------------------------------------------------
--	A clickable version of a frame widget.
-------------------------------------------------------------------------------
Clickable_widget = class{
	hot = nil,
	on_click = nil,
	udata = nil
}:extends(Frame_widget)

--	Check if mouse is on the widget's area.
function Clickable_widget:is_hot()
	self.hot = (mouse.x >= self.x and mouse.y >= self.y) and
		(mouse.x <= self.x + self.w and mouse.y <= self.y + self.h)
	return self.hot
end

--	Draw widget with different colors to indicate 'hot' or being clicked.
function Clickable_widget:draw()
	local fill = self.fill
	local border = self.border
	if self:is_hot() then
		border = {255, 255, 255, 255}
		if mouse.click then
			fill = {127, 0, 0, 255}
			self.on_click(self.udata)
		else
			fill = {0, 0, 127, 255}
		end
	end
	gui.box(self.x, self.y, self.x + self.w, self.y + self.h, fill, border)
	for _,m in pairs(self.children) do
		m:draw()
	end
	return true
end

function Clickable_widget:construct(x, y, w, h, callback, udata, border, fill)
	Frame_widget.construct(self, x, y, w, h, border or {0, 0, 255, 255}, fill or {0, 0, 127, 255})
	self.hot = false
	self.on_click = callback
	self.udata = udata
	return self
end

function make_button(callback, udata, text, w, h, border, fill)
	local btn = Clickable_widget:new(0, 0, w, h, callback, udata, border, fill)
	btn:add(Text_widget:new(0, 0, text), 1 + math.floor((w + 1 - 4 * #text)/2), 1)
	return btn
end

-------------------------------------------------------------------------------
--	Clickable widget with 'on' and 'off' states. This widget has a separate
--	list of children that are drawn if the widget is 'off'.
-------------------------------------------------------------------------------
Toggle_widget = class{
	active = nil,
	off_children = nil
}:extends(Clickable_widget)

function Toggle_widget:add(child, dx, dy, active)
	--widget.assert(child)
	child:move(self.x + dx, self.y + dy)
	table.insert((active == true and self.children) or self.off_children, child)
end

function Toggle_widget:move(x, y)
	local dx = x - self.x
	local dy = y - self.y
	self.x = x
	self.y = y
	for _,m in pairs(self.children) do
		m:move(m.x + dx, m.y + dy)
	end
	for _,m in pairs(self.off_children) do
		m:move(m.x + dx, m.y + dy)
	end
end

function Toggle_widget:draw()
	local fill = self.fill
	local border = self.border
	if self:is_hot() then
		border = {255, 255, 255, 255}
		if mouse.click then
			fill = {127, 0, 0, 255}
			self.on_click(self.udata)
			self.active = not self.active
		end
	elseif not self.active then
		return true
	end
	gui.box(self.x, self.y, self.x + self.w, self.y + self.h, fill, border)
	for _,m in pairs((self.active and self.children) or self.off_children) do
		m:draw()
	end
	return true
end

--	'callback' is a function to be called when the container is 'toggled'.
--	'udata' is an object which is passed to 'callback'.
function Toggle_widget:construct(x, y, w, h, callback, udata, active, border, fill)
	Clickable_widget.construct(self, x, y, w, h, callback, udata, border or {0, 0, 255, 255}, fill or {0, 0, 127, 255})
	self.active = active
	self.off_children = {}
	return self
end

function make_toggle(dim, horiz, callback, udata, active)
	local w = (horiz and dim) or 3
	local h = (horiz and 3) or dim
	return Toggle_widget:new(0, 0, w, h, callback, udata, active)
end

-------------------------------------------------------------------------------
--	Container widget with a separate toggle widget. The toggle widget is used
--	to toggle the display of the container's children on or off.
-------------------------------------------------------------------------------
Container_widget = class{
	active = nil,
	toggle = nil,
	children = nil
}:extends(widget)

function Container_widget:toggled()
	self.active = not self.active
end

function Container_widget:set_state(flag)
	self.active = flag
	if self.toggle then
		self.toggle.active = flag
	end
end

function Container_widget:add(child, dx, dy)
	--widget.assert(child)
	child:move(self.x + dx, self.y + dy)
	table.insert(self.children, child)
end

function Container_widget:add_toggle(child, dx, dy)
	--widget.assert(child)
	child:move(self.x + dx, self.y + dy)
	self.toggle = child
end

function Container_widget:move(x, y)
	local dx = x - self.x
	local dy = y - self.y
	self.x = x
	self.y = y
	if self.toggle then
		self.toggle:move(self.toggle.x + dx, self.toggle.y + dy)
	end
	for _,m in pairs(self.children) do
		m:move(m.x + dx, m.y + dy)
	end
end

function Container_widget:draw()
	if self.active then
		for _,m in pairs(self.children) do
			m:draw()
		end
	end
	if self.toggle then
		self.toggle:draw()
	end
	return self.active
end

function Container_widget:construct(x, y, active)
	widget.construct(self, x, y)
	self.active = (active == nil and false) or active
	self.children = {}
	self.toggle = nil
	return self
end

-------------------------------------------------------------------------------
--	Container which only shows if certain definable conditions hold.
-------------------------------------------------------------------------------
Conditional_widget = class{
	is_active = nil,
	obj = nil
}:extends(Container_widget)

function Conditional_widget:add_toggle(child, dx, dy)
	--widget.assert(child)
end

function Conditional_widget:move(x, y)
	local dx = x - self.x
	local dy = y - self.y
	self.x = x
	self.y = y
	for _,m in pairs(self.children) do
		m:move(m.x + dx, m.y + dy)
	end
end

function Conditional_widget:draw()
	self.active = self.is_active(self.obj)
	if self.active then
		for _,m in pairs(self.children) do
			m:draw()
		end
	end
	return self.active
end

--	'is_active' is a function that defines the conditions under which the
--	widget appears. 'obj' is an object which is passed to 'is_active'.
function Conditional_widget:construct(x, y, active, is_active, obj)
	Container_widget.construct(self, x, y, active)
	self.is_active = is_active
	self.obj = obj
	return self
end

