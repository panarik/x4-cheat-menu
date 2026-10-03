# Cheat Menu 9.0

Cheat menu for X4 Foundations. Version **1.33**. Spawn any ship the game currently has loaded, including ships from your other mods, then fit it. Spawn the combat fleets defined for the races and factions in your install. The faction AI takes the fleet. Requires SirNukes Mod Support APIs.

## Version

Current version: **1.33**. Author: **qadetmir**.

## Description

Spawn **any** ship that exists in **your** install: vanilla, the DLC you own, and every ship from enabled mods. No hardcoded ship list. The menu reads the same ware library as the in-game creative constructor.

The list is grouped by races and factions from that install, including custom ones from ship mods. Then by size, then by name.

Each ship can be created in either of two ways:

1. **Saved preset.** A kit you saved in the game for this ship. Slots that preset left empty stay empty.
2. **Automatic preset.** Built from the compatible modules loaded in your game (vanilla, your DLC, and enabled mods).

You choose how many ships to create: 1, 2, 3, 4, 5, 10, or 20.

If the hull ships with its own kit, that author preset is listed too. Empty slots in it stay empty.

You can drop a third-party fighter, a Kha'ak XL, or a vanilla courier in front of you and see how it actually behaves.

**Build Wing** places a combat fleet from the jobs in your install. The list is grouped by race, then by faction. Terran fleets are split into Defence and Attack. Point your ship and pick a fleet. The lead ship and the escorts that fleet brings appear ahead of your nose, stacked upward. They belong to that faction. Its AI flies them. They are not added to your property.

The window: ESC → Extension Options → Cheat Menu 9.0.

## Installation instructions

1. Install and enable **SirNukes Mod Support APIs** (Simple Menu API). The mod window will not open without it.
2. Copy the inner mod folder (the one that contains **content.xml**) into **X4 Foundations/extensions/**.
3. Enable **Cheat Menu 9.0** in the in-game extensions list.

## How to use

You need a loaded save (the option is not on the title screen).

1. In the in-game menu (ESC): **Extension Options → Cheat Menu 9.0**. Click it.
2. A narrow column on the left stays on the window: **Build Ship**, **Build Wing**, and **Spawn Stations**. **Spawn Stations** opens races, then module types and quantities. Set a quantity above zero and press **Build**. Build places an empty station 20 km ahead and builds those modules. A line under Build says to wait, then that the station is ready to look at. Connectors for that race are added for you. The layout inside the plot is the game's own. A fixed Terran dock, pier, and container store finished this way on 2026-10-02. A list you compose uses the same steps and has not been tried in game yet. Point your ship before you pick a fleet: it forms ahead of the nose. **Build Wing** opens races, then the factions of that race. The Terran faction then opens Defence or Attack, and the next page is the fleets in that group. Any other faction opens its fleets directly. Click one. The lead ship and its escorts appear in front of you. The faction AI controls the fleet. It is not added to your property.
3. **Build Ship** opens the list of races and factions across the rest of the window. Each row shows how many ships of that group exist in **your** install. Pick one.
4. The next screen is three columns: **Step 1: Size**, **Step 2: Name**, and **Step 3: Owner**. Pick a size. Names for that size appear in the middle. The size list stays.
5. Pick a name. The right column lists who receives the hull. **Player** is the first row. The name list stays.
6. Pick an owner. Under the columns there is a blank row, then **Step 4: Choose ship modules** and **Step 5: Choose quantity of ships**. Until you pick a ship name, those rows are only labels.
7. Pick a name. The game looks up kits for that hull. **Step 4** then opens a list: **Auto from found modules** first, then every saved preset for this hull. Pick one. The list closes and the row shows that kit. The window stays open.
8. **Step 5** opens the numbers 1 through 20. Pick one to create the ships. If you have not picked a kit, nothing is created.
9. **Player preset:** copies a kit you saved in the game for this ship. Slots the preset left empty stay empty.
10. **Auto from found modules:** builds a kit from compatible modules that are loaded. **Author preset:** shown when the hull ships with its own kit. Same rules as a player preset.
11. The ships appear near you. They belong to the owner you picked. Until you pick one, they stay yours. Crew is still a full 5-star set from the original argon / paranid / teladi list. You can keep the window open.

## Main features

**Now**

**Build Ship**

- Any ship the game has loaded, including ships from installed mods.
- The list is grouped by races and factions from the installed game, then XL / L / M / S, then names.
- Create a ship from a preset you saved in the game for that hull.
- Or create it from an automatic preset built from the loaded module list.
- Choose who receives the hull: you, or another faction. A Teladi hull can be given to the Terrans. Until you pick, the ship stays yours.
- Choose how many ships to create: any count from 1 to 20.
- Full crew, skills set to 15 (five stars). Crew race is still argon / paranid / teladi.

**Build Wing**

- Combat fleets from the jobs in your install, grouped by race and faction. Terran fleets are split into Defence and Attack.
- A click places the lead ship and its escorts ahead of your nose. The faction AI flies the fleet.

**Spawn Stations**

- Pick a race, then a module type, then a quantity (0, 1, 2, 3, 4, 5, 10, or 20). **Build** places an empty station 20 km ahead and builds every module whose quantity is above zero. Connectors for that race are added for you. You do not pick them.
- Under Build, one line says the build is in progress, then that the station is placed and you can look. If the modules do not fit the plot, that line says so.
- The station is finished the same way as the 2026-10-02 test: the build storage is filled, then the game is asked to complete the build. A short list you compose can finish. A long list can be refused when the modules do not fit the plot.

**Planned**

- Choosing the station's shape, and station turret loadouts.
- Gate control (same idea as DeadAir).
- Delete existing ships and stations.

**Known limits**

- A station from a list you compose is in this version. A short list can finish. A long list can be refused when the modules do not fit the plot. Gates and delete are not in this version.
- One race per build. A module with no maker race is shown only for races whose factions own that blueprint.
- The plot is 10 km up, down, left, right, forward, and back: a 20 km cube. The station center is 20 km ahead, so the near face stays 10 km from your ship. Where modules sit inside it is the game's random layout. Direction is not on this screen.
- The hull owner changes. The crew race does not follow that faction yet.
- Auto-fit still builds its kit as the player faction. A saved preset does not.
- A fleet follows that faction's own orders. The click does not start a war or an invasion.
- A fleet forms on your heading when you click. Turning afterwards does not move it.
- A preset does not fill slots that were empty in that kit.
- Auto-fit skips equipment a ship pack excluded from generated loadouts. If that equipment is already in a saved preset, the preset path still installs it.
- Build Ship uses the original cheat's safe position next to your ship. A fleet is placed ahead of your nose instead.
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
