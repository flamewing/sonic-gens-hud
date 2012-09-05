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

if	base_path == nil then
	base_path = (string.gsub(debug.getinfo(1).source, "sonic[\\\\/][%w%-]+%.lua", "?.lua", 1)):sub(2)
	package.path = base_path .. ";" .. package.path
end

-------------------------------------------------------------------------------
--	Icon showing the item to be gained if you break a monitor in the
--	next frame in 2p mode.
--	Written by: Marzo Junior
-------------------------------------------------------------------------------

require("sonic/common/rom-check")
require("headers/register")
require("headers/widgets")
require("sonic/common/hud-images")
require("sonic/common/game-info")

if rom:is_sonic2() then
	local monitor_icon = Icon_widget.Create(72 + 4 * 44, 0, function(self)
			local frames = AND(memory.readword(0xfffe04),7)
			if frames == 0 then
				return ui_icons.sonic_normal
			elseif frames == 1 then
				return ui_icons.tails_normal
			elseif frames == 2 then
				return ui_icons.eggman
			elseif frames == 3 then
				return ui_icons.ring
			elseif frames == 4 then
				return ui_icons.superspeed
			elseif frames == 5 then
				return ui_icons.shield_normal
			elseif frames == 6 then
				return ui_icons.invincibility
			elseif frames == 7 then
				return ui_icons.teleport
			else
				return ui_icons.blank
			end
		end, nil)
	callbacks.gens.registerafter:add(function()
			if not game:disable_hud() and memory.readword(0xffffffd8) ~= 0 and memory.readword(0xffffff75) == 0 then
				monitor_icon:draw()
			end
		end)
end

