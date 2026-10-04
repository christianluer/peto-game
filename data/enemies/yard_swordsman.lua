-- South-edge swordsman. Notice, hit, and sprites come from scripts/yard_enemy.

local enemy = ...
local yard_enemy = require("scripts/yard_enemy")

yard_enemy.attach(enemy, {
  sprites = { "enemies/soldier", "enemies/soldier_sword" },
  awareness = yard_enemy.SWORDSMAN_AWARENESS,
  melee = 28,
  damage = yard_enemy.raised_sword_damage,
  idle_animation = "walking",
  wander = yard_enemy.wander_south,
})
