# Peto quest

Peto is an original real-time action RPG. The player walks a tile map, uses items, fights in real time, and advances the story through dialogue and map events.

The plot, names, and world are still open. Treat every story beat as a draft until Christian confirms it. The map, hero, enemies, and music that shipped with the quest are Solarus placeholder kit art. They are not Peto canon.

## Engine

- Solarus 2. The installed runner is 2.1.4. `data/quest.dat` uses quest format 2.0.
- This repo is the quest. Do not fork the C++ engine unless a feature is missing. Distributed engine changes stay GPL v3.
- Screen size is fixed at 320×240. `data/main.lua` opens the window at 1280×960 (4×). F11 toggles Solarus fullscreen. The macOS green button is a separate fullscreen path and often blanks this build.
- Run from the repo root with `make start`. That runs `solarus-run -suspend-unfocused=no -lua-console=no .`, so clicking another app does not pause the game.

Open the quest in Solarus Quest Editor with File > Load Quest and choose this repo. The folder must contain `data/`.

## Files

- `data/quest.dat`: title, author, version, screen size. Savegames use the write dir `peto`.
- `data/main.lua`: startup, window size, fullscreen keys.
- `data/maps/first_map.dat`: the cottage where a new game starts. `home_yard.dat` is the grass outside its door.
- `data/languages/en/text/`: English dialogue (`dialogs.dat`) and UI strings (`strings.dat`).
- `data/scripts/`: menus, HUD, game startup.
- `data/items/`, `data/enemies/`, `data/entities/`: behavior.
- `data/sprites/`, `data/tilesets/`, `data/sounds/`, `data/musics/`: art and audio.

Story changes belong in language files and map scripts. Leave movement, the HUD, and item systems alone unless the design change requires it.

## Licenses

See `CREDITS.md`.

- Template Lua is GPL v3. Edits to those scripts stay GPL v3.
- Most template images, sounds, and music are CC BY-SA 4.0. Keep the credit and share adaptations under the same license.
- New Peto story text and art can use a license Christian chooses. Say which files are new.
