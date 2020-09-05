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
	base_path = (string.gsub(debug.getinfo(1).source, "sonic%-hud", "?", 1)):sub(2)
	package.path = base_path .. ";" .. package.path
end

--------------------------------------------------------------------------------
--	Script configuration options.
--------------------------------------------------------------------------------
gens.persistglobalvariables({
	-- Enabled HUDs
	game_hud = true,
	active_char_huds = {[1]=true, [2]=true},
	stat_hud = true,
	boss_hud_active = true,
	menu_active = true,	-- ignores disable_lua_hud
	-- Special features
	enable_predictor = true,
	-- Configuration options
	disable_original_huds = false,
	disable_lua_hud = false,
	skip_boring_stuff = false,
	skip_score_tally = true, -- requires skip_boring_stuff to be true to do anything
	disable_hyperflash = true,
	disable_s3k_super_music = false,
})

--------------------------------------------------------------------------------
--	Include all of the script subfiles.
--------------------------------------------------------------------------------
require("sonic/common/rom-check")
require("headers/register")
require("headers/widgets")
require("sonic/common/config-menu")
require("sonic/common/game-info")
require("sonic/common/char-info")
require("sonic/common/portraits")
require("sonic/common/jump-predictor")
require("sonic/common/status-widget")
require("sonic/common/character-hud")
require("sonic/common/boss-hud")
require("sonic/fast-forward")
require("sonic/kill-hyperflash")
require("sonic/kill-super-music")
require("sonic/kill-original")

--------------------------------------------------------------------------------
--	HUD components: status icons, character HUDs, boss HUDs.
--------------------------------------------------------------------------------
local status_huds = Status_widget:new(72, 0, stat_hud)
local char_huds = nil
local levelbounds = nil
local boss_hud = Boss_widget:new(0, 0, boss_hud_active)

--------------------------------------------------------------------------------
--	Main game HUD
--------------------------------------------------------------------------------
local function create_main_hud(ly, w, h)
	local main_hud = Frame_widget:new(0, 0, w, h)
	--main_hud:add_status_icon(1,          2, "score"         , bind(game.get_score         , game))
	main_hud:add_status_icon(1,          2, "camera"        , bind(game.get_camera        , game))
	main_hud:add_status_icon(1,     ly + 2, "clock"         , bind(game.get_time          , game))
	main_hud:add_status_icon(1, 2 * ly + 2, "ring"          , bind(game.get_rings         , game))
	main_hud:add_status_icon(1, 3 * ly + 2, "emeralds-chaos", bind(game.get_chaos_emeralds, game))
	if game:has_super_emeralds() then
		main_hud:add_status_icon(36, 3 * ly + 2, "emeralds-super", bind(game.get_super_emeralds, game))
	elseif rom:is_sonic_cd() then
		main_hud:add(Icon_widget:new(0, 0, bind(game.get_timewarp_icon, game)), 36, 3 * ly + 2)
	end
	return main_hud
end

local main_hud = Container_widget:new(0, 0, game_hud)
main_hud:add(create_main_hud(14, 65, 58), 3, 0)
main_hud:add_toggle(make_toggle(58, false, Container_widget.toggled, main_hud, game_hud), 0, 0)

--------------------------------------------------------------------------------
--	Main workhorse function
--------------------------------------------------------------------------------
local flash_nomovie = false

--	Reads mem values, emulates a couple of frames, displays everything
draw_hud = function ()
	--	Selected character(s)
	local selchar   = game:get_char()
	if characters == nil or game.curr_char ~= selchar then
		set_chardata(selchar)
		char_huds = {}
		levelbounds = {}
		for i, char in pairs(characters) do
			table.insert(char_huds, Character_hud:new(char, (i == 2 and 214) or 0, 169, active_char_huds[i]))
			table.insert(levelbounds, Level_bounds:new(char, (char.is_p1 and {255, 255, 0, 255}) or {255, 0, 255, 255}))
		end
	end

	--	look 2 frames into the future, pretending the B button is held,
	--	and get what the X and Y velocity of the player will be
	if want_prediction() then
		predict_jumps()
	end

	--	Display big red translucent box all over screen if not playing or recording a movie.
	if flash_nomovie and not movie.recording() and not movie.playing() then
		gui.box  (0, 0, 319, 223, {255, 0, 0, 128}, {255, 0, 0, 255})
	end

	--	Camera bounds:
	for i, hud in pairs(levelbounds) do
		if hud.character:in_game() and active_char_huds[i] then
			hud:draw()
		end
	end

	--	Basic game HUD (rings, time, score, emeralds)
	game_hud = main_hud:draw()

	--	The character huds:
	for i, hud in pairs(char_huds) do
		if hud.character:in_game() then
			active_char_huds[i] = hud:draw()
		end
	end

	boss_hud_active = boss_hud:draw()

	--	General timers: invincibility, speed shoes, super status, etc.
	stat_hud = status_huds:draw()
end

local function do_huds()
	if not game:disable_hud() then
		draw_hud()
	end
end

local function do_huds_load()
	for _, item in pairs(status_huds.children) do
		item.active = false
	end
	status_huds.children = {}
	do_huds()
end

local function toggle_lua_hud(enable)
	if enable then
		callbacks.gens.registerafter:add(do_huds)
		callbacks.savestate.registerload:add(do_huds_load)
	else
		callbacks.gens.registerafter:remove(do_huds)
		callbacks.savestate.registerload:remove(do_huds_load)
	end
end

--------------------------------------------------------------------------------
--	Starting options.
--------------------------------------------------------------------------------
local function apply_options()
	if char_huds then
		for n = 1,#char_huds do
			char_huds[n]:set_state(active_char_huds[n])
		end
	end
	main_hud:set_state(game_hud)
	boss_hud:set_state(boss_hud_active)
	if boss_hud_active then
		boss_hud:register()
	else
		boss_hud:unregister()
	end
	status_huds:set_state(stat_hud)
	toggle_lua_hud(not disable_lua_hud)
	toggle_disable_original_huds(disable_original_huds)
	toggle_fast_forward(skip_boring_stuff)
	toggle_hyperflash(disable_hyperflash)
	toggle_disable_s3k_super_music(disable_s3k_super_music)
end

local function reset_config()
	game_hud = true
	active_char_huds = {[1]=true, [2]=true}
	stat_hud = true
	boss_hud_active = true
	menu_active = true
	enable_predictor = true
	disable_original_huds = false
	disable_lua_hud = false
	skip_boring_stuff = false
	skip_score_tally = true
	disable_hyperflash = true
	disable_s3k_super_music = false
end

--------------------------------------------------------------------------------
--	Configuration menu.
--------------------------------------------------------------------------------
local menubtn = Container_widget:new(273, 0, menu_active)
local menu = Config_menu:new(40, 30, 240, 143, function ()
		apply_options()
		if not disable_lua_hud and not game:disable_hud() then
			do_huds()
		end
		menu_active = menubtn:draw()
	end, menu_active)

menubtn:add_toggle(make_toggle(8, false, Container_widget.toggled, menubtn, not disable_lua_hud), 43, 0)
menubtn:add(make_button(Config_menu.menu_loop, menu, "Options", 42, 8, nil, {0, 0, 0, 192}), 0, 0)
callbacks.gui.register:add(function()
		menu_active = menubtn:draw()
	end)

--------------------------------------------------------------------------------
--	Apply the options and do initial draw.
--------------------------------------------------------------------------------
apply_options()
update_input()
if not disable_lua_hud and not game:disable_hud() then
	do_huds()
end
menubtn:draw()

