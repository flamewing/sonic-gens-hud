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
--	A self-organizing togglable container widget.
--	Written by: Marzo Junior
-------------------------------------------------------------------------------

require("headers/lua-oo")
require("headers/widgets")
require("sonic/common/char-info")

Status_widget = class{
}:extends(Container_widget)

function Status_widget:move(x, y)
	local dx = x - self.x
	local dy = y - self.y
	if dx == 0 and dy == 0 then
		return
	end
	self.x = x
	self.y = y
	if self.toggle then
		self.toggle:move(self.toggle.x + dx, self.toggle.y + dy)
	end
	for _,m in pairs(self.children) do
		m:move(m.x + dx, m.y + dy)
	end
end

function Status_widget:draw()
	if self.active then
		local function status_huds_x(n)
			return 44 * (n%4) + self.x
		end
	
		local function status_huds_y(n)
			return 3 + math.floor(n/4) * 19 + self.y
		end

		for _, char in pairs(characters) do
			--	Only do it if the character is actually in the game (e.g., Tails in
			--	Sky Chase/Wing Fortress/Death Egg in S2 or Doomsday in S3&K).
			if char:in_game() then
				for _, item in pairs(char.status_huds) do
					if not item.active and item.is_active(item.obj) then
						local n = #self.children
						self:add(item, status_huds_x(n), status_huds_y(n))
						item.active = true
					end
				end
			end
		end
	
		local remove_queue = {}
		for n, item in pairs(self.children) do
			local j = n-1
			item:move(status_huds_x(j), status_huds_y(j))
			if not item:draw() then
				table.insert(remove_queue, 1, n)
			end
		end
	
		local todel = remove_queue[1]
		while todel do
			table.remove(remove_queue, 1)
			table.remove(self.children, todel)
			todel = remove_queue[1]
		end
	end
	if self.toggle then
		self.toggle:draw()
	end
	return self.active
end

function Status_widget:construct(x, y, active)
	Container_widget.construct(self, x, y, active)
	self:add_toggle(make_toggle(4 * 44 - 2, true, Container_widget.toggled, self, active), 0, 0)
	self.cleanfun = function()
			while #self.children > 0 do
				table.remove(self.children, 1)
			end
		end
	return self
end

