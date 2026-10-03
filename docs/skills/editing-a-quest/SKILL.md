---
name: editing-a-quest
description: Open and edit a Solarus quest in Quest Editor, including extracting a .solarus archive into a data folder. Use when loading Peto, editing maps and scripts, or unpacking a downloaded Solarus game.
---

# Editing a quest

Source: [Editing an existing quest](https://docs.solarus-games.org/tutorials/manual/editing-an-existing-quest/).

Peto is already an editable quest. In Solarus Quest Editor, use File > Load Quest and select the repo root. That folder contains `data/`. Play from the editor with F5, or from the repo root with `make start`.

A downloaded game is usually a `.solarus` file, which is a zip of the quest. To edit one:

1. Rename it to `.zip` and extract it.
2. Put the extracted files in a `data/` directory inside a folder dedicated to that game.
3. File > Load Quest, and choose the folder that contains `data/`.

Solarus does not hide quest source. To mark original Peto files as all-rights-reserved, set that license on each resource in the editor. Do not strip credits from template files. See `CREDITS.md`.

Importing pieces of another quest into Peto is a separate step. Follow [import-resources](../import-resources/SKILL.md).
