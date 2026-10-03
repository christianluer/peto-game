-- V is the engine's item_2 key. It shoots the equipped spell instead of using item 2.
-- A new game has only water. Later quests can unlock the others, and a menu
-- can change the equipped spell with the functions at the bottom of this file.

local MAGIC_SHOT_COST = 8
local SHOT_COOLDOWN = 280
local SHOT_RANGE = 290
local EQUIPPED_KEY = "spell_equipped"

require("scripts/multi_events")

local magic_shot = {}
magic_shot.SHOT_RANGE = SHOT_RANGE

local spells = {
  water = {
    sprite = "elements/water_splash",
    animation = "splash",
    impact_sprite = "effects/ripple",
    impact_animation = "ripple",
    sound = "splash",
    damage = 2,
    speed = 176,
  },
  fire = {
    sprite = "entities/enemy_projectiles/fireball",
    animation = "walking",
    impact_sprite = "effects/flame",
    impact_animation = "stopped",
    sound = "fire_ball",
    damage = 2,
    speed = 192,
  },
  thunder = {
    sprite = "entities/enemy_projectiles/lightningball",
    animation = "walking",
    impact_sprite = "elements/lightning_zap",
    impact_animation = "zap",
    sound = "electrified",
    damage = 3,
    speed = 240,
  },
  ice = {
    sprite = "entities/enemy_projectiles/iceball",
    animation = "walking",
    impact_sprite = "elements/ice_blast",
    impact_animation = "disappear",
    sound = "frost1",
    damage = 2,
    speed = 176,
  },
}

local direction_offset = {
  [0] = { 14, 0 },
  [1] = { 0, -14 },
  [2] = { -14, 0 },
  [3] = { 0, 14 },
}

local function play_impact(map, x, y, layer, spell)
  local effect = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = 0,
  })
  local sprite = effect:create_sprite(spell.impact_sprite)
  sprite:set_animation(spell.impact_animation)
  function sprite:on_animation_finished()
    effect:remove()
  end
end

local function shoot(game, spell)
  local map = game:get_map()
  if map == nil or game:is_suspended() then
    return
  end

  local hero = map:get_hero()
  local direction = hero:get_direction()
  local x, y, layer = hero:get_position()
  local offset = direction_offset[direction]
  x = x + offset[1]
  y = y + offset[2]

  local projectile = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
  })
  projectile:set_can_traverse("hero", true)
  projectile:set_can_traverse_ground("shallow_water", true)
  projectile:set_can_traverse_ground("deep_water", true)
  projectile:set_can_traverse_ground("hole", true)
  projectile:set_can_traverse_ground("lava", true)
  projectile:set_can_traverse_ground("prickles", true)
  projectile:set_can_traverse_ground("grass", true)

  local sprite = projectile:create_sprite(spell.sprite)
  sprite:set_animation(spell.animation)
  if direction < sprite:get_num_directions() then
    sprite:set_direction(direction)
  end

  local spent = false
  local function finish()
    if spent or projectile:get_map() == nil then
      return
    end
    spent = true
    local px, py, layer = projectile:get_position()
    projectile:remove()
    play_impact(map, px, py, layer, spell)
  end

  projectile:add_collision_test("sprite", function(_, other)
    if spent or other:get_type() ~= "enemy" then
      return
    end
    other:hurt(spell.damage)
    finish()
  end)

  local movement = sol.movement.create("straight")
  movement:set_speed(spell.speed)
  movement:set_angle(direction * math.pi / 2)
  movement:set_max_distance(SHOT_RANGE)
  movement:set_smooth(false)
  function movement:on_obstacle_reached()
    finish()
  end
  function movement:on_finished()
    finish()
  end
  movement:start(projectile)

  sol.audio.play_sound(spell.sound)
  game:remove_magic(MAGIC_SHOT_COST)
end

local function unlocked_key(spell_id)
  return "spell_unlocked_" .. spell_id
end

function magic_shot:is_unlocked(game, spell_id)
  return spells[spell_id] ~= nil and game:get_value(unlocked_key(spell_id)) == true
end

function magic_shot:unlock(game, spell_id)
  if spells[spell_id] == nil then
    return false
  end
  game:set_value(unlocked_key(spell_id), true)
  return true
end

function magic_shot:get_equipped(game)
  return game:get_value(EQUIPPED_KEY)
end

-- Equips a spell the hero already has. Returns false if it is still locked.
function magic_shot:set_equipped(game, spell_id)
  if not magic_shot:is_unlocked(game, spell_id) then
    return false
  end
  game:set_value(EQUIPPED_KEY, spell_id)
  return true
end

local game_meta = sol.main.get_metatable("game")

game_meta:register_event("on_started", function(game)
  game._magic_shot_ready = true
  if not magic_shot:is_unlocked(game, "water") then
    magic_shot:unlock(game, "water")
  end
  if spells[game:get_value(EQUIPPED_KEY)] == nil then
    game:set_value(EQUIPPED_KEY, "water")
  end
end)

game_meta:register_event("on_command_pressed", function(game, command)
  if command ~= "item_2" then
    return false
  end
  local spell_id = game:get_value(EQUIPPED_KEY)
  local spell = spells[spell_id]
  if spell == nil or not magic_shot:is_unlocked(game, spell_id) then
    sol.audio.play_sound("wrong")
    return true
  end
  if not game._magic_shot_ready or game:get_magic() < MAGIC_SHOT_COST then
    if game:get_magic() < MAGIC_SHOT_COST then
      sol.audio.play_sound("wrong")
    end
    return true
  end

  game._magic_shot_ready = false
  sol.timer.start(game, SHOT_COOLDOWN, function()
    game._magic_shot_ready = true
  end)
  shoot(game, spell)
  return true
end)

return magic_shot
