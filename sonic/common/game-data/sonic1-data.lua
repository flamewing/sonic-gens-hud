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

sonic1_rom_data = {
	Life_count = 0xfffe12,
	Score = 0xfffe26,
	Continue_count = 0xfffe18,
	Timer_frames = 0xfffe04,
	Timer = 0xfffe22,
	Timer_minute = 0xfffe23,
	Timer_frame = 0xfffe25,
	Timer_second = 0xfffe24,
	S1_Emerald_count = 0xfffe57,
	Game_Mode = 0xfff600,
	Apparent_Zone = 0xfffe10,
	Apparent_Act = 0xfffe11,
	Bonus_Countdown_1 = 0xfff7d2,
	Camera_X_pos = 0xfff700,
	Camera_Y_pos = 0xfff704,
	Camera_Min_X_pos = 0xfff728,
	Camera_Max_X_pos = 0xfff72a,
	Camera_Min_Y_pos = 0xfff72c,
	Camera_Max_Y_pos_now = 0xfff72e,
	Current_Boss_ID = 0xfff7aa,
	Invincibility_active = 0xfffe2d,
	Speedshoes_active = 0xfffe2e,
	Shield_active = 0xfffe2c,
	top_speed = 0xfff760,
	air_left = 0x28,
	id = 0xfffe15,
	x_pos = 0x8,
	x_sub = 0xa,
	y_pos = 0xc,
	y_sub = 0xe,
	x_vel = 0x10,
	y_vel = 0x12,
	inertia = 0x14,
	y_radius = 0x16,
	x_radius = 0x17,
	double_jump_data = 0x20,
	status = 0x22,
	angle = 0x26,
	double_jump_flag = 0x2f,
	invulnerable_time = 0x30,
	Invincibility_time = 0x32,
	Speedshoes_time = 0x34,
	spindash_flag = 0x39,
	spindash_counter = 0x3a,
	move_lock = 0x3e,
	air_frames = 0x38,
	Player1 = 0xffd000,
	Player2 = 0xffd040,
	shield = 0xffd180,
	bubbles_P1 = 0xffd340,
	GameModeID_Demo = 0x8,
	GameModeID_Level = 0xc,
}
