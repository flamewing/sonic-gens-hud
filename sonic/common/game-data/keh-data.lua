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

keh_rom_data = {
	Life_count = 0xfffe3d,
	Score = 0xfffe54,
	Perfect_rings_left = 0xfffece,
	Timer_frames = 0xfffe3a,
	Timer = 0xfffe50,
	Timer_minute = 0xfffe51,
	Timer_frame = 0xfffe52,
	Timer_second = 0xfffe53,
	Game_Mode = 0xfff6c2,
	Apparent_Zone = 0xfffe46,
	Bonus_Countdown_1 = 0xfff842,
	Camera_X_pos = 0xfff300,
	Camera_Y_pos = 0xfff304,
	Camera_Min_X_pos = 0xfff476,
	Camera_Max_X_pos = 0xfff478,
	Camera_Min_Y_pos = 0xfff47a,
	Camera_Max_Y_pos_now = 0xfff47c,
	top_speed = 0xfff760,
	id = 0x0,
	x_pos = 0x8,
	x_sub = 0xa,
	y_pos = 0xc,
	y_sub = 0xe,
	x_vel = 0x10,
	y_vel = 0x12,
	inertia = 0x14,
	y_radius = 0x16,
	x_radius = 0x17,
	status = 0x22,
	angle = 0x26,
	air_left = 0x28,
	obj_control = 0x2a,
	status_secondary = 0x2b,
	move_lock = 0x2e,
	invulnerable_time = 0x30,
	Invincibility_time = 0x32,
	Speedshoes_time = 0x34,
	spindash_flag = 0x39,
	spindash_counter = 0x3a,
	air_frames = 0x38,
	Player1 = 0xffa000,
	Player2 = 0xffa040,
	bubbles_P1 = 0xffc080,
	bubbles_P2 = 0xffc0c0,
	shield = 0xffc180,
	control_counter = 0xfff702,
	respawn_counter = 0xfff704,
	CPU_routine = 0xfff708,
	GameModeID_Demo = 2,
	GameModeID_Level = 3,
}
