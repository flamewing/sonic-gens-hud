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
--	Hack that disables super/hyper music.
--	Written by: Marzo Junior
--	Original by Upthorn
--------------------------------------------------------------------------------

require("sonic/common/rom-check")

if rom:is_sonic3() or rom:is_sonick() then
	function toggle_disable_s3k_super_music(enable)
		local zone, act = 0xffee4e, 0xffee4f
		local sfx, mus  = 0x2c, 0x9f
		local ad1, ad2, ad3 = 0xa01c0a, 0xa01c0b, 0xa01c22

		if enable then
			memory.register(ad1, 2, function()
				if memory.readbyte(ad2) == sfx then
					if memory.readbyte(ad1) ~= mus then
						memory.writebyte(ad2, 1 + memory.readbyte(act) + 2 * memory.readbyte(zone))
					else
						memory.writebyte(ad2, 0)
					end
					memory.writelong(ad3, 0x0)
				end
			end)
		else
			memory.register(ad1, 2, nil)
		end
	end
else
	function toggle_disable_s3k_super_music(enable)
	end
end

if disable_s3k_super_music == nil then
	--	Stand-alone guard.
	toggle_disable_s3k_super_music(true)
end

