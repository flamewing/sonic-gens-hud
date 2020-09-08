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
--	A self-organizing togglable container widget.
--	Written by: Marzo Junior
--------------------------------------------------------------------------------

require("headers/lua-oo")
require("headers/widgets")

Config_menu = class{
	showing_menu = false,
	draw_fun     = function () end,
}:extends(Frame_widget)

local function make_emerald_toggle(callback, udata, icon, text, h, active)
	local btn = Clickable_widget:new(0, 0, 1 + 16 + 1 + 4 * #text + 1, h, callback, udata, {0, 0, 0, 0}, {0, 0, 0, 0})
	local emerald = Icon_widget:new(0, 0, function()
			if btn.hot then
				return (icon() and "emeralds-slot-hot-on") or "emeralds-slot-hot-off"
			else
				return (icon() and "emeralds-chaos") or "emeralds-slot-empty"
			end
		end)
	btn:add(emerald, 1, 1)
	btn:add(Text_widget:new(0, 0, text), 1 + 16 + 1, math.floor((h - 1 - 5)/2))
	return btn
end

local function make_frame(text, x, y, w, h)
	local fra = Frame_widget:new(x, y + 3, w, h - 2, nil, {0, 0, 0, 0})
	local box = Frame_widget:new(0, 0, 4 + 4 * #text, 8, {0, 0, 255, 255}, {0, 0, 127, 255})
	box:add(Text_widget:new(0, 0, text), 3, 1)
	fra:add(box, 2, -3)
	return fra
end

local function make_warning(text, x, y, w, h)
	local fra = Frame_widget:new(x, y + 3, w, h - 2, nil, {0, 0, 0, 0})
	local box = Frame_widget:new(0, 0, 4 + 4 * #text, 8, {0, 0, 255, 255}, {0, 0, 127, 255})
	box:add(Text_widget:new(0, 0, text), 3, 1)
	fra:add(box, 2, -3)
	return fra
end

function Config_menu:menu_loop()
	--	Nonrecursive.
	if self.showing_menu then
		return
	end
	sound.clear()
	self.showing_menu = true
	while self.showing_menu do
		--	Must do it ourselves.
		update_input()
		--	Draw everything else first.
		self.draw_fun()
		--	Draw menu now, in front of all else.
		self:draw()
		gens.redraw()
		gens.wait()
	end
	self.draw_fun()
	gens.redraw()
	self.showing_menu = false
end

function Config_menu:construct(x, y, w, h, draw_fun, active)
	self:super(x, y, w, h, nil, {0, 0, 0, 225})
	self.showing_menu = false
	self.draw_fun = draw_fun

	self:add(make_button(function(self) self.showing_menu = false end, self, "Close" , 30, 8), math.floor((w - 30)/2), h - 10)
	self:add(Icon_widget:new(0, 0, "warning"), math.floor((w + 30 + 1)/2) + 10, h - 10)
	self:add(Text_widget:new(0, 0, "May cause desynchs"), 2 + 11 + math.floor((w + 30 + 1)/2) + 11, h - 8)
	h = h - 10

	local fra0 = make_frame("HUD Options", 0, 0, math.floor(w/2)-3, h - 5)
	--	Toggle for disabling the lua HUD.
	fra0:add(make_emerald_toggle(
		function(self)
			disable_lua_hud = not disable_lua_hud
		end, nil,
		function()
			return not disable_lua_hud
		end, "Enable Lua HUD", 15, not disable_lua_hud), 2, 7)
	--	Conditional display for HUD options.
	local cond = Conditional_widget:new(0, 0, not disable_lua_hud, function()
			return not disable_lua_hud
		end, nil)
	--	Jump predictor toggle.
	cond:add(make_emerald_toggle(
		function(self)
			enable_predictor = not enable_predictor
		end, nil,
		function()
			return enable_predictor
		end, "Enable Jump Predictor", 15, enable_predictor), 0, 0)
	--	Main game HUD toggle.
	cond:add(make_emerald_toggle(
		function(self)
			game_hud = not game_hud
		end, nil,
		function()
			return game_hud
		end, "Show Main HUD", 15, game_hud), 0, 17)
	for n=1, 3 do
		--	Pn toggle.
		cond:add(make_emerald_toggle(
			function(self)
				active_char_huds[n] = not active_char_huds[n]
			end, nil,
			function()
				return active_char_huds[n]
			end, string.format("Show Player %d HUD", n), 15, active_char_huds[n]), 0, 17 * (n + 1))
	end
	--	Status HUD toggle.
	cond:add(make_emerald_toggle(
		function(self)
			stat_hud = not stat_hud
		end, nil,
		function()
			return stat_hud
		end, "Show Status HUD", 15, stat_hud), 0, 85)
	--	Boss HUD toggle.
	cond:add(make_emerald_toggle(
		function(self)
			boss_hud_active = not boss_hud_active
		end, nil,
		function()
			return boss_hud_active
		end, "Show Boss HUD", 15, boss_hud_active), 0, 102)
	fra0:add(cond, 2, 7 + 17)
	self:add(fra0, 2, 5)

	local fra1 = make_frame("Cosmetic Hacks", 0, 0, math.floor(w/2)-3, math.floor(h/2) - 4)
	--	Original HUD disabler.
	fra1:add(make_emerald_toggle(
		function(self)
			disable_original_huds = not disable_original_huds
		end, nil,
		function()
			return disable_original_huds
		end, "Disable Original HUDs", 15, disable_original_huds), 2, 7)
	fra1:add(Icon_widget:new(0, 0, "warning"), math.floor(w/2)-15, 10)
	if rom:is_sonic3() or rom:is_sonick() then
		--	Super/hyper music diabler.
		fra1:add(make_emerald_toggle(
			function(self)
				disable_s3k_super_music = not disable_s3k_super_music
			end, nil,
			function()
				return disable_s3k_super_music
			end, "Disable Super Music", 15, disable_s3k_super_music), 2, 7 + 17)
	end
	if rom:is_sonic3k() then
		--	Hyperflash toggle.
		fra1:add(make_emerald_toggle(
			function(self)
				disable_hyperflash = not disable_hyperflash
			end, nil,
			function()
				return disable_hyperflash
			end, "Disable Hyperflash", 15, disable_hyperflash), 2, 7 + 34)
	end
	self:add(fra1, math.floor(w/2) + 1, 5)

	local fra2 = make_frame("Playback Options", 0, 0, math.floor(w/2)-3, math.floor(h/2+0.5) - 4)
	--	Toggle to skip boring stuff.
	fra2:add(make_emerald_toggle(
		function(self)
			skip_boring_stuff = not skip_boring_stuff
		end, nil,
		function()
			return skip_boring_stuff
		end, "Skip Boring Stuff", 15, skip_boring_stuff), 2, 7)
	--	Conditional display for skipping stuff.
	local cond = Conditional_widget:new(0, 0, skip_boring_stuff, function()
			return skip_boring_stuff
		end, nil)
	--	Toggle for skipping score tallies.
	cond:add(make_emerald_toggle(
		function(self)
			skip_score_tally = not skip_score_tally
		end, nil,
		function()
			return skip_score_tally
		end, "Skip Score Tallies", 15, skip_score_tally), 0, 0)
	fra2:add(cond, 2, 7 + 17)
	self:add(fra2, math.floor(w/2) + 1, math.floor(h/2) + 1 + 3)

	return self
end

