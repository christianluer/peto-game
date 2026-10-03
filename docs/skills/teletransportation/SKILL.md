---
name: teletransportation
description: Move the hero with teletransporters and destinations, including doors between maps and scrolling edges. Use when adding warps, doors, stairs, or adjacent-map transitions in a Solarus map.
---

# Teletransportation

Source: [Teletransportation](https://docs.solarus-games.org/tutorials/manual/teletransportation/). Entity API: [Teletransporter](https://docs.solarus-games.org/lua-api/map-entities/teletransporter/).

Peto currently has one map, `first_map`. A second map has to exist before a door can target it.

## Same map

1. On the map, add a Teletransporter and a Destination.
2. Name the destination `from_<teleporter>`, for example `from_cave_mouth`. Destination names are what the teletransporter dropdown shows.
3. Edit the teletransporter and choose that destination.
4. The hero faces the destination's direction after arrival. Use "Keep the same direction" to preserve the incoming facing.
5. Set the transition and an optional sound on the teletransporter.

Sprites are optional when the door is already drawn with tiles.

## Another map

Same entities. In the teletransporter properties, set both the destination map and the destination entity. Name destinations for the place they come from, such as `from_first_map`.

When renaming a destination, enable "Update existing teletransporter" so links in other maps stay valid.

Leave the map and re-enter it to test an edit without restarting the quest.

## Scrolling edge

Use this for two maps that sit next to each other.

1. Place a teletransporter just outside one edge of the map.
2. Resize it (R, or right-click > Resize) so it is about 16 pixels thick, the hero's size.
3. Set the destination map to the neighbor, the transition to Scrolling, and the destination to the matching edge rather than a destination entity. The hero keeps their position across the seam.
4. Repeat on the other map so the hero can walk back.
