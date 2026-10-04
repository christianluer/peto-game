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
- `data/maps/first_map.dat`: the cottage where a new game starts (house tileset). The south door fades to `home_yard` only after the poem and Denna's fixed reply. Stand in the top-left corner and press **F** to read the poem.
- `data/maps/home_yard.dat`: the grass outside that door (outside tileset). Christian has painted this map in the editor. Add yard behavior in `home_yard.lua`, not by rewriting the tile data. The south end of the dirt path fades to `fair_carriages` after every yard swordsman on that visit is dead.
- `data/maps/fair_carriages.dat`: a draft fair road with three carriages. Arliden, Laurian, Trip, Teren, and Shandi each have one fixed line in `dialogs.dat`. Face the nearest of them and press **F**. Calder, a draft name, opens the chat on **F** instead of a fixed line. **F** is the talk key for Denna too. The nearest person speaks. He does not follow. Walk west to return to the yard. The mailbox adds a character key, `denna` or `teacher`, so the bridge uses that person's prompt.
- `data/languages/en/text/`: English dialogue (`dialogs.dat`) and UI strings (`strings.dat`).
- `data/scripts/`: menus, HUD, magic, companion, game startup.
- `data/items/`, `data/enemies/`, `data/entities/`: behavior.
- `data/sprites/`, `data/tilesets/`, `data/sounds/`, `data/musics/`: art and audio. Extra tilesets from the free resource pack include `zoria`, `zane_desert`, `zane_forest`, `eod_cave`, and `eod_temple`.
- `character-catalog/characters.png` and `characters.zip`: one front frame per hero, villager, enemy, boss, and animal sprite, for choosing art. Not canon.

Story changes belong in language files and map scripts. Leave movement, the HUD, magic, the companion, and item systems alone unless the design change requires it.

## Play

| Input | What it does |
|---|---|
| Arrows | Walk |
| **C** | Sword slash. Hold, then release, for a spin if the magic bar has at least 12 points. The spin spends 12. |
| **V** | Equipped spell. Spends 8 magic. The shot flies 290 pixels. |
| **F** | Talk to the nearest person within 48 pixels. Denna and Calder open a chat. The troupe shows a short line. |
| Enter / Escape | Send a chat line, or close the chat. |

A full heart is 4 life points. The hero starts with 12, which is 3 hearts. Sword level 1 removes 1 life point. The magic bar holds 84 and refills on its own outside a charge or a spin.

**V** is water only. The spell list and the unlock checks live in `data/scripts/magic_shot.lua`. A later menu can equip a spell only after `unlock()` has been called for it. Do not put the cycle back on the key.

The companion is an NPC, so swords and spells do not hit her and she does not attack. She follows until she is 5 tiles (80 pixels) away, then stops. The chat panel is `data/scripts/companion.lua`. Replies come from `data/scripts/companion_llm.lua`. That script writes `companion_request.txt` in the Solarus write directory (`~/Library/Application Support/Solarus/peto/`) and polls `companion_reply.txt`. It does not open HTTP. If no reply arrives, she says "I can't hear you." Her display name and the woman type 1 sprite are placeholders.

Ollama and the model weights stay outside this repo, in `~/.ollama`. The model is `llama3.2:3b`. The process that talks to `http://127.0.0.1:11434` is `bridge.py` in the sibling repo `ollama-peto-game`. Do not commit model weights into either repo. Start Ollama, run `python3 "../ollama-peto-game/bridge.py"`, then `make start`.

NPCs use `set_traversable(true)`. This Solarus build has no `set_traversable_by`. Map scripts already define `map:on_started`, so a listener on the map metatable for that event does not run. Spawn something on every map from `game` `on_map_changed`.

Each visit to the yard spawns 1, 2, or 3 swordsmen along the south edge and 3 cluckos in the upper left. Shared notice range, hit, and sprites live in `data/scripts/yard_enemy.lua`. Swordsmen notice at 230 pixels. Their hit is the hero's sword plus 20 percent, rounded up to a whole life point. Cluckos notice at 70 percent of that, stand still, fire two fireballs (half a spell's length, same damage as water), then peck for half a sword. The fair path opens after the swordsmen and the cluckos from that visit are dead.

## Licenses

See `CREDITS.md`.

- Template Lua is GPL v3. Edits to those scripts stay GPL v3.
- Most template images, sounds, and music are CC BY-SA 4.0. Keep the credit and share adaptations under the same license.
- New Peto story text and art can use a license Christian chooses. Say which files are new.
