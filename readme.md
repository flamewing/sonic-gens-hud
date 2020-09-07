# Gens Lua HUD for Sega Genesis Sonic Games and Hacks

This set of script files is a Lua HUD for TASing Sega Genesis Sonic games. The HUD also supports several hacks.

## Index

1. Introduction
2. Building
3. Using
4. Changelog

## 1 Introduction

This HUD displays a load of useful information for TASing such games. It has the following features:

- Expanded game HUD showing score, rings, level time (including frames), the number of emeralds collected (chaos, super or time emeralds) and whether a time warp is possible (and which kind).
- Character HUDs for both players, showing position (down to subpixel level), speed and slope angle. For player 1, the current shield, the number of lives and of continues are also shown; for player 2, there is an indicator of whether Tails is being controlled by the CPU or by a (presumably human) player. Both players also feature a jump predictor whenever you are not in read-only playback of a movie; the jump predictor shows what will be your speed if you hold the 'C' button for the next two frames (so for optimal benefit, you should avoid using that button); for S2 and SCD, this speed is calculated as it will be without holding the forward direction, due to the air speed cap in those games. Also, lines show the level edges so that you know where you will be stopped.
- Boss HUDs, showing number of hits, a timer showing remaining invulnerability time (in frames) and position (pixel level). S2 Boom and SCD do not feature boss HUDs, but all other games in the compatibility list do.
- Dynamic status HUDs, showing several (most? all?) relevant timers (see below for a list), as well as the current charge in a spindash or peelout.
- The ability to disable the original game HUDs. The current method is very robust and fast, but could potentially cause desynchs; for this reason, it is disabled by default, and it is not recommended to be used while recording movies.
- The ability to skip "boring stuff", which is disabled by default. You can optionally toggle skipping of score tallies in all supported games (it is on by default, but does nothing unless you enable the skipping of generic "boring" stuff).
- The ability to disable Hyper Sonic's hyperflash. This includes a graphical glitch fix. As far as I can tell, the method used causes no desynchs, so it is on by default.
- The ability to disable the extremely annoying super/hyper music from S3, SK and S3K . This is disabled by default.
- The ability to disable all of these LUA HUDs with a simple variable. Combined with the disabling of the original HUDs, this can make for a very clean screen. For obvious reasons, this is off by default.
- A configuration menu with persistent settings, allowing you to easily toggle all the available options.

All HUDs are semi-transparent so that they do not get too much in the way. They are positioned assuming that the input display, frame counter and lag frames are shown in the upper right corner.

The timers (all in frames) currently watched by this script are:

- post-hit invulnerability timer (for both players);
- drowning timer (for both players);
- insta-shield (Sonic, S3/SK/S3&K);
- horizontal scroll delay caused by spindashes and some other abilities;
- flight timer and flight boost timer (Tails, except S2);
- speed shoes timer;
- invincibility timer;
- super/hyper form timer;
- frames until time warp (SCD);
- for 2p Tails, respawn and despawn timers and frames until CPU takes over.

The boss post-hit invulnerability timers are also watched and displayed, but they are displayed in the boss' respective HUDs.

Also, slope horizontal move lock timers for both players are also watched and displayed in the respective character HUD.

### Compatibility list

- Sonic the Hedgehog (W rev 0, W rev 1, J)
- Pu7o's Miles 'Tails' Prower in Sonic the Hedgehog v2.1.1
- Stealth's Knuckles the Echidna in Sonic the Hedgehog v1.1
- E-122-Psi's Amy Rose in Sonic the Hedgehog v1.8
- E-122-Psi's Charmy Bee in Sonic the Hedgehog v1.1
- Sonic the Hedgehog CD [partial]
- qiuu's and snkenjoi's Sonic CD Plus Plus [partial]
- Sonic the Hedgehog 2
- Sonic the Hedgehog 2 locked on to Sonic & Knuckles
- E-122-Psi's Amy Rose in Sonic the Hedgehog 2 v1.5
- snkenjoi and iojnekns' Sonic Boom [partial]
- ColinC10's Robotnik's Revenge
- ColinC10's Sonic 1 and 2 (note: Retro Wiki page has an outdated version)
- Sonic the Hedgehog 3
- Sonic & Knuckles
- Sonic the Hedgehog 3 locked on to Sonic & Knuckles
- E-122-Psi's Sonic 3 and Amy Rose v1.3
- Prerelease Sonic Classic Heroes [partial]

## 2 Building

You need have a Unix environment with bash, plus Lua, GD tools (specifically, png2gd) and 7z in order to build the HUD. If you have none of this, you can't build it at the moment.

If you want the HUD remover and the boss HUDs to work, you will also need to have the ROMs at a place where the build script can find them. See the first few variable definitions in make.sh:

- BASE: This can be used in the other variable definitions;
- ROMDIR: Path to your ROMs;
- HACKDIR: Path to the hacks;
- CDDIR: Path to Sonic CD bin/cue files.

Edit them to point to the correct places. Expected ROM names are as follows:

| Game/hack                                  | ROM name                                          |
|--------------------------------------------|---------------------------------------------------|
| Sonic the Hedgehog rev 0                   | `Sonic The Hedgehog (W) (REV00) [!].bin`          |
| Sonic the Hedgehog rev 1                   | `Sonic The Hedgehog (W) (REV01) [!].bin`          |
| Miles "Tails" Prower in Sonic the Hedgehog | `s1tails.bin`                                     |
| Knuckles the Echidna in Sonic the Hedgehog | `s1k.bin`                                         |
| Amy Rose in Sonic the Hedgehog v1.8        | `Amy_In_Sonic_1_Rev_1.8.bin`                      |
| Charmy Bee in Sonic the Hedgehog v1.1      | `Charmy_In_Sonic_1_Rev_1.1.bin`                   |
| Bunnie Rabbot in Sonic the Hedgehog v1.0   | `Bunnie_Rabbot_In_Sonic_The_Hedgehog_Rev_1.0.bin` |
| Sonic the Hedgehog 2                       | `Sonic the Hedgehog 2 (W) [!].bin`                |
| Sonic and Knuckles & Sonic 2               | `Sonic and Knuckles & Sonic 2 (W) [!].bin`        |
| Amy Rose in Sonic the Hedgehog 2 v1.5      | `Amy_In_Sonic_2_Rev_1.5.bin`                      |
| Robotnik's Revenge v1                      | `Robotnik's Revenge v1.bin`                       |
| Sonic 1 and 2                              | `Sonic 1 and 2.bin`                               |
| Sonic and Knuckles & Sonic 3               | `Sonic and Knuckles & Sonic 3 (W) [!].bin`        |
| Sonic 3 and Amy Rose v1.4                  | `Sonic_3_And_Amy_Rev_1.4.bin`                     |
| Sonic the Hedgehog 3                       | `Sonic the Hedgehog 3 (U) [!].bin`                |
| Sonic the Hedgehog CD (USA)                | `Sonic the Hedgehog CD (NTSC-U) [MK-4407].bin`    |
| Sonic Boom                                 | `SBOOM.BIN`                                       |
| Knuckles's Emerald Hunt                    | `KEH.bin`                                         |

## 3 Using

Extract all the contents of the distributed package somewhere you like. Open a supported ROM in Gens, then start 'sonic-hud.lua'.

Alternatively, all of the '*.lua' files in the 'sonic' subdirectory (but not on the 'sonic/common' subdirectory) can be opened in Gens and they will work on their own.

## 4 Changelog

**Jan 15/2014:**

- Fixed issues with Sonic CD.

**Jan 08/2014:**

- Replaced score display by camera position display.
- Added a level bounds display which shows where the player is stopped. Yellow is for player 1, magenta for player 2 and player 3; magenta is drawn after, so if only magenta is being shown, then both are being coincident. These displays are keyed by the character's HUDs, and will only display if those are also being displayed. The computations in the games for level bounds use the player's centerpoint; the HUD uses their hitbox instead. This means that the boundary will shift when the character's size changes.
- Found and added horizontal scroll delay for s1tails and for s1knux.
- Fixed boss code tables for S&K and S3&Amy
- Build scripts now skips missing ROMs and warns about it.

**Jun 28/2013:**

- Fixed horizontal scroll delay for non-S3/S&K/S3&K.

**Jun 27/2013:**

- Reformatted comments and readme to fill 80 columns.
- Added code to verify that functions are being supplied for callbacks.
- Added code to verify that widgets are being supplied to add to all container widgets.
- Non-nil values passed to class prototypes, so they actually have the fields.
- ROM checker no longer caches the return value of s1tails_check -- it is only ever called once per ROM anyway.
- More improvements to object model: the 'new' operator no longer not requires an instance of the class. Added a Java-like 'super' method to call the next constructor up on the class hierarchy (if any, with with error checking); syntax is 'self:super([args])'.

**Jun 26/2013:**

- Fixed two of Hyper Sonic's icons.
- Better object-oriented base model.
- More improvements to object-oriented model/syntax.
- Pure virtual error check for widget:add function.

**Jun 25/2013:**

- Icons are dynamically loaded as needed, instead of all at once at startup.

**Sep 5/2012:**

- Added horizontal scroll delay support for S2, S3, S&K, and their supported hacks.
- Fixed bugs 'Sonic 3 & Amy' hack.
- Script now works from wherever it has been decompressed to.
- Added S&K and S3&K visual cheat script.
- Added Sonic 1 movie resyncher.

**Aug 25/2012:**

- Sonic 3 & Amy Rose support;
- Updated Charmy in Sonic 1 support to v1.1;
- Perfect rings counter in S2;

**Apr 15/2012:**

- Updated support to Amy in Sonic 2 hack to version 1.5.

**Oct 11/2010:**

- Fixes error in plain Sonic 3 with the boss tables introduced in previous version.
- Updated to Amy in Sonic 2 v1.2.
- Tracking Tails despawn timer as well.
- Improved Tails flight icon again.
- Now also watching slope horizontal move lock timers.
- Super Amy support for Amy in Sonic 2.

**Sep 27/2010:**

- Revamped the ROM detection and feature set code.
- Added several hacks to the compatibility list.

**Jan 22/2012:**

- Updated support to Amy in Sonic 2 hack to version 1.5.

**Apr 15/2011:**

- Move lock support in Sonic 1 and derivatives;
- Tails flight grab timer is now tracked in S3/SK/S3&K;
- Fixed bug in configuration menu;
- Added support for E-122-Psi's Charmy Bee in Sonic the Hedgehog ROM hack.

**Oct 11/2010:**

- Fixes error in plain Sonic 3 with the boss tables introduced in previous version.
- Updated to Amy in Sonic 2 v1.2.
- Tracking Tails despawn timer as well.
- Improved Tails flight icon again.
- Now also watching slope horizontal move lock timers.
- Super Amy support for Amy in Sonic 2.

**Sep 27/2010:**

- Revamped the ROM detection and feature set code.
- Added several hacks to the compatibility list.

**Oct 2/2010:**

- Added instashield timer.
- Improved Tails' flight icon.
- Fixed Marble Garden 1 mini-boss HUD.
- Compatibility update for latest version of Amy Rose in Sonic 1.
- When disabling or enabling the original HUD in Sonic 1 and Sonic 1-based hacks through the configuration menu, you no longer have to wait for the next act for it to be restored.

**Sep 27/2010:**

- Revamped the ROM detection and feature set code.
- Added several hacks to the compatibility list.

**Sep 3/2010:**

- Fixed support for S&K and plain S3.
- Fixed jump predictor for S2K.
- Added Upthorn's code to disable super/hyper music in S3, S&K and S3&K.
- Reorganized code into multiple source files, all of which include the files it needs. All of the scripts that are directly in the "sonic" subdirectory are standalone scripts included by the main HUD script and conditionally toggled on or off.
- Added configuration menu and persistent settings.
- Fixed behavior of script when it was started and when loading a saved state.
- Score tallies for all supported games can now be skipped.

**Aug 9/2010:**

- Knuckles in Sonic 2 also features boss hit counts/timers now.

**Aug 8/2010:**

- A slight redesign, replacing the boxes with the minus/plus signs by a larger (but thinner) bar glued to the screen edge. This is to make it easier to bring back a disabled box (by Fitts' law).
- Hit counters and invulnerability timers for all bosses in S1 (including hacks), S2 (not including S2Boom), S3K (but not plain S3). Neither is available for SCD.
- Tails flight boost timer. This factors in the vertical limit and limiting upward speed, as well as the actual timer.
- Raiscan's code to skip S3K score tally, slightly modified.
