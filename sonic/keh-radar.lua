--------------------------------------------------------------------------------
--	This file is part of the Sonic & Knuckles and Sonic 3 & Knuckles cheat pack.
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

require("sonic/common/rom-check")
require("headers/lua-oo")
require("headers/widgets")
require("headers/ui-icons")
require("sonic/common/game-info")

if not gens.emulating() then
	error("ROM must be loaded first.")
elseif not rom:is_keh() then
	error("This script is for Knuckles' Emerald Hunt only.")
end

-- Emeralds
local emerald1 = 0xFFCC58
local emerald2 = 0xFFCC5E
local emerald3 = 0xFFCC64
local emerald4 = 0xFFCC6A
local emerald5 = 0xFFCC70

function is_emerald_showing(offset)
	local romoff = memory.readlong(offset)
	return memory.readlong(offset) ~= 0 and memory.readword(offset+4) ~= 0
end

function emerald_pos(offset)
	local romoff = memory.readlong(offset)
	if romoff ~= 0 then
		local ramoff = memory.readword(offset+4)
		local x, y
		if ramoff ~= 0 then
			ramoff = OR(ramoff, 0xFF0000)
			x, y = memory.readword(ramoff+0x8), memory.readword(ramoff+0xC)
		else
			x, y = memory.readword(romoff), AND(memory.readword(romoff+0x2), 0xFFF)
		end
		return x, y
	end
end

function emerald_pos_str(offset)
	return string.format("%5d, %5d", emerald_pos(offset))
end

Emerald_widget = class{
	offset = nil,
	get_xy = nil,
	is_active = nil,
}:extends(Container_widget)

function Emerald_widget:move(x, y)
	local dx = x - self.x
	local dy = y - self.y
	if dx == 0 and dy == 0 then
		return
	end
	self.x = x
	self.y = y
	if self.toggle then
		self.toggle:move(self.toggle.x + dx, self.toggle.y + dy)
	end
	for _,m in pairs(self.children) do
		m:move(m.x + dx, m.y + dy)
	end
end

function Emerald_widget:draw()
	self.active = self.is_active(self.offset)
	if self.active then
		for _,m in pairs(self.children) do
			m:draw()
		end
		if self.got_em(self.offset) then
			local px, py = self.get_xy(self.offset)
			local cx, cy = game:camera_pos()
			local wx, wy = 12, 12
			gui.box(px - wx - cx, py - wy - cy, px + wx - cx, py + wy - cy, {255, 255, 0, 96}, {255, 255, 0, 255})
		else
			local px, py = self.get_xy(self.offset)
			local cx, cy = game:camera_pos()
			local kx, ky = memory.readword(0xFFA008), memory.readword(0xFFA00C)
			local dx, dy = px - kx, py - ky
			local len = math.sqrt(dx*dx + dy*dy)
			dx = 64 * dx / len
			dy = 64 * dy / len
			gui.line(kx - cx, ky - cy, kx + dx - cx, ky + dy - cy, {255, 255, 255, 255})
		end
	end
	return self.active
end

function Emerald_widget:construct(x, y, offset, is_active, got_em, get_xy)
	self:super(x, y, true)
	self.cleanfun = function()
			while #self.children > 0 do
				table.remove(self.children, 1)
			end
		end
	self.is_active = is_active
	self.offset = offset
	self.got_em = got_em
	self.get_xy = get_xy

	local hud = Frame_widget:new(0, 0, 70, 15)
	hud:add(Icon_widget:new(0, 0, "emeralds-chaos"), 1, 1)

	--	Position
	hud:add(Text_widget:new(0, 0, function() return string.format("%5d, %5d", get_xy(self.offset)) end), 20, 4)

	self:add(hud, 0, 0)
	return self
end

local emerald_hud = Container_widget:new(0, 70, true)
emerald_hud:add(Emerald_widget:new(0, 0, emerald1, function(offset) return memory.readlong(offset) ~= 0 end, is_emerald_showing, emerald_pos), 0, 16*0)
emerald_hud:add(Emerald_widget:new(0, 0, emerald2, function(offset) return memory.readlong(offset) ~= 0 end, is_emerald_showing, emerald_pos), 0, 16*1)
emerald_hud:add(Emerald_widget:new(0, 0, emerald3, function(offset) return memory.readlong(offset) ~= 0 end, is_emerald_showing, emerald_pos), 0, 16*2)
emerald_hud:add(Emerald_widget:new(0, 0, emerald4, function(offset) return memory.readlong(offset) ~= 0 end, is_emerald_showing, emerald_pos), 0, 16*3)
emerald_hud:add(Emerald_widget:new(0, 0, emerald5, function(offset) return memory.readlong(offset) ~= 0 end, is_emerald_showing, emerald_pos), 0, 16*4)

local ge1, ge2, ge3, ge4, ge5
local px1, px2, px3, px4, px5
local py1, py2, py3, py4, py5

local predict_hud = Container_widget:new(0, 70, true)
predict_hud:add(Emerald_widget:new(0, 0, emerald1, function(offset) return ge1 end, function(offset) return false end, function() return px1, py1 end), 0, 16*0)
predict_hud:add(Emerald_widget:new(0, 0, emerald2, function(offset) return ge2 end, function(offset) return false end, function() return px2, py2 end), 0, 16*1)
predict_hud:add(Emerald_widget:new(0, 0, emerald3, function(offset) return ge3 end, function(offset) return false end, function() return px3, py3 end), 0, 16*2)
predict_hud:add(Emerald_widget:new(0, 0, emerald4, function(offset) return ge4 end, function(offset) return false end, function() return px4, py4 end), 0, 16*3)
predict_hud:add(Emerald_widget:new(0, 0, emerald5, function(offset) return ge5 end, function(offset) return false end, function() return px5, py5 end), 0, 16*4)

local state = savestate.create()
local firststate = savestate.create()
function predict_emeralds()
	if memory.readbyte(0xfff6c2) == 0xA then
		px1, px2, px3, px4, px5 = 0, 0, 0, 0, 0
		savestate.save(firststate)
		savestate.save(state)
		joypad.set(1, {start=true})
		gens.emulateframeinvisible()
		while memory.readlong(0xFFF6E8) ~= 0 do
			gens.emulateframeinvisible()
		end
		while memory.readlong(0xFFF6E8) == 0 do
			savestate.save(state)
			gens.emulateframeinvisible()
		end
		local nframes = 0
		local emptr = (game:get_zone() == 12 and emerald5) or emerald3
		savestate.load(state)
		local vint = memory.readlong(0xFFFE42)
		px1, px2, px3, px4, px5 = 0, 0, 0, 0, 0
		local iter = 0
		while (true) do
			memory.writelong(0xFFFE42, vint)
			while memory.readlong(emptr) == 0 do
				gens.emulateframeinvisible()
				nframes = nframes + 1
			end
			--	get predicted positions
			ge1 = memory.readlong(emerald1) ~= 0
			if ge1 then
				px1, py1 = emerald_pos(emerald1)
			end
			ge2 = memory.readlong(emerald2) ~= 0
			if ge2 then
				px2, py2 = emerald_pos(emerald2)
			end
			ge3 = memory.readlong(emerald3) ~= 0
			if ge3 then
				px3, py3 = emerald_pos(emerald3)
			end
			ge4 = memory.readlong(emerald4) ~= 0
			if ge4 then
				px4, py4 = emerald_pos(emerald4)
			end
			ge5 = memory.readlong(emerald5) ~= 0
			if ge5 then
				px5, py5 = emerald_pos(emerald5)
			end
			print(iter, ":", px1, px2, px3, px4, px5)
			local limit1 = 5000
			local limit2 = 8000
			if px1 > limit2 and px2 > limit2 and px3 > limit2 and ((ge4 ~= 0 and (px4 > limit2 and px5 > limit2)) or true) then
				break
			elseif px1 < limit1 and px2 < limit1 and px3 < limit1 and px4 < limit1 and px5 < limit1 then
				break
			else
				vint = vint + 1
				iter = iter + 1
				savestate.load(state)
				predict_hud:draw()
			end
		end
		--savestate.load(firststate)
		print(iter)
		--[[
		savestate.save(state)
		savestate.save(firststate)
		px1, px2, px3, px4, px5 = 0, 0, 0, 0, 0
		local iter = 0
		while (true) do
			iter = iter + 1
			joypad.set(1, {start=true})
			gens.emulateframeinvisible()
			for n=1,100 do
				repeat
					gens.emulateframeinvisible()
				until not gens.lagged()
			end

			--	get predicted positions
			ge1 = memory.readlong(emerald1) ~= 0
			if ge1 then
				px1, py1 = emerald_pos(emerald1)
			end
			ge2 = memory.readlong(emerald2) ~= 0
			if ge2 then
				px2, py2 = emerald_pos(emerald2)
			end
			ge3 = memory.readlong(emerald3) ~= 0
			if ge3 then
				px3, py3 = emerald_pos(emerald3)
			end
			ge4 = memory.readlong(emerald4) ~= 0
			if ge4 then
				px4, py4 = emerald_pos(emerald4)
			end
			ge5 = memory.readlong(emerald5) ~= 0
			if ge5 then
				px5, py5 = emerald_pos(emerald5)
			end
			print(iter, ":", px1, px2, px3, px4, px5)
			local limit = 2500
			if px1 < limit and px2 < limit and px3 < limit and px4 < limit and px5 < limit then
				break
			else
				savestate.load(state)
				predict_hud:draw()
				gens.emulateframeinvisible()
				savestate.save(state)
			end
		end
		]]
		gens.redraw()
		predict_hud:draw()
	end
end

gens.registerafter(function()
	if in_call then
		return
	end

	in_call = true
	predict_emeralds()
	emerald_hud:draw()
	in_call = false
end)

savestate.registerload(function()
	if in_call then
		return
	end

	in_call = true
	predict_emeralds()
	emerald_hud:draw()
	in_call = false
end)

in_call = true
predict_emeralds()
emerald_hud:draw()
in_call = false

