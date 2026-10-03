---
name: import-resources
description: Import tilesets, sprites, sounds, music, and scripts into the Peto quest from another Solarus quest or a resource pack. Use when adding kit art or copying resources with File > Import from Quest.
---

# Import resources

Source: [Import resources](https://docs.solarus-games.org/tutorials/manual/import-resources/).

A resource pack is a Solarus project that is not a game. It still has a `data/` folder of tilesets, sprites, scripts, sounds, and music. Free packs are Git repositories; the one this quest already uses is the [Solarus Free Resource Pack](https://gitlab.com/solarus-games/solarus-free-resource-pack).

Import from the editor, not by copying files by hand. Hand copies skip author and license metadata.

1. Open Peto with File > Load Quest.
2. File > Import from Quest.
3. The left panel is the source. The right panel is Peto.
4. Select the resources to copy. Import items.
5. Record anything new in `CREDITS.md`. CC BY-SA files stay CC BY-SA. Ask before adding someone else's work, and keep their credit.

Identify missing selects pack resources whose ids are not in Peto. It does not notice a renamed or moved file, and it does not notice a newer version of a file already imported. To pick up an update, delete that resource in Peto and import it again.
