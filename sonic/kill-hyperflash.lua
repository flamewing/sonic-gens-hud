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
--	Disable Hyper Sonic's Hyper Launch flash.
--	Original by Upthorn, but caused desynchs.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

require("sonic/common/rom-check")

--	Only S3&K.
if not rom:is_sonic3k() then
	function toggle_hyperflash(enable)
	end
else
	function toggle_hyperflash(enable)
		--	Function to actually disable the flash.
		--[[
		--	This causes desynchs because it causes many instructions not to be executed in
		--	any of the frames during which the flash would be drawn.
		memory.register(0xfff666, function ()
			if game:hyper_form() then
				if memory.readbyte(0xfff666) ~= 0 then
					memory.writebyte(0xfff666, 0)
				end
			end
		end)
		]]
		--	This, however, doesn't seem to cause desynchs.
		local kill_fun = enable and function()
				--	Point the write destination away from the DMA memory-mapped vport and into
				--	an unused word-sized RAM address. The theory is that all instructions are
				--	still executed in each frame, but their effects are nullified.
				memory.setregister("a6", 0xffcfcc)
			end or nil
		--	Fix graphical glitch resulting from above fix.
		local fix_glitch = enable and function()
				local reg = memory.getregister("a0")
				if memory.readbyte(reg + 0xa) == 0 then
					memory.writeword(reg + 0xa, memory.readword(0xffb00a))
				end
			end or nil
		memory.registerexec(0x810, kill_fun)
		memory.registerexec(0x1a516, fix_glitch)
	end
end

if disable_hyperflash == nil then
	toggle_hyperflash(true)
end

