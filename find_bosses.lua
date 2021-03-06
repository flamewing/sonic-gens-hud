#!/usr/bin/env lua

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

-- Edit these directories (after the 'or') to match your setup.
local romdir  = os.getenv("ROMDIR")  or os.getenv("HOME") .. "/.wine/drive_c/games/gens/ROMS/GenRen/"
local hackdir = os.getenv("HACKDIR") or os.getenv("HOME") .. "/.wine/drive_c/games/gens/ROMS/"
local cddir   = os.getenv("CDDIR")   or os.getenv("HOME") .. "/.wine/drive_c/games/gens/ROMS/"

local outfile = io.open("sonic/common/boss-tables.lua", "wb")
outfile:write("-------------------------------------------------------------------------------\n")
outfile:write("--	DO NOT EDIT THIS FILE, IT IS AUTOGENERATED!\n")
outfile:write("-------------------------------------------------------------------------------\n\n")
outfile:write("function make_boss_tables(boss_data)\n\treturn {\n")

for game = 1, 8 do
	local function make_unsigned_read(off, add)
		add = add or 0
		return string.format("make_unsigned_read(0x%02x, %2d)", off, add)
	end

	local function make_signed_read(off, add)
		add = add or 0
		return string.format("make_signed_read(0x%02x, %d)", off, add)
	end

	local files = nil
	local bosses = nil
	local conv = nil

	if game == 1 then
		files = {
			[01]={"s1wrev0" , romdir .. "Sonic The Hedgehog (W) (REV00) [!].bin"},
			[02]={"s1wrev1" , romdir .. "Sonic The Hedgehog (W) (REV01) [!].bin"},
			[03]={"s1tails" , hackdir .. "s1tails.bin"},
			[04]={"s1knux"  , hackdir .. "s1k.bin"},
			[05]={"s1amy"   , hackdir .. "Amy_In_Sonic_1_Rev_1.8.bin"},
			[06]={"s1charmy", hackdir .. "Charmy_In_Sonic_1_Rev_1.1.bin"},
			[07]={"s1bunnie", hackdir .. "Bunnie_Rabbot_In_Sonic_The_Hedgehog_Rev_1.0.bin"},
		}
		bosses = {
			[01]={0x00, 0x20, 0x11, 0x7c, 0x00, 0x08, 0x00, 0x21, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x2a, 0x4e, 0xbb, 0x10, 0x26, 0x43, 0xf9, 0x00, 0x01},
			[02]={0x51, 0xc9, 0xff,   -1, 0x43, 0xf8, 0xd0, 0x00, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00, 0x01},
			[03]={0x23, 0x48, 0x00, 0x34, 0x51, 0xc9, 0xff,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00, 0x01},
			[04]={0xd2, 0xfc, 0x00, 0x40, 0x51, 0xc9, 0xff, 0xee, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x30, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x00, 0x24, 0x43, 0xf9, 0x00, 0x01},
			[05]={0x23, 0x48, 0x00, 0x34, 0x51, 0xc9, 0xff,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00, 0x01},
			[06]={0x00, 0x21, 0x31, 0x7c, 0xff, 0xff, 0x00, 0x30, 0x70, 0x00, 0x10, 0x28, 0x00, 0x34, 0x30, 0x3b, 0x00, 0x0c, 0x4e, 0xbb, 0x00, 0x08, 0x4e, 0xf9, 0x00, 0x00},
			}
		conv = {
			[01]="s1.GHZ3",
			[02]="s1.LZ3",
			[03]="s1.MZ3",
			[04]="s1.SLZ3",
			[05]="s1.SYZ3",
			[06]="s1.FZ",
		}
	elseif game == 2 then
		files = {
			[01]={"s2"    , romdir .. "Sonic the Hedgehog 2 (W) [!].bin"},
			[02]={"s2knux", romdir .. "Sonic and Knuckles & Sonic 2 (W) [!].bin"},
			[03]={"s2amy" , hackdir .. "Amy_In_Sonic_2_Rev_1.5.bin"},
		}
		bosses = {
			[01]={0x13, 0x7c, 0x00, 0x04, 0x00, 0x24, 0x4e, 0x75, 0x61, 0x00, 0x00, 0x42, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x2a, 0x4e, 0xbb, 0x10, 0x26},
			[02]={0x13, 0x7c, 0x00, 0x00, 0x00, 0x1c, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0c, 0x00,   -1},
			[03]={0x00, 0x10, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0a, 0x00,   -1},
			[04]={0x00, 0x01, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0e, 0x00,   -1},
			[05]={0x00, 0x03, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0e, 0x00,   -1},
			[06]={0x00, 0x02, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x4a, 0x38, 0xf7, 0x3f, 0x67,   -1, 0x10, 0x38, 0xfe, 0x0f, 0x02, 0x00, 0x00, 0x1f, 0x66,   -1, 0x10, 0x3c},
			[07]={0x00, 0x01, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x14, 0x00,   -1},
			[08]={0x11, 0x7c, 0x00, 0x40, 0x00, 0x0e, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0a, 0x00, 0x84},
			[09]={  -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x10, 0x38, 0xfe, 0x0f, 0x02, 0x00, 0x00, 0x1f, 0x66,   -1, 0x70, 0xdc,   -1,   -1,   -1,   -1,   -1,   -1},
			[10]={0x00, 0x01, 0x00, 0x22, 0x60, 0x00, 0x01,   -1, 0x61, 0x00, 0x04,   -1, 0x61, 0x00,   -1,   -1, 0x53, 0x28, 0x00, 0x2a, 0x67,   -1, 0x0c, 0x28, 0x00, 0x32},
			[11]={0x06, 0x06, 0x10, 0x06, 0x00, 0x06, 0x10, 0x1e, 0x61, 0x00,   -1,   -1, 0x61, 0x00, 0x04,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00,   -1},
			[12]={0x00, 0x90, 0x11, 0x40, 0x00, 0x24, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x0a, 0x4e, 0xbb, 0x10, 0x06, 0x60, 0x00, 0x07,   -1},
			[13]={0x11, 0x68, 0x00, 0x28, 0x00, 0x24, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00,   -1, 0x4e, 0xbb, 0x10,   -1,   -1,   -1,   -1,   -1},
			}
		conv = {
			[01]="s2.CPZ2",
			[02]="s2.EHZ2",
			[03]="s2.HTZ2",
			[04]="s2.ARZ2",
			[05]="s2.MCZ2",
			[06]="s2.CNZ2",
			[07]="s2.MTZ3",
			[08]="s2.OOZ2",
			[09]="s2.DEZ1",
			[10]="s2.DEZ1",
			[11]="s2.DEZ1",
			[12]="s2.WFZ",
			[13]="s2.DEZ2",
		}
	elseif game == 3 then
		files = {
			[1] = {"s2rob", hackdir .. "Robotnik's Revenge v1.bin"},
		}
		bosses = {
			[01]={0x00, 0x20, 0x11, 0x7c, 0x00, 0x08, 0x00, 0x21, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x2a, 0x4e, 0xbb, 0x10, 0x26, 0x43, 0xf9, 0x00,   -1},
			[02]={0x23, 0x48, 0x00, 0x34, 0x51, 0xc9, 0xff,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00,   -1},
			[03]={0x23, 0x48, 0x00, 0x34, 0x51, 0xc9, 0xff,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00,   -1},
			[04]={0x51, 0xc9, 0xff,   -1, 0x43, 0xf8, 0xb0, 0x00, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00,   -1},
			[05]={0xd2, 0xfc, 0x00, 0x40, 0x51, 0xc9, 0xff, 0xee, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x30, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x00, 0x24, 0x43, 0xf9, 0x00,   -1},
			[06]={0x13, 0x7c, 0x00, 0x04, 0x00, 0x24, 0x4e, 0x75, 0x61, 0x00, 0x00, 0x42, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x2a, 0x4e, 0xbb, 0x10, 0x26},
			[07]={0x13, 0x7c, 0x00, 0x00, 0x00, 0x1c, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0c, 0x00,   -1},
			[08]={0x00, 0x10, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0a, 0x00,   -1},
			[09]={0x00, 0x01, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0e, 0x00,   -1},
			[10]={0x00, 0x03, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0e, 0x00,   -1},
			[11]={0x00, 0x02, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x4a, 0x38, 0xf7, 0x3f, 0x67,   -1, 0x10, 0x38, 0xfe, 0x0f, 0x02, 0x00, 0x00, 0x1f, 0x66,   -1, 0x10, 0x3c},
			[12]={0x00, 0x01, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x14, 0x00,   -1},
			[13]={0x11, 0x7c, 0x00, 0x40, 0x00, 0x0e, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0a, 0x00, 0x84},
			[14]={  -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x10, 0x38, 0xfe, 0x0f, 0x02, 0x00, 0x00, 0x1f, 0x66,   -1, 0x70, 0xdc,   -1,   -1,   -1,   -1,   -1,   -1},
			[15]={0x00, 0x01, 0x00, 0x22, 0x60, 0x00, 0x01,   -1, 0x61, 0x00, 0x04,   -1, 0x61, 0x00,   -1,   -1, 0x53, 0x28, 0x00, 0x2a, 0x67,   -1, 0x0c, 0x28, 0x00, 0x32},
			[16]={0x06, 0x06, 0x10, 0x06, 0x00, 0x06, 0x10, 0x1e, 0x61, 0x00,   -1,   -1, 0x61, 0x00, 0x04,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00,   -1},
			[17]={0x00, 0x90, 0x11, 0x40, 0x00, 0x24, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x0a, 0x4e, 0xbb, 0x10, 0x06, 0x60, 0x00, 0x07,   -1},
			[18]={0x11, 0x68, 0x00, 0x28, 0x00, 0x24, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00,   -1, 0x4e, 0xbb, 0x10,   -1,   -1,   -1,   -1,   -1},
			[19]={0x00, 0x21, 0x31, 0x7c, 0xff, 0xff, 0x00, 0x30, 0x70, 0x00, 0x10, 0x28, 0x00, 0x34, 0x30, 0x3b, 0x00, 0x0c, 0x4e, 0xbb, 0x00, 0x08, 0x4e, 0xf9, 0x00, 0x01},
			}
		conv = {
			[01]="s2rob.GHZ3",
			[02]="s2rob.MZ3",
			[03]="s2rob.SYZ3",
			[04]="s2rob.LZ3",
			[05]="s2rob.SLZ3",
			[06]="s2.CPZ2",
			[07]="s2.EHZ2",
			[08]="s2.HTZ2",
			[09]="s2.ARZ2",
			[10]="s2.MCZ2",
			[11]="s2.CNZ2",
			[12]="s2.MTZ3",
			[13]="s2.OOZ2",
			[14]="s2.DEZ1",
			[15]="s2.DEZ1",
			[16]="s2.DEZ1",
			[17]="s2.WFZ",
			[18]="s2.DEZ2",
			[19]="s2rob.FZ",
		}
	elseif game == 4 then
		files = {
			[01]={"s1and2", hackdir .. "Sonic 1 and 2.bin"},
		}
		bosses = {
			[01]={0x13, 0x7c, 0x00, 0x04, 0x00, 0x24, 0x4e, 0x75, 0x61, 0x00, 0x00, 0x42, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x2a, 0x4e, 0xbb, 0x10, 0x26},
			[02]={0x13, 0x7c, 0x00, 0x00, 0x00, 0x1c, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0c, 0x00,   -1},
			[03]={0x00, 0x10, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0a, 0x00,   -1},
			[04]={0x00, 0x01, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0e, 0x00,   -1},
			[05]={0x00, 0x03, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0e, 0x00,   -1},
			[06]={0x00, 0x02, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x4a, 0x38, 0xf7, 0x3f, 0x67,   -1, 0x10, 0x38, 0xfe, 0x0f, 0x02, 0x00, 0x00, 0x1f, 0x66,   -1, 0x10, 0x3c},
			[07]={0x00, 0x01, 0x14, 0xfc, 0x00, 0x00, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x14, 0x00,   -1},
			[08]={0x11, 0x7c, 0x00, 0x40, 0x00, 0x0e, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x26, 0x32, 0x3b, 0x00, 0x06, 0x4e, 0xfb, 0x10, 0x02, 0x00, 0x0a, 0x00, 0x84},
			[09]={  -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x10, 0x38, 0xfe, 0x0f, 0x02, 0x00, 0x00, 0x1f, 0x66,   -1, 0x70, 0xdc,   -1,   -1,   -1,   -1,   -1,   -1},
			[10]={0x00, 0x01, 0x00, 0x22, 0x60, 0x00, 0x01,   -1, 0x61, 0x00, 0x04,   -1, 0x61, 0x00,   -1,   -1, 0x53, 0x28, 0x00, 0x2a, 0x67,   -1, 0x0c, 0x28, 0x00, 0x32},
			[11]={0x06, 0x06, 0x10, 0x06, 0x00, 0x06, 0x10, 0x1e, 0x61, 0x00,   -1,   -1, 0x61, 0x00, 0x04,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00,   -1},
			[12]={0x00, 0x90, 0x11, 0x40, 0x00, 0x24, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x0a, 0x4e, 0xbb, 0x10, 0x06, 0x60, 0x00, 0x07,   -1},
			[13]={0x11, 0x68, 0x00, 0x28, 0x00, 0x24, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00,   -1, 0x4e, 0xbb, 0x10,   -1,   -1,   -1,   -1,   -1},
			[14]={0x00, 0x20, 0x11, 0x7c, 0x00, 0x08, 0x00, 0x21, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x2a, 0x4e, 0xbb, 0x10, 0x26, 0x43, 0xf9, 0x00,   -1},
			[15]={0x23, 0x48, 0x00, 0x34, 0x51, 0xc9, 0xff,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00,   -1},
			[16]={0x23, 0x48, 0x00, 0x34, 0x51, 0xc9, 0xff,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00,   -1},
			[17]={0x51, 0xc9, 0xff,   -1, 0x43, 0xf8, 0xb0, 0x00, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x32, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x10, 0x24, 0x43, 0xf9, 0x00,   -1},
			[18]={0xd2, 0xfc, 0x00, 0x40, 0x51, 0xc9, 0xff, 0xee, 0x70, 0x00, 0x10, 0x28, 0x00, 0x25, 0x30, 0x3b, 0x00, 0x28, 0x4e, 0xbb, 0x00, 0x24, 0x43, 0xf9, 0x00,   -1},
			[19]={0x00, 0x21, 0x31, 0x7c, 0xff, 0xff, 0x00, 0x30, 0x70, 0x00, 0x10, 0x28, 0x00, 0x34, 0x30, 0x3b, 0x00, 0x0c, 0x4e, 0xbb, 0x00, 0x08, 0x4e, 0xf9, 0x00, 0x01},
			}
		conv = {
			[01]="s2.CPZ2",
			[02]="s2.EHZ2",
			[03]="s2.HTZ2",
			[04]="s2.ARZ2",
			[05]="s2.MCZ2",
			[06]="s2.CNZ2",
			[07]="s2.MTZ3",
			[08]="s2.OOZ2",
			[09]="s2.DEZ1",
			[10]="s2.DEZ1",
			[11]="s2.DEZ1",
			[12]="s2.WFZ",
			[13]="s2.DEZ2",
			[14]="s1.GHZ3",
			[15]="s1.MZ3",
			[16]="s1.SYZ3",
			[17]="s1.LZ3",
			[18]="s1.SLZ3",
			[19]="s1.FZ",
		}
	elseif game == 5 then
		files = {
			[01]={"sk"    , romdir .. "Sonic and Knuckles & Sonic 3 (W) [!].bin"},
			[02]={"s3kamy", hackdir .. "Sonic_3_And_Amy_Rev_1.4.bin"},
			}
		bosses = {
			[01]={0xfa, 0xb8, 0x4e, 0xf9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x30, 0x28, 0x00, 0x44},
			[02]={  -1,   -1, 0x4e, 0xf9,   -1,   -1,   -1,   -1, 0x10, 0x38, 0xfa, 0xb8, 0x02, 0x00, 0x00, 0x0c,   -1,   -1, 0x00, 0x0c,   -1,   -1, 0x20, 0xbc,   -1,   -1},
			[03]={0xff, 0xf8, 0x14, 0x0c, 0x00, 0x16, 0xff, 0xf0, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x60, 0x00,   -1,   -1},
			[04]={0x00, 0x00, 0x00, 0x10, 0x00, 0x08, 0x00, 0x08, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x60, 0x00,   -1,   -1},
			[05]={0x11, 0xfc, 0x00, 0x19, 0xff, 0x91, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x08, 0x28, 0x00, 0x06},
			[06]={0x11, 0xfc, 0x00, 0x2e, 0xff, 0x91, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[07]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[08]={0x11, 0xfc, 0x00, 0x19, 0xff, 0x91, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[09]={  -1,   -1,   -1,   -1, 0x4e, 0x75, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[10]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[11]={0x22, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[12]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[13]={0x00, 0x2e, 0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[14]={0xff, 0xee, 0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[15]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[16]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[17]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[18]={0x00, 0x02, 0x00, 0x02, 0x04, 0x02, 0x02, 0x04, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xf9,   -1,   -1},
			[19]={0x0a, 0xaa, 0x08, 0x64, 0x06, 0x42, 0x00, 0x44, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[20]={0xff, 0xee, 0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[21]={0xff, 0xf8, 0xf4, 0x07, 0x00, 0x00, 0xff, 0xf8, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xb9,   -1,   -1},
			[22]={0x06, 0x44, 0x04, 0x22, 0x00, 0x00, 0x00, 0x44, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x30, 0x38, 0xee, 0xbc},
			[23]={0x09, 0xaa, 0x4e, 0xf9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x30, 0x38, 0xee, 0xbc},
			[24]={0x00, 0x01, 0xf4, 0x05, 0x00, 0x09, 0xff, 0xf4, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x31, 0xe8, 0x00, 0x10},
			[25]={0x08, 0xfa, 0x61, 0x00,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xf9,   -1,   -1},
			[26]={0x42, 0x28, 0x00, 0x39, 0x60, 0x00,   -1,   -1, 0x32, 0x68, 0x00, 0x44, 0x08, 0x29, 0x00, 0x02, 0x00, 0x38, 0x67, 0x06, 0x20, 0xbc,   -1,   -1,   -1,   -1},
			[27]={0x11, 0xfc, 0x00, 0x19, 0xff, 0x91, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[28]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[29]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xfb,   -1,   -1, 0x00, 0x04, 0x00, 0xba},
			[30]={0x02, 0x22, 0x0a, 0x88, 0x00, 0x00, 0x00, 0x44, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x49, 0xfa,   -1,   -1},
			[31]={0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x49, 0xfa,   -1,   -1},
			[32]={0x4e, 0xba,   -1,   -1, 0x4e, 0xfa,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x70, 0x14, 0x4e, 0xfa},
			[33]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[34]={  -1,   -1, 0x4e, 0xf9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xb9,   -1,   -1},
			[35]={  -1,   -1, 0x11, 0x7c, 0x00, 0x16, 0x00, 0x28, 0x4a, 0x38, 0xfa, 0xa9, 0x6a, 0x14, 0x61, 0x00,   -1,   -1, 0x61, 0x00,   -1,   -1, 0x4e, 0xb9,   -1,   -1},
			[36]={  -1,   -1, 0x11, 0x7c, 0x00, 0x03, 0x00, 0x29, 0x32, 0x68, 0x00, 0x46, 0x11, 0x69, 0x00, 0x22, 0x00, 0x22, 0x08, 0x29, 0x00, 0x01, 0x00, 0x38, 0x66, 0x0e},
			[37]={0x20, 0x4a, 0x4e, 0xf9,   -1,   -1,   -1,   -1, 0x30, 0x38, 0xfa, 0xae, 0x91, 0x68, 0x00, 0x10, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1},
			[38]={0xd1, 0x68, 0x00, 0x10, 0x4e, 0xfa,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xf9,   -1,   -1},
			[39]={0x7f, 0xfc, 0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[40]={0x00, 0x32, 0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x61, 0x00,   -1,   -1},
			[41]={0x43, 0xfa, 0x00, 0x36, 0x4e, 0xba,   -1,   -1, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xb9,   -1,   -1},
			[42]={0x04, 0x00, 0x07, 0x80, 0x04, 0xa0, 0x07, 0x90, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b,   -1,   -1, 0x4e, 0xbb,   -1,   -1, 0x4e, 0xb9,   -1,   -1},
			}
		conv = {
			[01]="s3k.knux",
			[02]="s3k.normal",
			[03]="s3k.normal",
			[04]="s3k.normal",
			[05]="s3k.normal",
			[06]="s3k.normal",
			[07]="s3k.normal",
			[08]="s3k.normal",
			[09]="s3k.normal",
			[10]="s3k.normal",
			[11]="s3k.CNZ1",
			[12]="s3k.normal",
			[13]="s3k.normal",
			[14]="s3k.normal",
			[15]="s3k.normal",
			[16]="s3k.normal",
			[17]="s3k.normal",
			[18]="s3k.normal",
			[19]="s3k.normal",
			[20]="s3k.normal",
			[21]="s3k.normal",
			[22]="s3k.normal",
			[23]="s3k.MHZ2",
			[24]="s3k.normal",
			[25]="s3k.normal",
			[26]="s3k.normal",
			[27]="s3k.normal",
			[28]="s3k.mecha1",
			[29]="s3k.mecha2",
			[30]="s3k.mecha1",
			[31]="s3k.mecha1",
			[32]="s3k.DEZ1",
			[33]="s3k.normal",
			[34]="s3k.normal",
			[35]="s3k.normal",
			[36]="s3k.normal",
			[37]="s3k.DDZ",
			[38]="s3k.DDZ",
			[39]="s3k.normal",
			[40]="s3k.normal",
			[41]="s3k.normal",
			[42]="s3k.normal",
		}
	elseif game == 6 then
		files = {
			[01]={"s3"    , romdir .. "Sonic the Hedgehog 3 (U) [!].bin"},
			}
		bosses = {
			[01]={0x63, 0x82, 0x1e, 0x00, 0x05, 0x00, 0x01, 0xfc, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0a, 0x4e, 0xbb, 0x10, 0x06, 0x60, 0x00,   -1,   -1},
			[02]={0x00, 0x00, 0x00, 0x10, 0x00, 0x08, 0x00, 0x08, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0a, 0x4e, 0xbb, 0x10, 0x06, 0x60, 0x00,   -1,   -1},
			[03]={0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x16, 0x4e, 0xbb, 0x10, 0x12, 0x08, 0x28, 0x00, 0x06},
			[04]={0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x10, 0x4e, 0xbb, 0x10, 0x0c, 0x61, 0x00,   -1,   -1},
			[05]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x10, 0x4e, 0xbb, 0x10, 0x0c, 0x61, 0x00,   -1,   -1},
			[06]={0x4e, 0xb9,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x10, 0x4e, 0xbb, 0x10, 0x0c, 0x61, 0x00,   -1,   -1},
			[07]={0x92, 0x16, 0x4e, 0xf9, 0x00, 0x05, 0x30, 0x08, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x10, 0x4e, 0xbb, 0x10, 0x0c, 0x61, 0x00, 0x10, 0xf6},
			[08]={0x22, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x1e, 0x4e, 0xbb, 0x10, 0x1a, 0x61, 0x00,   -1,   -1},
			[09]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x12, 0x4e, 0xbb, 0x10, 0x0e, 0x61, 0x00,   -1,   -1},
			[10]={0x20, 0xbc,   -1,   -1,   -1,   -1, 0x4e, 0x75, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			[11]={0xe4, 0x00, 0x34, 0x4e, 0x75, 0x4e, 0xba, 0x41, 0xa2, 0x53, 0x68, 0x00, 0x44, 0x6a, 0x10, 0x44, 0x68, 0x00, 0x18, 0x08, 0x68, 0x00, 0x00, 0x00, 0x04, 0x31},
			[12]={0x00, 0x02, 0x00, 0x02, 0x04, 0x02, 0x02, 0x04, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			[13]={0x0a, 0xaa, 0x08, 0x64, 0x06, 0x42, 0x00, 0x44, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			[14]={0x00, 0x2c, 0x4e, 0xb9, 0x00, 0x05, 0x41, 0x7c, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			[15]={0x0e, 0xaa, 0x0a, 0x64, 0x06, 0x42, 0x00, 0x44, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x10, 0x4e, 0xbb, 0x10, 0x0c, 0x4e, 0xb9,   -1,   -1},
			[16]={0x7f, 0xfc, 0x4e, 0xb9, 0x00, 0x05, 0x3f, 0xd8, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			[17]={0x00, 0x32, 0x4e, 0xb9, 0x00, 0x05, 0x41, 0x7c, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			[18]={0x43, 0xfa, 0x00, 0x2e, 0x4e, 0xba, 0x9e, 0xb6, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x10, 0x4e, 0xbb, 0x10, 0x0c, 0x4e, 0xb9,   -1,   -1},
			[19]={0x00, 0x32, 0x4e, 0xb9, 0x00, 0x08, 0x5c, 0x36, 0x70, 0x00, 0x10, 0x28, 0x00, 0x05, 0x32, 0x3b, 0x00, 0x0e, 0x4e, 0xbb, 0x10, 0x0a, 0x61, 0x00,   -1,   -1},
			}
		conv = {
			[01]="s3k.normal",
			[02]="s3k.normal",
			[03]="s3k.normal",
			[04]="s3k.normal",
			[05]="s3k.normal",
			[06]="s3k.normal",
			[07]="s3k.normal",
			[08]="s3k.CNZ1",
			[09]="s3k.normal",
			[10]="s3k.normal",
			[11]="s3k.normal",
			[12]="s3k.normal",
			[13]="s3k.normal",
			[14]="s3k.normal",
			[15]="s3k.normal",
			[16]="s3k.normal",
			[17]="s3k.normal",
			[18]="s3k.normal",
			[19]="s3k.normal",
		}
	elseif game == 7 then
		files = {
			[01]={"scd"    , cddir .. "Sonic the Hedgehog CD (NTSC-U) [MK-4407].bin"},
			}
		bosses = {
			}
		conv = {
		}
	elseif game == 8 then
		files = {
			[01]={"s2boom"    , hackdir .. "SBOOM.BIN"},
			}
		bosses = {
			}
		conv = {
		}
	end

	for n = 1, #files do
		local fid, filename = files[n][1], files[n][2]
		local file = io.open(filename, "rb")
		if file == nil then
			print("Warning: File '" .. filename .. "' was not found, and is being ignored.")
			print("Boss HUDs will not be displayed for this game/hack unless you rerun this script with the missing file present.\n")
			outfile:write(string.format("\t\t%s = {},\n", fid))
		else
			local bytes = file:read("*a")

			local curr = 1
			local start = 1
			if game == 2 and fid == "s2knux" then
				start = 3 * 1024 * 1024
			end
			if #bosses > 0 then
				outfile:write(string.format("\t\t%s = {\n", fid))
				for i = start, #bytes do
					local boss = bosses[curr]
					if boss[1] < 0 or bytes:byte(i) == boss[1] then
						local found = true
						for j = 2, #boss do
							if boss[j] >= 0 and bytes:byte(i + j - 1) ~= boss[j] then
								found = false
								break
							end
						end
						if found then
							outfile:write(string.format("\t\t\t[0x%06x] = boss_data.%s,\t-- %02d\n", i + 7, conv[curr], curr))
							i = i + #boss - 1
							if curr == #bosses then
								break
							end
							curr = curr + 1
						end
					end
				end
				outfile:write("\t\t},\n")
			else
				outfile:write(string.format("\t\t%s = {},\n", fid))
			end
		end
	end
end

outfile:write("\t}\nend\n")


