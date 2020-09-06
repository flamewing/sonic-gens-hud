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

sonic2_rom_data = {
	Life_count = 0xfffe12,
	Score = 0xfffe26,
	Continue_count = 0xfffe18,
	Perfect_rings_left = 0xffff40,
	Timer_frames = 0xfffe04,
	Timer = 0xfffe22,
	Timer_minute = 0xfffe23,
	Timer_frame = 0xfffe25,
	Timer_second = 0xfffe24,
	S1_Emerald_count = 0xffffb1,
	Super_Sonic_flag = 0xfffe19,
	Turning_Super_flag = 0xfff65f,
	Super_Sonic_frame_count = 0xfff670,
	Game_Mode = 0xfff600,
	Apparent_Zone = 0xfffe10,
	Apparent_Act = 0xfffe11,
	Bonus_Countdown_1 = 0xfff7d2,
	Camera_X_pos = 0xffee00,
	Camera_Y_pos = 0xffee04,
	Camera_Min_X_pos = 0xffeec8,
	Camera_Max_X_pos = 0xffeeca,
	Camera_Min_Y_pos = 0xffeecc,
	Camera_Max_Y_pos_now = 0xffeece,
	Current_Boss_ID = 0xfff7aa,
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
	Player1 = 0xffb000,
	Player2 = 0xffb040,
	bubbles_P1 = 0xffd080,
	bubbles_P2 = 0xffd0c0,
	shield = 0xffd180,
	control_counter = 0xfff702,
	respawn_counter = 0xfff704,
	CPU_routine = 0xfff708,
	GameModeID_Demo = 0x8,
	GameModeID_Level = 0xc,
}
