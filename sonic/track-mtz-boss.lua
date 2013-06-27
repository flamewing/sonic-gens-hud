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
--	Tracks the Metropolis boss in Sonic 2.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Include all of the required files.
--------------------------------------------------------------------------------
require("sonic/common/rom-check")

if rom:is_sonic2() then
	local function Scan_orbs()
		local offset = 0xffb080
		local last   = 0xffd5ff
		while offset < last do
			local id = memory.readbyte(offset)
			if id == 0x53 then
				return offset,memory.readlong(offset + 0x34)
			end
			offset = offset + 0x40
		end
		return nil,nil
	end
	
	local function WatchMTZBoss()
		local orbptr,bossptr = Scan_orbs()
		if orbptr ~= nil and bossptr ~= 0 then
			local border = {0, 0, 0, 0}
			local fill   = {255, 255, 255, 255}
			gui.box(260, 40, 319, 50, {0, 0, 0, 192}, {0, 0, 127, 255})

			if memory.readbyte(bossptr+0x14) > 0 then
				local orbrout = memory.readbyte(orbptr+0x24)
				if orbrout >= 6 then
					gui.text(266, 42, "Get hit now", fill, border)
				else
					gui.text(266, 42, "Wait for it", fill, border)
				end
			else
				local norbs,counter,orbflag = memory.readbyte(bossptr+0x2C),memory.readbyte(bossptr+0x39),memory.readbyte(bossptr+0x3A)
				local orbypos = memory.readwordsigned(orbptr+0x0C)
				if counter >= 0x20 and norbs == 0 and orbflag == 0 and orbypos >= 0x4AC then
					gui.text(266, 42, "Hit boss now", fill, border)
				else
					gui.text(266, 42, "Wait for it", fill, border)
				end
			end
		end
	end
	
	savestate.registerload(WatchMTZBoss)
	gens.registerafter(WatchMTZBoss)
	gens.registerstart(WatchMTZBoss)
end

