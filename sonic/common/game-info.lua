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
--	Global, character independent, game data.
--	Written by: Marzo Junior
--	Based on game disassemblies and Gens' RAM search.
--------------------------------------------------------------------------------

require("sonic/common/rom-check")
require("sonic/common/enums")

game = {
	curr_char    = nil,
	shields      = nil,
}

local curr_data = rom.data

if rom:is_scheroes() or rom:is_sonic_cd() then
	-- Timer with centiseconds
	function game:get_time()
		return string.format("  %2d'%02d''%02d", memory.readbyte(curr_data.Timer_minute),
							 memory.readbyte(curr_data.Timer_second),
							 math.floor(memory.readbyte(curr_data.Timer_frame) * 10/6))
	end
else
	-- Timer with frames
	function game:get_time()
		return string.format("  %2d:%02d::%02d", memory.readbyte(curr_data.Timer_minute),
							 memory.readbyte(curr_data.Timer_second),
							 memory.readbyte(curr_data.Timer_frame))
	end
end

if curr_data.Timer_frames == nil then
	function game:get_level_frames()
		return 0    --	Not used.
	end
else
	function game:get_level_frames()
		return memory.readbyte(curr_data.Timer_frames+1)
	end
end

function game:get_lives()
	return string.format("x%2d", memory.readbyte(curr_data.Life_count))
end

if curr_data.Continue_count ~= nil then
	function game:get_continues()
		return string.format("x%2d", memory.readbyte(curr_data.Continue_count))
	end
end

function game:get_score()
	return string.format("%11d", 10 * memory.readlong(curr_data.Score))
end

function game:get_raw_rings()
	return memory.readword(rom.ring_offset)
end

if curr_data.Perfect_rings_left == nil then
	function game:get_rings()
		return string.format("%3d", self:get_raw_rings())
	end
else
	function game:get_rings()
		return string.format("%3d (%d)", self:get_raw_rings(), memory.readwordsigned(curr_data.Perfect_rings_left))
	end
end

function game:has_super_emeralds()
	return curr_data.S2_Emerald_count ~= nil
end

--	Only gets called for S3K or SCH:
function game:get_super_emeralds()
	return string.format("%2d", memory.readbyte(curr_data.S2_Emerald_count))
end

--	normal = 0; becoming super = 1; reverting to normal = 2; transformed = -1
if curr_data.Turning_Super_flag == nil then
	function game:super_status()
		return 0
	end
else
	function game:super_status()
		return memory.readbytesigned(curr_data.Turning_Super_flag)
	end
end

--	Super Sonic/Knuckles = 1, Hyper Sonic/Knuckles = -1, all others 0
if curr_data.Super_Sonic_flag == nil then
	function game:hyper_form()
		return false
	end
else
	function game:hyper_form()
		return memory.readbytesigned(curr_data.Super_Sonic_flag) == -1
	end
end

if rom.scroll_delay ~= nil then
	if rom:is_scheroes() then
		-- Indirect value in SCH
		function game:scroll_delay()
			local delayaddr = 0xff0000 + memory.readword(rom.scroll_delay)
			return memory.readword(delayaddr)
		end
	else
		function game:scroll_delay()
			return memory.readbyte(rom.scroll_delay)
		end
	end
else
	function game:scroll_delay()
		return 0
	end
end

function game:super_active()
	return self:super_status() == -1
end

function game:scroll_delay_timer()
	return string.format("%5d", self.scroll_delay())
end

function game:scroll_delay_active()
	return self:scroll_delay() ~= 0
end

if curr_data.Super_Sonic_frame_count ~= nil then
	function game:super_timer()
		return string.format("%5d", 61 * game:get_raw_rings() + memory.readword(curr_data.Super_Sonic_frame_count) - 60)
	end
else
	function game:super_timer()
		return string.format("%5d", 0)
	end
end

if rom:is_sonic_cd() then
	-- This is an ugly hack.
	local function showing_hud()
		return AND(memory.readword(curr_data.HUD_ScoreTime + curr_data.art_tile), 0x7ff) ~= 0x568 or
		       AND(memory.readword(curr_data.HUD_Lives + curr_data.art_tile), 0x7ff) ~= 0x568 or
		       AND(memory.readword(curr_data.HUD_Rings + curr_data.art_tile), 0x7ff) ~= 0x568
	end
	function game:disable_hud()
		--	RAM byte 0xff1522 indicates if Sonic is actually travelling in time;
		--	this is the time travel cutscene proper.
		if memory.readbyte(curr_data.ResetLevel_Flags) == 2 or showing_hud() then
			return true
		end
		return false
	end
elseif curr_data.Ending_running_flag ~= nil then
	local boringmodes = {0, 4, 0x28, 0x34, 0x48, 0x4c, 0x8c}
	function game:disable_hud()
		local mode = memory.readbyte(curr_data.Game_Mode)
		for _, m in ipairs(boringmodes) do
			if mode == m then
				return true
			end
		end
		-- Endgame.
		return memory.readbytesigned(curr_data.Ending_running_flag) == -1
	end
else
	local boringmodes = nil
	local level_loading = 0x80 + curr_data.GameModeID_Level
	if rom:is_scheroes() then
		boringmodes = {
			curr_data.GameModeID_SegaScreen,
			curr_data.GameModeID_TitleScreen,
			curr_data.GameModeID_SpecialStage,
			curr_data.GameModeID_EndingSequence,
			curr_data.GameModeID_OptionsScreen,
			curr_data.GameModeID_S1_Ending,
		}
	elseif rom:is_keh() then
		boringmodes = {0, 1, 2, 5, 6, 7, 8, 9, 10}
	elseif rom:is_sonic2() then
		boringmodes = {0, 4, 0x10, 0x14, 0x18, 0x1c, 0x20, 0x24, 0x28}
	else
		boringmodes = {0, 4, 0x14, 0x18, 0x1c}
	end

	function game:disable_hud()
		local mode = memory.readbyte(curr_data.Game_Mode)
		for _, m in ipairs(boringmodes) do
			if mode == m then
				return true
			end
		end
		if mode == level_loading then
			local time = memory.readlong(curr_data.Timer)
			return not (time > 0 and time < 5)
		end
		return false
	end
end

function game:get_zone()
	return memory.readbyte(curr_data.Apparent_Zone)
end

if curr_data.Apparent_Act == nil then
	function game:get_act()
		return 0
	end

	function game:get_level()
		return game:get_zone()
	end
else
	function game:get_act()
		return memory.readbyte(curr_data.Apparent_Act)
	end

	function game:get_level()
		return memory.readword(curr_data.Apparent_Zone)
	end
end

function game:get_char()
	return rom.get_char()
end

function game:get_mode()
	return memory.readbyte(curr_data.Game_Mode)
end

function game:in_score_tally()
	return memory.readbyte(curr_data.Game_Mode) == curr_data.GameModeID_Level and memory.readlong(curr_data.Bonus_Countdown_1) ~= 0
end

if curr_data.S1_Emerald_count == nil then
	function game:get_chaos_emeralds()
		return 0
	end
elseif rom:is_sonic_cd() then
	--	Emeralds are stored as a bit mask in SCD.
	local emerald_mask = {}
	--	This is probably overkill:
	for i = 0, 255, 1 do
		local count = 0
		local n = i
		while n ~= 0 do
			count = count + (n % 2)
			n = math.floor(n / 2)
		end
		emerald_mask[i] = count
	end

	function game:get_chaos_emeralds()
		return string.format("%3d", emerald_mask[memory.readbyte(curr_data.S1_Emerald_count)])
	end
else
	function game:get_chaos_emeralds()
		return string.format("%3d", memory.readbyte(curr_data.S1_Emerald_count))
	end
end

if curr_data.TimeWarp_Direction == nil then
	function game:get_timewarp_icon()
		return nil
	end
else
	function game:get_timewarp_icon()
		local val = memory.readbytesigned(curr_data.TimeWarp_Direction)
		if val == -1 then
			return "warp-past"
		elseif val == 1 then
			return "warp-future"
		end
		return "blank"
	end
end

if curr_data.TimeWarp_Counter == nil then
	function game:warp_time_left()
		return 0
	end
else
	function game:warp_time_left()
		--	Time until warp
		local val = 210 - memory.readword(curr_data.TimeWarp_Counter)
		return (val >= 0 and val) or 0
	end
end

if curr_data.TimeWarp_Active == nil then
	function game:warp_active()
		--	If a warp has been initiated and
		return false
	end
else
	function game:warp_active()
		--	If a warp has been initiated
		return memory.readbyte(curr_data.TimeWarp_Active) == 1 and game:warp_time_left() > 0
	end
end

function game:warp_timer()
	return string.format("%5d", self:warp_time_left())
end

function game:camera_pos()
	return memory.readword(curr_data.Camera_X_pos), memory.readword(curr_data.Camera_Y_pos)
end

function game:level_bounds()
	return memory.readword(curr_data.Camera_Min_X_pos), memory.readword(curr_data.Camera_Max_X_pos),
		   memory.readword(curr_data.Camera_Min_Y_pos), memory.readword(curr_data.Camera_Max_Y_pos_now)
end

function game:min_camera_y()
	return memory.readword(curr_data.Camera_Min_Y_pos)
end

if rom:is_scheroes() then
	function game:extend_screen_bounds()
		return self:get_zone() == curr_data.sky_chase_zone
	end
elseif rom:is_keh() or rom:is_sonic3() or rom:is_sonick() then
	function game:extend_screen_bounds()
		return false
	end
else
	function game:extend_screen_bounds()
		return memory.readbyte(curr_data.Current_Boss_ID) == 0
	end
end

if rom:is_scheroes() or rom:is_sonic_cd() then
	function game:bounds_deltas()
		return 0x10, 0x130, 0x38, 0xE0
	end
else
	function game:bounds_deltas()
		return 0x10, 0x128, 0x40, 0xE0
	end
end

function game:get_camera()
	return string.format("%5d,%5d", game:camera_pos())
end

function game:get_camera_rect()
	local l, r, t, b = game:level_bounds()
	local x, y = game:camera_pos()
	return l - x, r - x, t - y, b - y
end

function game:init()
	if rom:is_scheroes() then
		self.shields = {shieldids.flame_shield, shieldids.lightning_shield, shieldids.bubble_shield, shieldids.normal_shield}
	elseif rom:is_sonic3() or rom:is_sonick() then
		self.shields = {shieldids.flame_shield, shieldids.lightning_shield, shieldids.bubble_shield}
	else
		self.shields = {shieldids.normal_shield}
	end
end

game:init()
