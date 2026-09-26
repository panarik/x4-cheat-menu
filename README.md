# Cheat Menu 9.0

Cheat menu for X4 Foundations. Version **1.24**. Spawn any ship the game currently has loaded, including ships from your other mods, then fit it. The list is grouped by the races and factions in your installed game. Requires SirNukes Mod Support APIs.

## Version

Current version: **1.24**. Author: **qadetmir**.

## Description

Spawn **any** ship that exists in **your** install: vanilla, the DLC you own, and every ship from enabled mods. No hardcoded ship list. The menu reads the same ware library as the in-game creative constructor.

The list is grouped by races and factions from that install, including custom ones from ship mods. Then by size, then by name.

Each ship can be created in either of two ways:

1. **Saved preset.** A kit you saved in the game for this ship. Slots that preset left empty stay empty.
2. **Automatic preset.** Built from the compatible modules loaded in your game (vanilla, your DLC, and enabled mods).

You choose how many ships to create: 1, 2, 3, 4, 5, 10, or 20.

If the hull ships with its own kit, that author preset is listed too. Empty slots in it stay empty.

You can drop a third-party fighter, a Kha'ak XL, or a vanilla courier in front of you and see how it actually behaves.

The window: ESC → Extension Options → Cheat Menu 9.0.

## Installation instructions

1. Install and enable **SirNukes Mod Support APIs** (Simple Menu API). The mod window will not open without it.
2. Copy the inner mod folder (the one that contains **content.xml**) into **X4 Foundations/extensions/**.
3. Enable **Cheat Menu 9.0** in the in-game extensions list.

## How to use

You need a loaded save (the option is not on the title screen).

1. In the in-game menu (ESC): **Extension Options → Cheat Menu 9.0**. Click it.
2. A list of races and factions opens. Each row shows how many ships of that group exist in **your** install. Pick one.
3. A size list opens: XL / L / M / S. Pick a size.
4. A list of the actual ships for that group and size.
5. Click a ship name. A fitting screen opens. Each row is a count dropdown: 1, 2, 3, 4, 5, 10, or 20.
6. **Player preset:** copies a kit you saved in the game for this ship. Slots the preset left empty stay empty.
7. **Auto from found modules:** builds a kit from compatible modules that are loaded.
8. **Author preset:** shown when the hull ships with its own kit. Same rules as a player preset.
9. The ships appear near the player, player-owned, with a full 5-star crew. You can keep the window open.

## Main features

**Now**

- Any ship the game has loaded, including ships from installed mods.
- The list is grouped by races and factions from the installed game, then XL / L / M / S, then names.
- Create a ship from a preset you saved in the game for that hull.
- Or create it from an automatic preset built from the loaded module list.
- Choose how many ships to create: 1, 2, 3, 4, 5, 10, or 20.
- Full crew, skills set to 15 (five stars).

**Planned**

- Give spawned ships to factions.
- Spawn stations.
- Build fleets from a constructor-style list.
- Gate control (same idea as DeadAir).
- Delete existing ships and stations.

**Known limits**

- Factions, stations, fleets, gates, and delete are not in this version.
- A preset does not fill slots that were empty in that kit.
- Auto-fit skips equipment a ship pack excluded from generated loadouts. If that equipment is already in a saved preset, the preset path still installs it.
- Spawn uses the original cheat's safe position next to your ship — nearby, not a scripted offset on the nose.
- Pilot/crew race pick is still the original argon / paranid / teladi set.

## Requirements

- **Required:** [SirNukes Mod Support APIs](https://www.nexusmods.com/x4foundations/mods/503) (Simple Menu API). Also on [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2042901274).
- Tested on X4 Foundations **8.00** and **9.00**.
- Tested with the latest version of the Star Wars Interworlds overhaul.

## Shout outs

Original Cheat Menu: **Slan** (2018) and **ehtschu123** (Split / 2020). The spawn, loadout, and crew stars still follow that logic.

**SirNukes** — Mod Support APIs / Simple Menu. The new window sits on that API.

Egosoft — the live ware list is the same idea as the creative constructor. That is the catalogue this menu reads.

**DeadAir** — reference for how Simple Menu is used in the wild; gate tools are planned in that spirit later.

## Feedback

This mod is meant to work with **other people's ship mods**. If ships from your mods are missing from the list, show up in the wrong group, or spawn wrong — please report it.

**Disclaimer.** A saved preset copies that kit, including mod equipment stored in it. The automatic preset asks the game to build a loadout from compatible modules that are loaded. Equipment a ship pack excluded from generated loadouts is left off the automatic path.

Please send reports **on this mod page** (Posts / Bugs).

In the report, include:

- Launch the game from Steam with these Launch Options (no quotes around the whole line): `-debug all -logfile debuglog.txt -scriptlogfiles`
- **Game log:** `%USERPROFILE%\Documents\Egosoft\X4\<profile number>\debuglog.txt` — the folder that also has **save** and **config.xml**. If Documents is on OneDrive: `%USERPROFILE%\OneDrive\Documents\Egosoft\X4\<profile number>\debuglog.txt`
- **Mod log:** `%USERPROFILE%\Documents\Egosoft\X4\<profile number>\logs\cm90\cm90_cheat_log.txt` (same profile folder). This file appears only with `-scriptlogfiles`.
- What is broken. A screenshot helps if the list or the spawned ship looks wrong.

Do not send crash dumps (`.dmp`) or `cm90_log.lua` from the mod folder — that file is the logger, not the log.
