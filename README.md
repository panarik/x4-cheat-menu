# Cheat Menu 9.0

WIP cheat menu for X4 Foundations 9.00. Version **1.17**. First feature: instantly spawn any ship the game currently has loaded — vanilla, the DLC you own, and every ship from your other mods. No hardcoded ship list. The menu reads the same ware library as the in-game creative constructor. Built to set up RP situations. Requires SirNukes Mod Support APIs.

## Version

Current version: **1.17**. Author: **qadetmir**.

## Description

This mod is **in development**. What you get today is the first finished piece: spawn **any** ship that exists in **your** install.

The menu asks the game for every ware tagged **ship**, the same way Custom Start / the creative constructor builds its catalogue. If a ship pack, a DLC, or a one-off hull is loaded, it shows up. If you only own part of the DLC set, you only see that set.

You can drop a third-party fighter, a Kha'ak XL, or a vanilla courier in front of you and see how it actually behaves — loadout, size, and all.

I am publishing this for people who need to **build a scene and then role-play it**. Spawn the ships, set the table, play.

The new window: ESC → Extension Options → Cheat Menu 9.0.

## Installation instructions

1. Install and enable **SirNukes Mod Support APIs** (Simple Menu API). The mod window will not open without it.
2. Copy the inner mod folder (the one that contains **content.xml**) into **X4 Foundations/extensions/**.
3. Enable **Cheat Menu 9.0** in the in-game extensions list.

## How to use

You need a loaded save (the option is not on the title screen).

1. In the in-game menu (ESC): **Extension Options → Cheat Menu 9.0**. Click it.
2. A race list opens. Each race shows how many ships of that race exist in **your** install. Pick a race.
3. A size list opens: XL / L / M / S. Pick a size.
4. A list of the actual ships for that race and size.
5. Click a ship name. That same moment the chosen ship appears near the player, in a free spot. It is player-owned, the game builds the loadout, crew is 5-star.
6. Each click spawns one more ship. You can keep the window open.

## Main features

**Now**

- Live ship list from game wares (vanilla + owned DLC + enabled ship mods).
- Grouped by race, then XL / L / M / S, then names.
- Spawn **one** ship next to the player.
- Loadout **level 1** (the game assembles the kit).
- Full crew, skills set to 15 (five stars).

**Planned**

- Give spawned ships to factions.
- Spawn stations.
- Build fleets from a constructor-style list.
- Gate control (same idea as DeadAir).
- Delete existing ships and stations.

**Known limits**

- This is a WIP. Only the ship spawner for now.
- Spawn uses the original cheat's safe position next to your ship — nearby, not a scripted “exactly on the nose” offset.
- A few hulls (some Boron / some mod ships) may still come out with a thin loadout. That is a game/loadout quirk, not a mods own loadout list.
- Pilot/crew race pick is still the original argon / paranid / teladi set.

## Requirements

- **Required:** [SirNukes Mod Support APIs](https://www.nexusmods.com/x4foundations/mods/503) (Simple Menu API). Also on [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2042901274).
- Tested on the **9.00**.

## Shout outs

Original Cheat Menu: **Slan** (2018) and **ehtschu123** (Split / 2020). The spawn, loadout, and crew stars still follow that logic.

**SirNukes** — Mod Support APIs / Simple Menu. The new window sits on that API.

Egosoft — the live ware list is the same idea as the creative constructor. That is the catalogue this menu reads.

**DeadAir** — reference for how Simple Menu is used in the wild; gate tools are planned in that spirit later.

## Feedback

This mod is meant to work with **other people's ship mods**. If ships from your mods are missing from the list, show up wrong, or spawn wrong — please report it.

**Disclaimer.** The game itself picks the weapons. Spawn uses the internal constructor / loadout **level 1**, so custom turrets, guns, and other kit from a ship pack are replaced by the game's standard sets. That is how it works **today**. I will look at fitting mod hulls with weapons from those same mods later.

Please send reports **on this mod page** (Posts / Bugs).

In the report, include:

- Launch the game from Steam with these Launch Options (no quotes around the whole line): `-debug all -logfile debuglog.txt -scriptlogfiles`
- **Game log:** `%USERPROFILE%\Documents\Egosoft\X4\<profile number>\debuglog.txt` — the folder that also has **save** and **config.xml**. If Documents is on OneDrive: `%USERPROFILE%\OneDrive\Documents\Egosoft\X4\<profile number>\debuglog.txt`
- **Mod log:** `%USERPROFILE%\Documents\Egosoft\X4\<profile number>\logs\cm90\cm90_cheat_log.txt` (same profile folder). This file appears only with `-scriptlogfiles`.
- What is broken. A screenshot helps if the list or the spawned ship looks wrong.

Do not send crash dumps (`.dmp`) or `cm90_log.lua` from the mod folder — that file is the logger, not the log.
