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

local function Create_HUD(click_fun, obj, text_fun, icon, x, y)
	local cont = Container_widget:new(x, y, true)
	local hud  = Clickable_widget:new(0, 0, 68, 16, click_fun, obj)
	hud:add_status_icon(1, 1, icon, text_fun)
	cont:add(hud, 0, 0)
	return cont
end

local function get_filename(level)
	local filename = romid
	return string.format("./movies/%s_%04x.input", filename, level)
end

local function get_level()
	return ((rom:is_sonic3() or rom:is_sonick()) and game:get_zone()) or game:get_level()
end

local function fast_forward(cond)
	local iter = 0
	while cond() == true do
		sound.clear()
		for n = 1,2 do
			joypad.write(n, {A=false, C=false, up=false, right=false, left=false, Y=false, X=false, Z=false, start=false, mode=false, down=false, B=false})
		end
		gens.emulateframeinvisible()
		iter = iter + 1
		if iter == 60 then
			iter = 0
			gens.redraw()
			gui.drawtext(120, 100, "Fast-forwarding to start of level...")
		end

		if iter == 30 then
			gens.wait()
		end
	end
end

local state = {[0] = savestate.create(), [1] = savestate.create()}
local last = 0

local function save_level(self)
	savestate.save(state[0])
	savestate.save(state[1])
	fast_forward(function()
		return not prediction_wanted()
	end)
	fast_forward(function()
		last = (last + 1) % 2
		savestate.save(state[last])
		return memory.readbyte(0xfff600) ~= 0xc
	end)
	savestate.load(state[last])
	if memory.readbyte(0xfff600) == 0xc then
		savestate.load(state[(last + 1) % 2])
	end
	local iter = 0
	local level = get_level()
	local file = io.open(get_filename(level), "w+")
	file:write("joypads = {\n")
	while movie.playing() and level == get_level() do
		sound.clear()
		repeat
			gens.emulateframeinvisible()
		until not gens.lagged()
		file:write(string.format("\t{[%d] = %s,\n\t [%d] = %s},\n", 1, tostring(joypad.read(1)), 2, tostring(joypad.read(2))))
		iter = iter + 1
		if iter == 60 then
			iter = 0
			gens.redraw()
			gui.drawtext(120, 100, "Saving level...")
		end

		if iter == 30 then
			gens.wait()
		end
	end
	file:write("\t}\n")
	file:close()
	gens.redraw()
	gui.drawtext(120, 100, "Done.")
end

local function paste_level(self)
	if not movie.recording() then
		print("Error: cannot paste in read-only mode.")
		return
	end
	savestate.save(state[0])
	savestate.save(state[1])
	fast_forward(function()
		return not prediction_wanted()
	end)
	fast_forward(function()
		last = (last + 1) % 2
		savestate.save(state[last])
		return memory.readbyte(0xfff600) ~= 0xc
	end)
	savestate.load(state[last])
	if memory.readbyte(0xfff600) == 0xc then
		savestate.load(state[(last + 1) % 2])
	end
	
	dofile(get_filename(get_level()))
	
	local level = get_level()
	local iter = 0
	local count = #joypads
	for i,m in pairs(joypads) do
		if level ~= get_level() then
			break
		end
		sound.clear()
		repeat
			for n = 1,2 do
				joypad.write(n, m[n])
			end
			gens.emulateframeinvisible()
		until not gens.lagged()
		iter = iter + 1
		if iter == 60 then
			iter = 0
			gens.redraw()
			gui.box(109, 98, 109 + 102, 98 + 10, {0, 0, 0, 128}, {255, 255, 255, 255})
			gui.box(110, 99, 110 + 100 * (i/count), 98 + 9, {0, 0, 128, 255}, {0, 0, 128, 255})
			gui.drawtext(130, 100, "Pasting level...")
		end

		if iter == 30 then
			gens.wait()
		end
	end
	fast_forward(function()
		return level == get_level()
	end)
	gens.redraw()
	gui.drawtext(120, 100, "Done.")
end

local copy_icon  = Create_HUD(save_level , nil, "Save level" , "level-copy" , 0,  0)
local paste_icon = Create_HUD(paste_level, nil, "Paste level", "level-paste", 0, 18)

gui.register(function ()
	update_input()
	copy_icon:draw()
	paste_icon:draw()
end)

