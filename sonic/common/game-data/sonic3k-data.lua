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
	obj_control = 0x2e,
	status = 0x2a,
    Player1 = 0xffb000,
    Player2 = 0xffb04a,
    Tails_control_counter = 0xfff702,
    Tails_respawn_counter = 0xfff704,
    Tails_CPU_routine = 0xfff708,
    GameModeID_Level = 0xc,
}
