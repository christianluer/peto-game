# Peto

Peto is an original real-time action RPG on a tile map. The player walks, uses items, fights in real time, and moves the story through dialogue and map events.

The plot, world, characters, and script are still open. Christian and the agent write the script together. Treat every story beat as a draft until Christian confirms it.

The repo name and working title are Peto. Either can change.

The playable files in `data/` start from Solarus Quest Editor's new-quest template. That map, hero, enemies, and music are placeholder kit art. They are not Peto canon.

## Read the docs first

Before changing the quest, read `docs/README.md`, then `docs/game.md`, then the one skill under `docs/skills/` that matches the task. Those files are the working context for this game. Do not guess Solarus editor steps, resource imports, or map warps when a skill already describes them.

| Task | Read |
|---|---|
| What the quest is, where files live, how to run it | `docs/game.md` |
| Open this quest, or unpack a `.solarus` archive | `docs/skills/editing-a-quest/SKILL.md` |
| Bring in tilesets, sprites, audio, or scripts from a pack or another quest | `docs/skills/import-resources/SKILL.md` |
| Doors, warps, map changes, scrolling edges | `docs/skills/teletransportation/SKILL.md` |

## Engine

Solarus 2 is the engine. Homebrew's current build is 2.1.4, and `data/quest.dat` targets quest format 2.0, which that build runs. This repo is the quest (the game data), not a fork of the C++ engine.

- Run it from the repo root with `make start`. Details are in `docs/game.md`.
- Edit maps, sprites, tilesets, and dialogue in Solarus Quest Editor. Follow `docs/skills/editing-a-quest/SKILL.md`.
- Write story and behavior in Lua under `data/`.
- Change the Solarus engine source only when a feature is missing. If a modified engine is ever distributed, those engine changes stay GPL v3 and the modified source must ship with it.

Quest metadata lives in `data/quest.dat`. The screen size is 320×240. Folder roles are listed in `docs/game.md`.

A dialogue or plot rewrite should stay in language files and map scripts. Leave movement, HUD, and item systems alone unless the design change requires it.

## Story

Do not invent final canon. Propose options, mark them as drafts, and wait for Christian to choose. Prefer short playable scenes over long lore dumps.

Characters, places, and story text written for Peto are original. Do not copy text, maps, characters, or assets from other commercial games.

## Licenses already in this repo

The starter quest is the one Solarus Quest Editor copies for File > New quest. See `CREDITS.md`.

- Lua scripts from that template are GPL v3. Edits to those scripts stay GPL v3.
- Most other template files (images, sounds, music) are CC BY-SA 4.0. Keep attribution, and share adaptations under the same license.
- Story text, maps, and art made for Peto can use a license Christian chooses. Say which files are new when that matters.

## How to work in this repo

- Confirm story, names, and world rules before treating them as decided.
- Explain a design tradeoff in plain language before a large refactor.
- Keep the story in dialogue files and map scripts, and systems in the other Lua files.
- If a task mixes a system change and a story change, say which files hold the draft script.
