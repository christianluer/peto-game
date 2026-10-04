-- Slow, heavy turtle. The swordsman breed stays in the quest for a later map.

local enemy = ...
local yard_enemy = require("scripts/yard_enemy")

yard_enemy.attach(enemy, {
  sprites = { "enemies/duck_soldier_green", "enemies/duck_soldier_green_weapon" },
  awareness = yard_enemy.SWORDSMAN_AWARENESS,
  melee = 24,
  life = 8,
  hurt_style = "monster",
  chase_speed = 20,
  damage = yard_enemy.half_sword_damage,
  idle_animation = "walking",
})
