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

soniccd_rom_data = {
	Life_count = 0xff1508,
    Score = 0xff1518,
    Continue_count = 0xff150e,
	Timer = 0xff1514,
	Timer_minute = 0xff1515,
	Timer_frame = 0xff1516,
	Timer_second = 0xff1517,
	S1_Emerald_count = 0xff0f20,
	Game_Mode = 0xfff600,
	Apparent_Zone = 0xff1506,
	Apparent_Act = 0xff1507,
	Bonus_Countdown_1 = 0xfff7d2,
	Camera_X_pos = 0xfff700,
	Camera_Y_pos = 0xfff704,
	Camera_Min_X_pos = 0xfff728,
	Camera_Max_X_pos = 0xfff72a,
	Camera_Min_Y_pos = 0xfff72c,
	Camera_Max_Y_pos_now = 0xfff72e,
    Current_Boss_ID = 0xfff7aa,
    TimeWarp_Active = 0xff1521,
    TimeWarp_Counter = 0xfff786,
    TimeWarp_Direction = 0xfff784,
    status = 0x22,
    Player1 = 0xffd000,
    ResetLevel_Flags = 0xff1522,
    GameModeID_Level = 0x0,
}
