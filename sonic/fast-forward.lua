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
--	Skip boring stuff (special stages, loading screens).
--	Based on code by Nitsuja.
--------------------------------------------------------------------------------

require("sonic/common/game-info")
require("headers/register")

local tx, ty = 100,100
local dx, dy =   1,1

local function want_fast_forward()
	return game:disable_hud() or (skip_score_tally and game:in_score_tally())
end

local function fast_forward()
	if movie.playing() and not movie.recording() and want_fast_forward() then
		sound.clear()
		local iter = 0
		while want_fast_forward() do
			gens.emulateframeinvisible()
			gens.emulateframeinvisible()
			iter = iter + 1
			if iter == 30 then
				iter = 0
				gui.drawtext(320-ty*3/2,tx*2/3, "Please Wait...")
				tx = tx + dx
				ty = ty + dy
				if tx < 0 or tx >= 320 then
					dx = -dx
					tx = tx + (2*dx)
				end
				if ty < 0 or ty >= 240 then
					dy = -dy
					ty = ty + (2*dy)
				end
				return
			end

			if iter == 15 then
				gens.wait()
			end
		end
	end
end

function toggle_fast_forward(enable)
	if enable then
		callbacks.gens.registerafter:add(fast_forward)
	else
		callbacks.gens.registerafter:remove(fast_forward)
	end
end

--	Configuration guard for stand-alone.
if skip_boring_stuff == nil then
	skip_score_tally = true
	toggle_fast_forward(true)
end

