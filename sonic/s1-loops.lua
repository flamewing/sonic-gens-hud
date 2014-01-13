--------------------------------------------------------------------------------
--	This file is part of the Sonic 1 movie resyncher.
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

enable_predictor = true

require("sonic/common/rom-check")
require("headers/widgets")
require("sonic/common/game-info")
require("sonic/common/jump-predictor")

if not gens.emulating() then
	error("ROM must be loaded first.")
elseif not rom:is_sonic1() then
	error("Error: This script is for Sonic 1 and compatible hacks only.", 0)
elseif not movie.playing() and not movie.recording() then
	error("Error: This script can only be used during movies.", 0)
end

local v_lvllayout = 0xFFFFA400
local v_256loop1  = 0xFFFFF7AC	-- 256x256 level tile which contains a loop (GHZ/SLZ)
local v_256loop2  = 0xFFFFF7AD	-- 256x256 level tile which contains a loop (GHZ/SLZ)
local v_256roll1  = 0xFFFFF7AE	-- 256x256 level tile which contains a roll tunnel (GHZ)
local v_256roll2  = 0xFFFFF7AF	-- 256x256 level tile which contains a roll tunnel (GHZ)

local function has_loops()
	local lvl = game:get_zone()
	return lvl == 0 or lvl == 3	-- GHZ or SLZ
end

local function get_chunk()
	local x = AND(memory.readbyte(0xFFFFD008), 0x7F)
	local y = AND(SHIFT(memory.readword(0xFFFFD00C), 1), 0x380)
	return memory.readbyte(v_lvllayout + x + y)
end

local function in_roll()
	if not has_loops() then
		return false
	end
	local roll1,roll2 = memory.readbyte(v_256roll1),memory.readbyte(v_256roll2)
	local chunk = get_chunk()
	return chunk == roll1 or chunk == roll2
end

local function in_loop()
	if not has_loops() then
		return false
	end
	local loop1,loop2 = memory.readbyte(v_256loop1),memory.readbyte(v_256loop2)
	local chunk = get_chunk()
	return chunk == loop1 or chunk == loop2
end

local function looptype()
	local loop1,loop2 = memory.readbyte(v_256loop1),memory.readbyte(v_256loop2)
	local chunk = get_chunk()
	if chunk == loop1 then
		return "Air chk: N"
	elseif chunk == loop2 then
		return "Air chk: Y"
	else
		return ""
	end
end

local function lowxpos()
	return string.format("Xoff : 0x%02X", memory.readbyte(0xFFFFD009))
end

local function angle()
	return string.format("Angle: 0x%02X", memory.readbyte(0xFFFFD026))
end

local function get_plane()
	local loop1,loop2 = memory.readbyte(v_256loop1),memory.readbyte(v_256loop2)
	local chunk = get_chunk()
	if chunk == loop2 then
		if AND(memory.readbyte(0xFFFFD022),64) ~= 0 then
			return "high plane"
		end
	elseif chunk ~= loop1 then
		return "high plane"
	end
	local lowx  = memory.readbyte(0xFFFFD009)
	local angle = memory.readbyte(0xFFFFD026)
	local plane = AND(memory.readbyte(0xFFFFD001),64)
	if lowx < 0x2C then
		return "high plane"
	elseif lowx >= 0xE0 then
		return "low  plane"
	elseif plane == 0 then
		if angle == 0 or angle > 0x80 then
			return "high plane"
		else
			return "low  plane"
		end
	elseif angle <= 0x80 then
		return "low  plane"
	else
		return "high plane"
	end
end

local loophud = Conditional_widget:new(259, 30, true, in_loop)

local loopframe = Frame_widget:new(0, 0, 60, 40)
loopframe:add(Text_widget:new(0, 0, looptype ), 3, 2)
loopframe:add(Text_widget:new(0, 0, lowxpos  ), 3, 10)
loopframe:add(Text_widget:new(0, 0, angle    ), 3, 18)
loopframe:add(Text_widget:new(0, 0, get_plane), 3, 24)

loophud:add(loopframe, 0, 0)

gui.register(function ()
	loophud:draw()
end)

