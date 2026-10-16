# Cheat Menu 9.0

## About this mod

A cheat menu for X4 Foundations — a constructor for game situations. Version **1.36**, author **qadetmir**.

The menu reads what your install actually has loaded — the same ware library as the in-game creative constructor. Vanilla, the DLC you own, and every enabled mod. No hardcoded lists: ships, combat fleets, and stations that normally take hours of waiting appear in a few clicks.

Three tools in one window: **Build Ship**, **Build Wing**, and **Spawn Stations**. Open it with ESC → Extension Options → Cheat Menu 9.0. You need a loaded save: the option is not on the title screen.

## Requirements and installation

1. **Required:** [SirNukes Mod Support APIs](https://www.nexusmods.com/x4foundations/mods/503) (Simple Menu API). Also on [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2042901274). The mod window will not open without it.
2. Copy the inner mod folder (the one that contains **content.xml**) into `X4 Foundations/extensions/`.
3. Enable **Cheat Menu 9.0** in the in-game extensions list.

Tested on X4 Foundations **8.00** and **9.00**, and with the latest version of the Star Wars Interworlds overhaul.

## Features

### Build Ship — spawn any ship from your install

Any ship that exists in your install: vanilla, your DLC, and every ship from enabled mods. The list is grouped by races and factions from that install, including custom ones from ship mods, then by size, then by name. Each group row shows how many of its ships exist in your install.

1. Click **Build Ship** in the left column. The races and factions open across the window. Pick one.
2. The next screen is three columns: **Step 1: Size**, **Step 2: Name**, **Step 3: Owner**. Pick a size, then a name. The right column lists who receives the hull — **Player** is the first row, so you can also give a Teladi hull to the Terrans.
3. **Step 4: Choose ship modules.** Pick a kit for that hull: **Auto from found modules**, every preset you saved in the game for this hull, and an author kit when the hull ships with one. Saved kits are copied as they are — slots a kit left empty stay empty.
4. **Step 5: Choose quantity of ships.** Any count from 1 to 20. The ships appear near you, at a safe position, and belong to the owner you picked. Until you pick one, they stay yours.

The crew is a full five-star set. Crew race is argon / paranid / teladi. The automatic kit is built from compatible modules that are loaded; equipment a ship pack excluded from its generated loadouts is left off the automatic path — a saved preset still installs it.

### Build Wing — place several combat fleets

Combat fleets from the jobs in your install, grouped by race and faction. Terran fleets are split into Defence and Attack. The faction AI takes each fleet: it is not added to your property, and the click does not start a war or an invasion.

1. Click **Build Wing**, pick a race, then a faction. Terran opens Defence or Attack. Then pick a fleet. Picking a fleet only selects it.
2. **Step №2: Choose destination type.** The two sides are headings. **Spawn ahead of player** queues that fleet in front of your ship. **Spawn with coordinates** sets X, Y, and Z in kilometres, from −500 to 500, zero in the middle. Click the number to type a value. **Add to list** on either side adds one row: the fleet and where it will appear. Add as many rows as you want, including the same fleet more than once.
3. **SPAWN** places every queued fleet, then clears the list. A row queued ahead of you appears in front of your ship. A row queued with coordinates appears at the X Y Z you stored.

### Spawn Stations — build your own station

Build a station from the module list of any race, connectors included. The station belongs to the owner you pick. Until you pick one, it is yours.

1. Click **Spawn Stations** and pick a race. One build is one race: the modules and the connectors all come from that race. A module with no maker race is listed only for races whose factions own its blueprint.
2. Set a quantity for each module type you want: 0, 1, 2, 3, 4, 5, 10, or 20. Zero means "do not build". You do not pick connectors: for every three modules above zero, the build adds one vertical connector, one cross, and one base connector of that race.
3. **Step 3: Choose owner.** Pick who receives the station. **Add to list** stores one row: the race, how many modules you set, that owner, and either "ahead" or the coordinates. **Spawn ahead of player** adds a station in front of your ship. **Spawn with coordinates** sets X, Y, and Z in kilometres, from −500 to 500, zero in the middle. Click the number to type a value. Add as many rows as you want.
4. **SPAWN** builds every queued station, each at its own place, then clears the list. Leave room between stations so their plots do not overlap. Where the modules sit inside the plot is the game's own layout, stacked upward. Each module is fitted at the highest loadout the station constructor offers.
5. Watch the status line: it says the station is ready to look at, or that the build was refused because the modules did not fit the plot. A short list finishes; a long list can be refused, and the connectors count toward that fit.

**Planned:** choosing the station's shape and station turret loadouts, gate control, deleting existing ships and stations.

## Shout outs

Original Cheat Menu: **Slan** (2018) and **ehtschu123** (Split / 2020). The spawn, loadout, and crew stars still follow that logic.

**SirNukes** — Mod Support APIs / Simple Menu. The window sits on that API.

Egosoft — the live ware list is the same idea as the creative constructor. That is the catalogue this menu reads.

**DeadAir** — reference for how Simple Menu is used in the wild; gate tools are planned in that spirit later.

## Feedback and bug reports

This mod is meant to work with **other people's ship mods**. If ships from your mods are missing from the list, show up in the wrong group, or spawn wrong — please report it on this mod page (Posts / Bugs).

In the report, include:

- Launch the game from Steam with these Launch Options (no quotes around the whole line): `-debug all -logfile debuglog.txt -scriptlogfiles`
- **Game log:** `%USERPROFILE%\Documents\Egosoft\X4\<profile number>\debuglog.txt` — the folder that also has **save** and **config.xml**. If Documents is on OneDrive: `%USERPROFILE%\OneDrive\Documents\Egosoft\X4\<profile number>\debuglog.txt`
- **Mod log:** `%USERPROFILE%\Documents\Egosoft\X4\<profile number>\logs\cm90\cm90_cheat_log.txt` (same profile folder). This file appears only with `-scriptlogfiles`.
- What is broken. A screenshot helps if the list or the spawned ship looks wrong.

Do not send crash dumps (`.dmp`) or `cm90_log.lua` from the mod folder — that file is the logger, not the log.
