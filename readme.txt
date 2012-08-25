This set of script files is a Lua HUD for TASing Sega Genesis Sonic games. The
HUD also supports several hacks.


Index
--------------------------------------------------------------------------------
1) Introduction
2) Building
3) Using
4) Changelog

1) Introduction
--------------------------------------------------------------------------------

This HUD displays a load of useful information for TASing such games. It has the
following features:

 *	Expanded game HUD showing score, rings, level time (including frames), the
 	number of emeralds collected (chaos, super or time emeralds) and whether a
 	time warp is possible (and which kind).
 *	Character HUDs for both players, showing position (down to subpixel level),
 	speed and slope angle. For player 1, the current shield, the number of lives
 	and of continues are also shown; for player 2, there is an indicator of
 	whether Tails is being controlled by the CPU or by a (presumably human) 
 	player. Both players also feature a jump predictor whenever you are not in 
 	read-only playback of a movie; the jump predictor shows what will be your 
 	speed if you hold the 'C' button for the next two frames (so for optimal 
 	benefit, you should avoid using that button); for S2 and SCD, this speed
 	is calculated as it will be without holding the forward direction, due to
 	the air speed cap in those games.
 *	Boss HUDs, showing number of hits, a timer showing remaining invulnerability
 	time (in frames) and position (pixel level). S2 Boom and SCD do not feature
 	boss HUDs, but all other games in the compatibility list do.
 *	Dynamic status HUDs, showing several (most? all?) relevant timers (see below
 	for a list), as well as the current charge in a spindash or peelout.
 *	The ability to disable the original game HUDs. The current method is very
 	robust and fast, but could potentially cause desynchs; for this reason, it
 	is disabled by default, and it is not recommended to be used while recording
 	movies.
 *	The ability to skip "boring stuff", which is disabled by default. You can
 	optionally toggle skipping of score tallies in all supported games (it is on
 	by default, but does nothing unless you enable the skipping of generic
 	"boring" stuff).
 *	The ability to disable Hyper Sonic's hyperflash. This includes a graphical
 	glitch fix. As far as I can tell, the method used causes no desynchs, so it
 	is on by default.
 *	The ability to disable the extremely annoying super/hyper music from S3, SK
 	and S3K . This is disabled by default.
 *	The ability to disable all of these LUA HUDs with a simple variable.
 	Combined with the disabling of the original HUDs, this can make for a very
 	clean screen. For obvious reasons, this is off by default.
 *	A configuration menu with persistent settings, allowing you to easily toggle
 	all the available options.

All HUDs are semi-transparent so that they do not get too much in the way. They
are positioned assuming that the input display, frame counter and lag frames are
shown in the upper right corner.

The timers (all in frames) currently watched by this script are:
 *	post-hit invulnerability timer (for both players);
 *	drowning timer (for both players);
 *	insta-shield (Sonic, S3/SK/S3&K);
 *	flight timer and flight boost timer (Tails, except S2);
 *	speed shoes timer;
 *	invincibility timer;
 *	super/hyper form timer;
 *	frames until time warp (SCD);
 *	for 2p Tails, respawn and despawn timers and frames until CPU takes over.

The boss post-hit invulnerability timers are also watched and displayed, but
they are displayed in the boss' respective HUDs.

Also, slope horizontal move lock timers for both players are also watched and
displayed in the respective character HUD. 

Compatibility list:

 *	Sonic the Hedgehog (W rev 0, W rev 1, J)
 *	Pu7o's Miles 'Tails' Prower in Sonic the Hedgehog v2.1.1
 *	Stealth's Knuckles the Echidna in Sonic the Hedgehog v1.1
 *	E-122-Psi's Amy Rose in Sonic the Hedgehog v1.8
 *	E-122-Psi's Charmy Bee in Sonic the Hedgehog v1.1
 *	Sonic the Hedgehog CD [partial]
 *	qiuu's and snkenjoi's Sonic CD Plus Plus [partial]
 *	Sonic the Hedgehog 2
 *	Sonic the Hedgehog 2 locked on to Sonic & Knuckles
 *	E-122-Psi's Amy Rose in Sonic the Hedgehog 2 v1.5
 *	snkenjoi and iojnekns' Sonic Boom [partial]
 *	ColinC10's Robotnik's Revenge
 *	ColinC10's Sonic 1 and 2 (note: Retro Wiki page has an outdated version)
 *	Sonic the Hedgehog 3
 *	Sonic & Knuckles
 *	Sonic the Hedgehog 3 locked on to Sonic & Knuckles
 *	E-122-Psi's Sonic 3 and Amy Rose v1.3 

2) Building
--------------------------------------------------------------------------------
You need have a Unix environment with bash, plus Lua, GD tools (specifically,
png2gd) and 7z in order to build the HUD. If you have none of this, you can't
build it at the moment.

After installing all required tools, edit 'make.sh' so that the environment
variables it sets have the correct locations.

3) Using
--------------------------------------------------------------------------------
Find the location where your Gens rerecording executable is. At the same level,
create a directory called "lua". Extract all the contents of the distributed
package into this directory.

Open a supported ROM, then start sonic-hud.lua.

4) Changelog
--------------------------------------------------------------------------------

Aug 25 2012:
 *	Sonic 3 & Amy Rose support;
 *	Updated Charmy in Sonic 1 support to v1.1;
 *	Perfect rings counter in S2;

Apr 15 2012:
 *	Updated support to Amy in Sonic 2 hack to version 1.5.

Oct 11/2010:
 *	Fixes error in plain Sonic 3 with the boss tables introduced in previous
 	version.
 *	Updated to Amy in Sonic 2 v1.2.
 *	Tracking Tails despawn timer as well.
 *	Improved Tails flight icon again.
 *	Now also watching slope horizontal move lock timers.
 *	Super Amy support for Amy in Sonic 2.

Sep 27/2010:
 *	Revamped the ROM detection and feature set code.
 *	Added several hacks to the compatibility list.

Jan 22 2012:
 *	Updated support to Amy in Sonic 2 hack to version 1.5.


Apr 15/2011:
 *	Move lock support in Sonic 1 and derivatives;
 *	Tails flight grab timer is now tracked in S3/SK/S3&K;
 *	Fixed bug in configuration menu;
 *	Added support for E-122-Psi's Charmy Bee in Sonic the Hedgehog ROM hack.

Oct 11/2010:
 *	Fixes error in plain Sonic 3 with the boss tables introduced in previous
 	version.
 *	Updated to Amy in Sonic 2 v1.2.
 *	Tracking Tails despawn timer as well.
 *	Improved Tails flight icon again.
 *	Now also watching slope horizontal move lock timers.
 *	Super Amy support for Amy in Sonic 2.

Sep 27/2010:
 *	Revamped the ROM detection and feature set code.
 *	Added several hacks to the compatibility list.

Oct 2/2010:
 *	Added instashield timer.
 *	Improved Tails' flight icon.
 *	Fixed Marble Garden 1 mini-boss HUD.
 *	Compatibility update for latest version of Amy Rose in Sonic 1.
 *	When disabling or enabling the original HUD in Sonic 1 and Sonic 1-based
 	hacks through the configuration menu, you no longer have to wait for the
 	next act for it to be restored.

Sep 27/2010:
 *	Revamped the ROM detection and feature set code.
 *	Added several hacks to the compatibility list.

Sep 3/2010:
 *	Fixed support for S&K and plain S3.
 *	Fixed jump predictor for S2K.
 *	Added Upthorn's code to disable super/hyper music in S3, S&K and S3&K.
 *	Reorganized code into multiple source files, all of which include the files
 	it needs. All of the scripts that are directly in the "sonic" subdirectory
 	are standalone scripts included by the main HUD script and conditionally
 	toggled on or off.
 *	Added configuration menu and persistent settings.
 *	Fixed behavior of script when it was started and when loading a saved state.
 *	Score tallies for all supported games can now be skipped.

Aug 9/2010:
 *	Knuckles in Sonic 2 also features boss hit counts/timers now.

Aug 8/2010:
 *	A slight redesign, replacing the boxes with the minus/plus signs by a larger
 	(but thinner) bar glued to the screen edge. This is to make it easier to
 	bring back a disabled box (by Fitts' law).
 *	Hit counters and invulnerability timers for all bosses in S1 (including
 	hacks), S2 (not including S2Boom), S3K (but not plain S3). Neither is
 	available for SCD.
 *	Tails flight boost timer. This factors in the vertical limit and limiting
 	upward speed, as well as the actual timer.
 *	Raiscan's code to skip S3K score tally, slightly modified.

