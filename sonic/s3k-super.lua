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
require("headers/ui-icons")

if not gens.emulating() then
	error("ROM must be loaded first.")
elseif not rom:is_sonick() and not rom:is_sonic3k() then
	error("This script is for Sonic & Knuckles or Sonic 3 & Knuckles only.")
end

local plain_s3 = checksum == 0xa8f2
-- Set this to true to allow "Turbo Tails".
local allow_turbotails = false

-- Player offsets
local p1_off  = 0xffb000
local p2_off  = 0xffb04a

-- Several important RAM addresses:
local chaosem_off   = 0xffffb0 -- byte
local superem_off   = 0xffffb1 -- byte

local num_lives     = 0xfffe12 -- byte
local rings_life    = 0xfffe1b -- byte
local lives_upd     = 0xfffe1c -- byte
local rings_upd     = 0xfffe1d -- byte
local rings_off     = 0xfffe20 -- word
local lvl_rings     = 0xfffec8 -- word
local lvl_lives     = 0xfffecc -- word; guessing

local super_active  = 0xfff65f -- byte; normal = 0; becoming super = 1; reverting to normal = 2; transformed = -1
local super_swappal = 0xfff65e -- byte, Sonic/Knuckles only; counter that swaps palette 3 frames after reaching zero
local super_type    = 0xfffe19 -- byte; Super Sonic/Knuckles = 1, Hyper Sonic Knuckles = 255, all others 0
local super_drain   = 0xfff670 -- word; how many frames until ring is drained (takes sixty-ONE frames to drain each ring)
local sonic_topspd  = 0xfff760 -- word
local sonic_accel   = 0xfff762 -- word
local sonic_decel   = 0xfff764 -- word
local sel_char_off  = 0xffff08 -- word; also at 0xffff0a
local tails_supflag = 0xfff667 -- byte; Super Tails flag?
local tails_palette = 0xfff668 -- byte; what palette to use for Super Tails
local tails_swappal = 0xfff669 -- byte, Tails only; counter that swaps palette 4 frames after reaching zero
local tails_topspd  = 0xfffec0 -- word
local tails_accel   = 0xfffec2 -- word
local tails_decel   = 0xfffec4 -- word

local objmap_off    = 0xc  -- word
local objanim_off   = 0x20 -- long
local status_off    = 0x2b -- bitfield byte
local drown_off     = 0x2c -- byte; Seconds of air remaining
local control_off   = 0x2e -- Control flags
local invinc_off    = 0x35 -- byte; Decremented every 8 frames
local sspeed_off    = 0x36 -- byte; Decremented every 8 frames

local circling_objs_off        = 0xffcd7c
local trailing_objs_off        = 0xffcbc0
local map_supersonic           = (plain_s3 and 0x141194) or 0x146816 -- long
-- Stars that circle around Hyper Sonic:
local obj_hypersonic           = 0x019348 -- long
-- After-images left behind by Hyper Sonic and Hyper Knuckles:
local obj_hypersonicknux_trail = 0x01a494 -- long
-- Stars left behind by Super Sonic and Super Knuckles:
local obj_supersonicknux_stars = (plain_s3 and 0x17ea2) or 0x019156 -- long
-- The birds that circle Super Tails
local obj_hypertails_birds     = 0x01a170 -- long
local unk_flag                 = 0xffffffba

-- This is the tailing end of Tails_JumpHeight and is used to
-- play the transformation sound and music.
local hack_superchange_sounds  = (plain_s3 and 0x1b8d2) or 0x1db1c

-- Prevent multiple instances
in_call = false

-- Control variables
xmouse = 0
ymouse = 0
xmousedelta = 0
ymousedelta = 0
input_state = {}
draw_queue = {}

function update_input()
	input_state = input.get()
	xmousedelta = input_state.xmouse - xmouse
	ymousedelta = input_state.ymouse - ymouse
	xmouse = input_state.xmouse
	ymouse = input_state.ymouse
end

function do_button(text, x, y, width, height, fill_color, outline_color)
	local return_value
	
	if (xmouse >= x and ymouse >= y) and
		(xmouse <= x + width and ymouse <= y + height) then
		outline_color = {255, 255, 255, 255}
		
		if input_state.leftclick then
			if not leftclickdown then
				return_value = true
				leftclickdown = true
			end
			
			fill_color = {127, 0, 0, 255}
		else
			leftclickdown = false
			fill_color = {0, 0, 192, 255}
		end
	else
		if fill_color == nil then
			fill_color = {0, 0, 127, 255}
		end
		
		if outline_color == nil then
			outline_color = {0, 0, 255, 255}
		end
	end

	table.insert(draw_queue, function() gui.box(x, y, x + width, y + height, fill_color, outline_color) end)
	table.insert(draw_queue, function() gui.text(x + 2, y + 2, text, {255, 255, 255, 255}, {0, 0, 0, 0}) end)

	return return_value
end

function do_icon_button(gdimage, x, y, width, height, fill_color, outline_color, skip_corners)
	local return_value
	
	if (xmouse >= x and ymouse >= y) and
		(xmouse <= x + width and ymouse <= y + height) then

		if input_state.leftclick then
			if not leftclickdowna then
				return_value = true
				leftclickdowna = true
			end
		else
			leftclickdowna = false
		end
	end

	if fill_color ~= nil then
	    if skip_corners then
			table.insert(draw_queue, function() gui.box(x + 1, y + 1, x + width - 1, y + height - 2, fill_color) end)
		else
			table.insert(draw_queue, function() gui.box(x, y, x + width, y + height, fill_color, outline_color) end)
		end
	end
	
    table.insert(draw_queue, function() gui.drawimage(x, y, ui_icons[gdimage]) end)
	if outline_color ~= nil then
	    if skip_corners then
		    table.insert(draw_queue, function() gui.line(x + 1, y, x + width - 2, y, outline_color) end)
		    table.insert(draw_queue, function() gui.line(x, y + 1, x, y + height - 2, outline_color) end)
		    table.insert(draw_queue, function() gui.line(x + 1, y + height - 1, x + width - 2, y + height - 1, outline_color) end)
		    table.insert(draw_queue, function() gui.line(x + width - 1, y + 1, x + width - 1, y + height - 2, outline_color) end)
		end
	end

	return return_value
end

function do_toggle_button(state, x, y, w, h)
	if state then
		return not do_button("-", x, y, w, h)
	else
		return     do_button("+", x, y, w, h)
	end
end

function do_status_icon(x, y, gdimage, text)
    table.insert(draw_queue, function() gui.drawimage(x, y, gdimage) end)
	table.insert(draw_queue, function() gui.text(x + 20, y + 4, text, {255, 255, 255, 255}, {0, 0, 0, 0}) end)
end

function call_func(address)
	if address == nil or address == 0 then return end

	memory.setregister("a7", memory.getregister("a7") - 4)
	memory.writedword(memory.getregister("a7"), memory.getregister("pc"))
	
	memory.setregister("pc", address)
end

function play_sound(sfx)
	memory.setregister("d0", sfx)
	call_func((plain_s3 and 0x15e2) or 0x1358)
end

function give_life()
	memory.writeword(lvl_lives, memory.readword(lvl_lives) + 1)
	memory.writebyte(num_lives, memory.readbyte(num_lives) + 1)
	memory.writebyte(lives_upd, memory.readbyte(lives_upd) + 1)
	play_sound(0x2a)
end

function give_rings(cnt)
	local curcnt = memory.readword(lvl_rings) + cnt
	if curcnt > 999 then
		curcnt = 999
	elseif curcnt < 0 then
		curcnt = 0
	end
	memory.writeword(lvl_rings, curcnt)

	curcnt = memory.readword(rings_off) + cnt
	if curcnt > 999 then
		curcnt = 999
	elseif curcnt < 0 then
		curcnt = 0
	end
	memory.writeword(rings_off, curcnt)
	
	-- Update in-game HUD:
	memory.writebyte(rings_upd, (cnt > 0 and 1) or -1)

	local last_life = memory.readbyte(rings_life)
	if curcnt >= 100 and AND(last_life, BIT(1)) == 0 then
		memory.writebyte(rings_life, OR(last_life, BIT(1)))
		give_life()
	elseif curcnt >= 200 and AND(last_life, BIT(2)) == 0 then
		memory.writebyte(rings_life, OR(last_life, BIT(2)))
		give_life()
	else
		play_sound(0x33)
	end
end

function give_shoes()
	memory.writebyte(p1_off + status_off, OR(memory.readbyte(p1_off + status_off), BIT(2)))
	memory.writebyte(p1_off + sspeed_off, 150);
	if memory.readword(sel_char_off) == 2 then -- Tails
		memory.writeword(tails_topspd, 3072)
		memory.writeword(tails_accel, 24)
		memory.writeword(tails_decel, 128)
	else
		memory.writeword(sonic_topspd, 3072)
		memory.writeword(sonic_accel, 24)
		memory.writeword(sonic_decel, 128)
	end
	memory.setregister("d0", 8)
	call_func((plain_s3 and 0x164c) or 0x13c2)
end

local fire_shield = 0
local lightning_shield = 1
local bubble_shield = 2
local shield_sounds = {[fire_shield]      = 0x3e,
                       [lightning_shield] = 0x41,
                       [bubble_shield]    = 0x3f}
local shield_objs   = {[fire_shield]      = (plain_s3 and 0x1815a) or 0x195a6,
                       [lightning_shield] = (plain_s3 and 0x18268) or 0x196c2,
					   [bubble_shield]    = (plain_s3 and 0x18458) or 0x198be}
function give_shield(type)
	-- 0 = flame shield, 1 = lightning shield, 2 = bubble shield
	local bit = BIT(type+4)
	local status = AND(memory.readbyte(p1_off + status_off), 0x8e)
	status = OR(status, BIT(0))
	status = OR(status, bit)
	memory.writebyte(p1_off + status_off, status)
	play_sound(shield_sounds[type])
	if memory.readbyte(p1_off + 0x43) == 0 then
		memory.writelong(0xffcce8, shield_objs[type])
		memory.writeword(0xffcd2a, p1_off)
	else
		memory.writelong(0xffcd32, shield_objs[type])
		memory.writeword(0xffcd74, p1_off)
	end
end

local invinc_obj = (plain_s3 and 0x17580) or 0x187f0
function give_invincibility()
	-- Only if not super.
	if memory.readbyte(super_type) == 0 and (plain_s3 or memory.readbyte(tails_supflag) == 0) then
		memory.writebyte(p1_off + status_off, OR(memory.readbyte(p1_off + status_off), BIT(1)))
		memory.writebyte(p1_off + invinc_off, 150)
		if memory.readbyte(0xfff7aa) == 0 and memory.readbyte(p1_off + drown_off) > 12 then
			play_sound(0x2c)
		end
		if memory.readbyte(p1_off + 0x43) == 0 then
			memory.writelong(0xffcd7c, invinc_obj)
			memory.writeword(0xffcdbe, p1_off)
		else
			memory.writelong(0xffcea4, invinc_obj)
			memory.writeword(0xffcee6, p1_off)
		end
	end
end

function go_super()
	local hyper = false
	if not plain_s3 then
		if memory.readbyte(superem_off) ~= 7 and memory.readbyte(chaosem_off) ~= 7 then
			return
		end
		hyper = memory.readbyte(superem_off) == 7
	else
		if memory.readbyte(chaosem_off) ~= 7 then
			return
		end
	end
	if memory.readbyte(unk_flag) ~= 0 then
		return
	end
	if memory.readword(rings_off) < 50 then
		return
	end

	local selchar = memory.readword(sel_char_off)
	-- "Turbo Tails", all but Sonic in plain S3:
	if (plain_s3 and selchar > 1) or (not allow_turbotails and selchar == 2 and not hyper) then
		return
	end

	-- Common values:
	memory.writebyte(super_active, 1)
	memory.writebyte(super_swappal, 15)
	memory.writeword(super_drain, 60)
	memory.writebyte(p1_off + control_off, 129)
	-- Super/Hyper Sonic overrides these (and I am not sure Hyper Tails needs them):
	memory.writeword(sonic_topspd, 2048)
	memory.writeword(sonic_accel, 24)
	memory.writeword(sonic_decel, 192)
	-- Hyper Tails overrides this:
	memory.writebyte(p1_off + objanim_off, 31)

	if selchar <= 1 then -- Super/Hyper Sonic
		memory.writelong(p1_off + objmap_off, map_supersonic) -- Super/Hyper Sonic maps
		memory.writebyte(super_type, (hyper and -1) or 1)
		-- Stars left back or after-images:
		memory.writelong(trailing_objs_off, (hyper and obj_hypersonicknux_trail) or obj_supersonicknux_stars)
		if hyper then
			memory.writelong(circling_objs_off, obj_hypersonic) -- Circling stars
		end
		-- Supersonic/Hypersonic have even greater speed, acceleration and deceleration
		memory.writeword(sonic_topspd, 2560)
		memory.writeword(sonic_accel, 48)
		memory.writeword(sonic_decel, 256)
	elseif selchar == 2 then -- Hyper Tails
		memory.writebyte(tails_supflag, 1)
		memory.writebyte(p1_off + objanim_off, 41)
		-- Note: trying to "increment" Turbo/Super Tails with this fails because, among other
		-- things, the address is used for Tails' tails for several things (like flight).
		-- memory.writelong(trailing_objs_off, (hyper and obj_hypersonicknux_trail) or obj_supersonicknux_stars)
		if hyper then
			memory.writelong(circling_objs_off, obj_hypertails_birds) -- Flickies
		end
		memory.writeword(tails_topspd, 2048)
		memory.writeword(tails_accel, 24)
		memory.writeword(tails_decel, 192)
	elseif selchar == 3 then -- Super/Hyper Knuckles
		memory.writebyte(super_type, (hyper and -1) or 1)
		-- Stars left back or after-images:
		memory.writelong(trailing_objs_off, (hyper and obj_hypersonicknux_trail) or obj_supersonicknux_stars)
	end
	-- More common values:
	memory.writebyte(p1_off + invinc_off, 0)
	memory.writebyte(p1_off + status_off, OR(memory.readbyte(p1_off + status_off),2))

	-- The following four lines *should* play the transformation sound and start the music.
	-- However, only one of them actually gets played...
	--memory.setregister("d0", 0xffffff9f)
	--call_func(0x1380)
	--memory.setregister("d0",  0x2c)
	--call_func(0x1358)
	-- The following calls a portion of Tails_JumpHeight to play the sound and music.
	-- It is a hack, but works.
	call_func(hack_superchange_sounds)
end

function give_super(hyper)
	memory.writebyte(chaosem_off, 7)
	if not plain_s3 and hyper then
		memory.writebyte(superem_off, 7)
	end
	give_rings(50)
	go_super()
end

function give_wheel_glitch()
	memory.writebyte(p1_off + 0x3c, 0xff)
end

local x_offset = 269
local width    = 41
-- Reads mem values, emulates a couple of frames, displays everything
function create_menu()
	update_input()

	if do_icon_button    ("ring"            , 0,  63, 16, 14, {32, 32, 32, 255}, {255, 189, 0, 255}, true) then
		give_rings(10)
	elseif do_icon_button("shield-flame"    , 0,  78, 16, 14) then
		give_shield(fire_shield)
	elseif do_icon_button("shield-lightning",17,  78, 16, 14) then
		give_shield(lightning_shield)
	elseif do_icon_button("shield-bubble"   ,34,  78, 16, 14) then
		give_shield(bubble_shield)
	elseif do_icon_button("superspeed"      , 0,  93, 16, 14) then
		give_shoes()
	elseif do_icon_button("invincibility"   ,17,  93, 16, 14) then
		give_invincibility()
	elseif do_icon_button("emeralds-chaos"  , 0, 108, 16, 14, {32, 32, 32, 255}, {255, 189, 0, 255}, true) then
		local ncnt = (memory.readbyte(chaosem_off) + 1) % 8
		memory.writebyte(chaosem_off, ncnt)
		if plain_s3 then
			for emerald = 0, 6, 1 do
				local val = 0
				if emerald < ncnt then
					val = 1
				end
				memory.writebyte(0xffffb2 + emerald, (emerald < ncnt and 1) or 0)
			end
		else
			local scnt = memory.readbyte(superem_off)
			if scnt > ncnt then
				memory.writebyte(superem_off, ncnt)
				scnt = ncnt
			end
			for emerald = 0, 6, 1 do
				local val = 0
				if emerald < scnt then
					val = 3
				elseif emerald < ncnt then
					val = 2
				end
				memory.writebyte(0xffffb2 + emerald, val)
			end
		end
	elseif not plain_s3 and do_icon_button("emeralds-super"  ,17, 108, 16, 14, {32, 32, 32, 255}, {255, 189, 0, 255}, true) then
		local scnt = (memory.readbyte(superem_off) + 1) % 8
		memory.writebyte(superem_off, scnt)
		local ncnt = memory.readbyte(chaosem_off)
		if scnt > ncnt then
			memory.writebyte(chaosem_off, scnt)
			ncnt = scnt
		end
		for emerald = 0, 6, 1 do
			local val = 0
			if emerald < scnt then
				val = 3
			elseif emerald < ncnt then
				val = 2
			end
			memory.writebyte(0xffffb2 + emerald, val)
		end
	elseif do_icon_button("superchange"  , 0, 123, 16, 14) then
		give_super(false)
	-- elseif do_button("Go Normal"    , x_offset, 190, width, 9) then
	-- 	give_rings(-1000)
	-- 	memory.writebyte(chaosem_off, 0)
	-- 	memory.writebyte(superem_off, 0)
	-- 	memory.writebyte(super_swappal, 1) -- Near instant swap
	-- 	if memory.readword(sel_char_off) == 2 then
	-- 		memory.writebyte(tails_swappal, 1) -- Near instant swap
	-- 	end
	-- elseif do_button("Go Super"     , x_offset, 200, width, 9) then
	-- 	go_super(false)
	-- elseif do_button("Go Hyper"     , x_offset, 210, width, 9) then
	-- 	go_super(true)
	elseif not plain_s3 and do_icon_button("hyperchange"  , 17, 123, 16, 14) then
		give_super(true)
	elseif do_icon_button("wheel-glitch"  , 0, 138, 16, 14) then
		give_wheel_glitch()
	end

	local item = draw_queue[1]
	while item do
		item()
		table.remove(draw_queue, 1)
		item = draw_queue[1]
	end
end

gens.registerafter(function()
	if in_call then
		return
	end

	in_call = true
	create_menu()
	in_call = false
end)

gui.register(function()
	if in_call then
		return
	end

	in_call = true
	create_menu()
	in_call = false
end)
