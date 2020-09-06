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

sonic3_rom_data = {
	Life_count = 0xfffe12,
	Score = 0xfffe26,
	Continue_count = 0xfffe18,
	Perfect_rings_left = 0xffff40,
	Timer_frames = 0xfffe04,
	Timer = 0xfffe22,
	Timer_minute = 0xfffe23,
	Timer_frame = 0xfffe25,
	Timer_second = 0xfffe24,
	S1_Emerald_count = 0xffffb0,
	S2_Emerald_count = 0xffffb1,
	Super_Sonic_flag = 0xfffe19,
	Turning_Super_flag = 0xfff65f,
	Super_Sonic_frame_count = 0xfff670,
	Game_Mode = 0xfff600,
	Apparent_Zone = 0xffee4e,
	Apparent_Act = 0xffee4f,
	Bonus_Countdown_1 = 0xfff7d2,
	Camera_X_pos = 0xffee78,
	Camera_Y_pos = 0xffee7c,
	Camera_Min_X_pos = 0xffee14,
	Camera_Max_X_pos = 0xffee16,
	Camera_Min_Y_pos = 0xffee18,
	Camera_Max_Y_pos_now = 0xffee1a,
	Current_Boss_ID = 0xfff7aa,
	Ending_running_flag = 0xffef72,
	carry_delay = 0xfff73f,
	shield = 0xffcce8,
	top_speed = 0xfff760,
	code = 0x0,
	x_pos = 0x10,
	x_sub = 0x12,
	y_pos = 0x14,
	y_sub = 0x16,
	x_vel = 0x18,
	y_vel = 0x1a,
	inertia = 0x1c,
	y_radius = 0x1e,
	x_radius = 0x1f,
	next_anim = 0x21,
	anim_frame = 0x23,
	double_jump_data = 0x25,
	angle = 0x26,
	status = 0x2a,
	status_secondary = 0x2b,
	air_left = 0x2c,
	obj_control = 0x2e,
	double_jump_flag = 0x2f,
	move_lock = 0x32,
	invulnerable_time = 0x34,
	Invincibility_time = 0x35,
	Speedshoes_time = 0x36,
	spindash_flag = 0x3d,
	spindash_counter = 0x3e,
	air_frames = 0x3c,
	Player1 = 0xffb000,
	Player2 = 0xffb04a,
	bubbles_P1 = 0xffCb2c,
	bubbles_P2 = 0xffcb76,
	control_counter = 0xfff702,
	respawn_counter = 0xfff704,
	CPU_routine = 0xfff708,
	GameModeID_Demo = 0x8,
	GameModeID_Level = 0xc,
}
