--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Dynamic icon loader for widgets.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

local img_path = (string.gsub(debug.getinfo(1).source, "headers/ui%-icons%.lua", "img")):sub(2)

local function open_image(fname)
	local prefix = img_path
	local filename = prefix .. "/" .. fname
	local file = io.open(filename, "rb") or
		error(debug.traceback(string.format("Error: Image '%s' could not be found.", filename)), 0)
	local retvar = file:read("*a")
	file:close()
	return retvar
end

ui_icons = {}
setmetatable(ui_icons, {__index = function (self,image)
		local v = open_image("ui-icon-" .. image .. ".luaimg")
		self[image] = v
		return v
	end})

