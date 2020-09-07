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

if	base_path == nil then
	base_path = (string.gsub(debug.getinfo(1).source, "sonic[\\\\/][%w%-]+%.lua", "?.lua", 1)):sub(2)
	package.path = base_path .. ";" .. package.path
end

--------------------------------------------------------------------------------
--	Icon showing the item to be gained if you break a monitor in the
--	next frame in 2p mode.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

require("sonic/common/rom-check")
require("headers/register")
require("headers/widgets")
require("sonic/common/game-info")

local curr_data = rom.data

if curr_data.Two_player_mode ~= nil and curr_data.Two_player_items then
	local monitor_icon = Icon_widget:new(72 + 4 * 44, 0, function()
			local frames = AND(memory.readword(rom.data.Timer_frames), 7)
			if frames == 0 then
				return "sonic-normal"
			elseif frames == 1 then
				return "tails-normal"
			elseif frames == 2 then
				return "eggman"
			elseif frames == 3 then
				return "ring"
			elseif frames == 4 then
				return "superspeed"
			elseif frames == 5 then
				return "shield-normal"
			elseif frames == 6 then
				return "invincibility"
			elseif frames == 7 then
				return "teleport"
			else
				return "blank"
			end
		end)
	callbacks.gens.registerafter:add(function()
			if not game:disable_hud() and memory.readword(curr_data.Two_player_mode) ~= 0 and memory.readword(curr_data.Two_player_items) == 0 then
				monitor_icon:draw()
			end
		end)
end

