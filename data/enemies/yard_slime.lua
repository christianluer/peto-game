-- Blue slime. Slow, sturdy, and it hits as hard as a clucko's peck.

local enemy = ...
local yard_enemy = require("scripts/yard_enemy")

yard_enemy.attach(enemy, {
  sprites = { "enemies/slime_cyan" },
  awareness = yard_enemy.SWORDSMAN_AWARENESS,
  melee = 20,
  life = 6,
  chase_speed = 22,
  damage = yard_enemy.half_sword_damage,
  idle_animation = "walking",
  hurt_style = "monster",
})
