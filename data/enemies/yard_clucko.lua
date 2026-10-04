-- Stands still until the hero is close, fires two fireballs, then pecks.
-- Notice range is 0.7 of the swordsman's. The fireball flies half a spell.

local enemy = ...
local yard_enemy = require("scripts/yard_enemy")

yard_enemy.attach(enemy, {
  sprites = { "enemies/clucko" },
  awareness = 120,
  melee = 20,
  damage = yard_enemy.half_sword_damage,
  idle_animation = "stopped",
  hurt_style = "monster",
  shots = 2,
  shot_delay = 1100,
  shoot = yard_enemy.shoot_fireball,
})
