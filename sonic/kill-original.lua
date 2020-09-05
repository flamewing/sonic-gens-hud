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
--	Display hacks to remove the HUDs of the original games.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

require("sonic/common/rom-check")
require("headers/register")

--	Here we add code to push the original game HUDs *just* offscreen.
local exec_kill_fun    = function() end
local exec_restore_fun = function() end
local start_kill_fun   = function() end
local exit_restore_fun = function() end
if rom:is_sonic_cd() then
	--	In Sonic CD, the HUD is composed of 3 different parts that must be moved
	--	offscreen. We move each just enough that they are offscreen but still loaded.
	local addr = {[0xffd080] = 32, [0xffd0c0] = 96, [0xffd140] = 88}
	exec_kill_fun    = function()
			for ad, val in pairs(addr) do
				memory.registerwrite(ad + 8, 2,
					function(address, range)
						if memory.readbyte(ad) == 28 and
								memory.readwordsigned(ad + 8) ~= val then
							memory.writeword(ad + 8, val)
						end
					end)
			end
		end
	exec_restore_fun = function()
			for ad, val in pairs(addr) do
				memory.registerwrite(ad + 8, 2, nil)
			end
		end
	start_kill_fun   = function()
			for ad, val in pairs(addr) do
				if memory.readbyte(ad) == 28 then
					memory.writeword(ad + 8, val)
				end
			end
		end
	exit_restore_fun = function()
			for ad, val in pairs(addr) do
				if memory.readbyte(ad) == 28 then
					memory.registerwrite(ad + 8, 2, nil)
					memory.writeword(ad + 8, 144)
				end
			end
		end
	--	This was supposed to eliminate the 'past'/'future' signs, but it doesn't
	--	work in all levels. Back to the drawing board...
	--	memory.registerwrite(0xfff802, 4,
	--		function(address, range)
	--			local val = memory.readlong(0xfff802)
	--			if val == 0xd0185e2 or val == 0xd0185da then
	--				memory.writelong(0xfff802, 0x8010780)
	--			end
	--		end)
elseif rom:is_sonic1() then
	--	The HUD in Sonic 1 and hacks is a single object, which we push *just* offscreen so
	--	that it will still be loaded and drawn.
	local ad = 0xffd040
	local val = 32
	exec_kill_fun    = function()
			memory.registerwrite(ad + 8, 1,
				function(address, range)
					if memory.readbyte(ad) == 33 and
							memory.readwordsigned(ad + 8) ~= val then
						memory.writeword(ad + 8, val)
					end
				end)
		end
	exec_restore_fun = function()
			memory.registerwrite(ad + 8, 1, nil)
		end
	start_kill_fun   = function()
			if memory.readbyte(ad) == 33 then
				memory.writeword(ad + 8, val)
			end
		end
	exit_restore_fun = function()
			if memory.readbyte(ad) == 33 then
				memory.registerwrite(ad + 8, 2, nil)
				memory.writeword(ad + 8, 144)
			end
		end
elseif rom:is_sonic2() then
	--	The HUD in Sonic 2 is not an object, so the solutions for Sonic 1/CD do not work.
	--	We hook the execution of the HUD drawing function and rewrite the hud position
	--	by tampering with the regiter holding its y-coordinate just after it is set.
	local offset = rom.hud_code
	if offset ~= nil then
		exec_kill_fun    = function()
				memory.registerexec(offset,
					function(address, range)
						memory.setregister("d2", -512)
					end)
			end
		exec_restore_fun = function()
				memory.registerexec(offset, nil)
			end
		start_kill_fun   = function() end
		exit_restore_fun = function()
				memory.registerexec(offset, nil)
			end
	end
elseif rom:is_sonic3() or rom:is_sonick() then
	--	In Sonic 3, Sonic 3 & Knuckles and Sonic & Knuckles, the strategy is the same used
	--	for Sonic 2, but the register and executable location and range watched differ.
	local offset = rom.hud_code
	if offset ~= nil then
		exec_kill_fun    = function()
				memory.registerexec(offset,
					function(address, range)
						memory.setregister("d1", -512)
					end)
			end
		exec_restore_fun = function()
				memory.registerexec(offset, nil)
			end
		start_kill_fun   = function() end
		exit_restore_fun = function()
				memory.registerexec(offset, nil)
			end
	end
end

function toggle_disable_original_huds(enable)
	if enable then
		start_kill_fun()
		exec_kill_fun()
		callbacks.gens.registerstart:add(start_kill_fun)
		callbacks.gens.registerexit:add(exit_restore_fun)
	else
		exit_restore_fun()
		callbacks.gens.registerstart:remove(start_kill_fun)
		callbacks.gens.registerexit:remove(exit_restore_fun)
	end
end

if disable_original_huds == nil then
	toggle_disable_original_huds(true)
end

