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
--	Boss HUD widget and object.
--------------------------------------------------------------------------------

require("sonic/common/rom-check")
require("headers/lua-oo")
require("headers/register")
require("headers/widgets")

--------------------------------------------------------------------------------
--	This is the HUD of a single boss.
--------------------------------------------------------------------------------
Boss_hud = class{
	offset      = 0,
	icon_fun    = function (flag) return "blank" end,
	hit_counter = function (self) return 0 end,
	flash_timer = function (self) return 0 end,
}:extends(Container_widget)

if rom:is_sonic3() or rom:is_sonick() then
	function Boss_hud:get_position()
		local xpospix   = memory.readword      (self.offset + 0x10)
		local ypospix   = memory.readwordsigned(self.offset + 0x14)
		return string.format("%5d, %5d", xpospix, ypospix)
	end

	function Boss_hud:loaded()
		return memory.readlong(self.offset) ~= 0
	end
else
	function Boss_hud:get_position()
		local xpospix   = memory.readword      (self.offset + 0x08)
		local ypospix   = memory.readwordsigned(self.offset + 0x0c)
		return string.format("%5d, %5d", xpospix, ypospix)
	end

	function Boss_hud:loaded()
		return memory.readbyte(self.offset) ~= 0
	end
end

function Boss_hud:hit_counter_string()
	return string.format("x%3d", self:hit_counter())
end

function Boss_hud:flash_timer_string()
	return ((self:flash_timer() > 0) and string.format("%3d", self:flash_timer())) or ""
end

function Boss_hud:face_icon()
	return self.icon_fun(self:flash_timer() > 0)
end

function Boss_hud:draw()
	if self.offset == 0 or self:hit_counter() == 0 or not self:loaded() then
		return false
	end
	if self.active then
		for _, m in pairs(self.children) do
			m:draw()
		end
	end
	if self.toggle then
		self.toggle:draw()
	end
	return self.active
end

function Boss_hud:construct(x, y, active, offset, icon_fun, hit_counter, flash_timer)
	self:super(x, y, active)
	self.offset = offset
	self.icon_fun = icon_fun
	self.hit_counter = hit_counter
	self.flash_timer = flash_timer

	local hud = Frame_widget:new(0, 0, 65, 29)
	hud:add(Icon_widget:new(0, 0, bind(self.face_icon, self)), 2, 2)

	--	Hit counter
	hud:add(Text_widget:new(0, 0, bind(self.hit_counter_string, self)), 22, 5)
	hud:add(Text_widget:new(0, 0, bind(self.flash_timer_string, self)), 53, 5)
	-- These are for debugging purposes:
	--hud:add(Text_widget:new(0, 0, bind(function (self) return string.format("0x%02x", memory.readbyte(self.offset)) end, self)), 22, 12)
	--hud:add(Text_widget:new(0, 0, bind(function (self) return string.format("0x%06x", self.offset) end, self)), 22, 12)

	--	Position
	hud:add(Icon_widget:new(0, 0, "location"                   ),  2, 18)
	hud:add(Text_widget:new(0, 0, bind(self.get_position, self)), 17, 19)

	self:add(hud, 0, 0)
	return self
end

--------------------------------------------------------------------------------
--	This is a self-organizing widget that watches for, and creates, the boss
--	HUDs for each active boss.
--------------------------------------------------------------------------------
Boss_widget = class{
	boss_addr = {},
	cleanfun  = function() end,
}:extends(Container_widget)

local function make_boss_icons(hit, normal)
	return function(hurt)
		return hurt and hit or normal
	end
end
local eggmanicons = make_boss_icons("eggman-flashing"         , "eggman")
local mecha_icons = make_boss_icons("mechasonic-blue-flashing", "mechasonic-blue")

local select_icons = function(val) return eggmanicons end
if rom:is_sonic2() then
	select_icons = function(val) return ((val == 0xaf) and mecha_icons) or eggmanicons end
elseif rom:is_sonick() or rom:is_sonic3k() then
	local knux_icons  = make_boss_icons("knuckles-wounded"    , "knuckles-normal")
	select_icons = function(val)
			if val == 1 then
				return mecha_icons
			elseif val == 2 then
				return knux_icons
			else
				return eggmanicons
			end
		end
end

function Boss_widget:construct(x, y, active)
	self:super(x, y, active)
	self:add_toggle(make_toggle(65, true, Container_widget.toggled, self, active), 134, 220)

	-- Code locations of boss main loop.
	self.boss_addr = rom.boss_array

	self.cleanfun = function()
			self:scan_bosses()
		end

	return self
end

function Boss_widget:scan_bosses()
	self.children = {}
	if rom:is_keh() then
	elseif rom:is_sonic3() or rom:is_sonick() then
		local offset = 0xffb094
		local last   = 0xffcfcb
		while offset < last do
			local code = memory.readlong(offset)
			for ad, fun in pairs(self.boss_addr) do
				if code == ad then
					self:add(Boss_hud:new(0, 0, true, offset, select_icons(fun[1]), fun[2], fun[3]), 0, 0)
					break
				end
			end
			offset = offset + 0x4a
		end
	else
		local offset = (rom:is_sonic2() and 0xffb080) or 0xffd040
		local last   = (rom:is_sonic2() and 0xffd5ff) or 0xffefff
		while offset < last do
			local id = memory.readbyte(offset)
			if id ~= 0 then
				for ad, fun in pairs(self.boss_addr) do
					if id == fun[1] then
						self:add(Boss_hud:new(0, 0, true, offset, select_icons(fun[1]), fun[2], fun[3]), 0, 0)
						break
					end
				end
			end
			offset = offset + 0x40
		end
	end
end

function Boss_widget:register()
	-- Register all code addresses and snoop at a0 register when it runs.
	for ad, fun in pairs(self.boss_addr) do
		memory.registerexec(ad, 8,
			function(address, range)
				local offset = AND(memory.getregister("a0"), 0xffffff)
				for id, child in pairs(self.children) do
					if child.offset == offset then
						-- already have it
						return
					end
				end
				self:add(Boss_hud:new(0, 0, true, offset, select_icons(fun[1]), fun[2], fun[3]), 0, 0)
			end)
	end
	self:scan_bosses()
	callbacks.savestate.registerload:add(self.cleanfun)
end

function Boss_widget:unregister()
	-- Unregister all code addresses.
	for ad, fun in pairs(self.boss_addr) do
		memory.registerexec(ad, 8, nil)
	end
	self.children = {}
	callbacks.savestate.registerload:remove(self.cleanfun)
end

function Boss_widget:draw()
	if self.active then
		local function boss_huds_x(n)
			if n == 0 then
				return 134
			elseif n == 1 then
				return 250
			end
			n = n - 2
			return 3 + (n%2) * 247
		end

		local function boss_huds_y(n)
			if n == 0 then
				return 191
			elseif n == 1 then
				return 29
			end
			n = n - 2
			return 60 + math.floor(n/2) * 31
		end

		if #self.children == 0 then
			self:scan_bosses()
		end

		local remove_queue = {}
		for n, item in pairs(self.children) do
			local j = n-1
			item:move(boss_huds_x(j), boss_huds_y(j))
			if not item:draw() then
				table.insert(remove_queue, 1, n)
			end
		end

		local todel = remove_queue[1]
		while todel do
			table.remove(remove_queue, 1)
			table.remove(self.children, todel)
			todel = remove_queue[1]
		end
	end
	if self.toggle then
		self.toggle:draw()
	end
	return self.active
end

