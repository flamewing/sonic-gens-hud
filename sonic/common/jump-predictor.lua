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
--	Jump predictor.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

require("sonic/common/rom-check")

--	Create space in memory for a savestate
local state = savestate.create()
local buttons = nil
if rom:has_air_speed_cap() then
	buttons = {left=false, right=false, C=true}
else
	buttons = {C=true}
end

local curr_data = rom.data

--	Functions to determine if jump prediction is desirable
prediction_wanted = nil
if rom:is_sonic_cd() then
	prediction_wanted = function ()
				return memory.readbyte(0xff1510) ~= 0
				       and memory.readbyte(0xfff7cc) == 0
			end
elseif rom:is_sonic3() or rom:is_sonick() then
	prediction_wanted = function ()
				local mode = memory.readbyte(curr_data.Game_Mode)
				return mode == curr_data.GameModeID_Demo or mode == curr_data.GameModeID_Level
			end
else
	local function check_bound(val, min, max)
		return val > min and val < max
	end
	prediction_wanted = function ()
				local mode = memory.readbyte(curr_data.Game_Mode)
				if mode == curr_data.GameModeID_Demo or mode == curr_data.GameModeID_Level then
					return true
				elseif mode == 0x80 + curr_data.GameModeID_Level then
					return not check_bound(memory.readlong(curr_data.Timer), 0, 4)
				end
				return false
			end
end

function want_prediction()
	return enable_predictor and prediction_wanted() and (movie.recording() or not movie.playing())
end

function predict_jumps()
	savestate.save(state)
	for n=1, 2 do
		repeat
			for i, _ in pairs(characters) do
				joypad.set(i, buttons)
			end
			gens.emulateframeinvisible()
		until not gens.lagged()
	end

	--	get jump velocities
	for _, char in pairs(characters) do
		char.jump_speed = char:get_speed()
	end

	savestate.load(state)
end

