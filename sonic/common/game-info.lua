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
--	Global, character independent, game data.
--	Written by: Marzo Junior
--	Based on game disassemblies and Gens' RAM search.
-------------------------------------------------------------------------------

require("sonic/common/rom-check")
require("sonic/common/enums")

game = {
	curr_char    = nil,
	shields      = nil,
}

if rom:is_sonic_cd() then
	function game:get_time()
		return string.format("  %2d:%02d::%02d", memory.readbyte(0xff1515),
							 memory.readbyte(0xff1516), memory.readbyte(0xff1517))
	end
	
	function game:get_level_frames()
		return 0    --	Not used.
	end

	function game:get_lives()
		return string.format("x%2d", memory.readbyte(0xff1508))
	end
	
	function game:get_continues()
		return string.format("x%2d", memory.readbyte(0xff150e))
	end
	
	function game:get_score()
		return string.format("%11d", 10 * memory.readlong(0xff1518))
	end
else
	function game:get_time()
		return string.format("  %2d:%02d::%02d", memory.readbyte(0xfffe23),
							 memory.readbyte(0xfffe24), memory.readbyte(0xfffe25))
	end
	
	function game:get_level_frames()
		return memory.readbyte(0xfffe05)
	end

	function game:get_lives()
		return string.format("x%2d", memory.readbyte(0xfffe12))
	end
	
	function game:get_continues()
		return string.format("x%2d", memory.readbyte(0xfffe18))
	end
	
	function game:get_score()
		return string.format("%11d", 10 * memory.readlong(0xfffe26))
	end
end

function game:get_raw_rings()
	return memory.readword(rom.ring_offset)
end

if rom:is_sonic2() then
	function game:get_rings()
		return string.format("%3d (%d)", self:get_raw_rings(), memory.readwordsigned(0xffff40))
	end
else
	function game:get_rings()
		return string.format("%3d", self:get_raw_rings())
	end
end

--	Only gets called for S3K:
function game:get_super_emeralds()
	return string.format("%2d", memory.readbyte(0xffffb1))
end

if rom:is_sonic1() or rom:is_sonic_cd() then
	function game:super_status()
		return 0
	end

	function game:hyper_form()
		return false
	end
elseif rom:is_sonic2() then
    --	normal = 0; becoming super = 1; reverting to normal = 2; transformed = -1
	function game:super_status()
		return memory.readbytesigned(0xfff65f)
	end

    --	Super Sonic/Knuckles = 1, all others 0
	function game:hyper_form()
		return false
	end
else
    --	normal = 0; becoming super = 1; reverting to normal = 2; transformed = -1
	function game:super_status()
		return memory.readbytesigned(0xfff65f)
	end

    --	Super Sonic/Knuckles = 1, Hyper Sonic/Knuckles = -1, all others 0
	function game:hyper_form()
		return memory.readbytesigned(0xfffe19) == -1
	end
end

function game:super_active()
	return self:super_status() == -1
end

function game:cputime_time_left()
	return memory.readword(0xfff702)
end

function game:cputime_active()
	local cputime = self.cputime_time_left()
	return cputime ~= 0 and cputime < 599
end

function game:cputime_timer()
	return string.format("%5d", self.cputime_time_left())
end

function game:despawn_time_left()
	return memory.readword(0xfff704)
end

function game:despawn_active()
	return self:despawn_time_left() ~= 0
end

function game:despawn_timer()
	return string.format("%5d", 300 - self:despawn_time_left())
end

function game:respawn_time_left()
	return (64 - AND(memory.readword(0xfffe04),0x3f)) % 64
end

if rom:is_sonic2() then
	function game:respawn_active()
		if memory.readword(0xfff708) == 2 then
			return self:respawn_time_left() ~= 0
				   and memory.readbyte(0xffb000 + 0x2a) == 0
				   and AND(memory.readbyte(0xffb000 + 0x22),0xd2) == 0
		end
		return false
	end
elseif rom:is_sonic3() or rom:is_sonick() then
	function game:respawn_active()
		if memory.readword(0xfff708) == 2 then
			return self:respawn_time_left() ~= 0
				   and memory.readbytesigned(0xffb000 + 0x2e) >= 0
				   and AND(memory.readbyte(0xffb000 + 0x2a),0x80) == 0
		end
		return false
	end
else
	function game:respawn_active()
		return false
	end
end

function game:respawn_timer()
	return string.format("%5d", self:respawn_time_left())
end

function game:super_timer()
	return string.format("%5d", 61 * game:get_raw_rings() + memory.readword(0xfff670) - 60)
end

if rom:is_sonic_cd() then
	local function showing_hud()
		return AND(memory.readword(0xffd082),0x7ff) ~= 0x568 or
		       AND(memory.readword(0xffd0c2),0x7ff) ~= 0x568 or
		       AND(memory.readword(0xffd142),0x7ff) ~= 0x568
	end
	function game:disable_hud()
		--	RAM byte 0xff1522 indicates if Sonic is actually travelling in time;
		--	this is the time travel cutscene proper.
		if memory.readbyte(0xff1522) == 2 or showing_hud() then
			return true
		end
		return false
	end

	function game:in_score_tally()
		return memory.readlong(0xfff7d2) ~= 0
	end
	
	function game:get_zone()
		return memory.readbyte(0xff1506)
	end
	
	function game:get_act()
		return memory.readbyte(0xff1507)
	end
	
	function game:get_level()
		return memory.readword(0xff1506)
	end
elseif rom:is_sonic3() or rom:is_sonick() then
	function game:disable_hud()
		local mode = memory.readbyte(0xfff600)
		for _,m in ipairs({0,4,0x28,0x34,0x48,0x4c,0x8c}) do
			if mode == m then
				return true
			end
		end
		-- Endgame.
		return memory.readword(0xffef72) == 0xff00
	end
	
	function game:in_score_tally()
		return memory.readlong(0xfff7d2) ~= 0
	end
	
	function game:get_zone()
		return memory.readbyte(0xffee4e)
	end
	
	function game:get_act()
		return memory.readbyte(0xffee4f)
	end
	
	function game:get_level()
		return memory.readword(0xffee4e)
	end
else
	local boringmodes = (rom:is_sonic2() and
						{0,4,0x10,0x14,0x18,0x1c,0x20,0x24,0x28}) or
						{0,4,0x14,0x18,0x1c}
	function game:disable_hud()
		local mode = memory.readbyte(0xfff600)
		for _,m in ipairs(boringmodes) do
			if mode == m then
				return true
			end
		end
		if mode == 0x8c then
			local time = memory.readlong(0xfffe22)
			return not (time > 0 and time < 5)
		end
		return false
	end
	
	function game:get_zone()
		return memory.readbyte(0xfffe10)
	end
	
	function game:get_act()
		return memory.readbyte(0xfffe11)
	end
	
	function game:get_level()
		return memory.readword(0xfffe10)
	end
end

function game:get_char()
	return rom.get_char()
end


if rom:is_sonic_cd() then
	function game:in_score_tally()
		return memory.readlong(0xfff7d2) ~= 0
	end

	--	Emeralds are stored as a bit mask in SCD.
	local emerald_mask = {}
	--	This is probably overkill:
	for i = 0,255,1 do
		local count = 0
		local n = i
		while n ~= 0 do
			count = count + (n % 2)
			n = math.floor(n / 2)
		end
		emerald_mask[i] = count
	end

	function game:get_chaos_emeralds()
		return string.format("%3d", emerald_mask[memory.readbyte(0xff0f20)])
	end

	function game:get_timewarp_icon()
		local val = memory.readbytesigned(0xfff784)
		if val == -1 then
			return ui_icons.warp_past
		elseif val == 1 then
			return ui_icons.warp_future
		end
		return ui_icons.blank
	end

	function game:warp_time_left()
		--	Time until warp
		local val = 210 - memory.readword(0xfff786)
		return (val >= 0 and val) or 0
	end

	function game:warp_active()
		--	If a warp has been initiated
		return memory.readbyte(0xff1521) == 1 and game:warp_time_left() > 0
	end
else
	function game:in_score_tally()
		return memory.readbyte(0xfff600) == 0xc and memory.readlong(0xfff7d2) ~= 0
	end

	local emeralds = nil
	if rom:is_sonic1() then
		emeralds   = 0xfffe57
	elseif rom:is_sonic2() then
		emeralds   = 0xffffb1
	elseif rom:is_sonic3() or rom:is_sonick() then
		emeralds   = 0xffffb0
	end

	function game:get_chaos_emeralds()
		return string.format("%3d", memory.readbyte(emeralds))
	end

	function game:get_timewarp_icon()
		return nil
	end

	function game:warp_time_left()
		return 0
	end

	function game:warp_active()
		--	If a warp has been initiated and
		return false
	end
end

function game:warp_timer()
	return string.format("%5d", self:warp_time_left())
end


function game:init()
	if rom:is_sonic3() or rom:is_sonick() then
		self.shields = {shieldids.flame_shield, shieldids.lightning_shield, shieldids.bubble_shield}
	else
		self.shields = {shieldids.normal_shield}
	end
end

game:init()

