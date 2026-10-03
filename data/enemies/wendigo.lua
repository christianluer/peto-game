-- Lua script of enemy Wendigo.
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite_body, sprite_head, shadow
local was_hurt_by_sword = false

function enemy:on_created()
  local sprite_name = "enemies/" .. enemy:get_breed()
  shadow = enemy:create_sprite(sprite_name)
  sprite_body = enemy:create_sprite(sprite_name)
  sprite_head = enemy:create_sprite(sprite_name)
  -- Use correct animations.
  function shadow:on_animation_changed(animation)
    if animation ~= "shadow" then shadow:set_animation("shadow") end
  end
  function sprite_head:on_animation_changed() enemy:update_head_animation() end
  function sprite_body:on_animation_changed() enemy:update_head_animation() end
  shadow:set_animation("shadow")
  sprite_head:set_animation("walking_head")
  -- Collision properties.
  enemy:set_invincible_sprite(shadow)
  enemy:set_invincible_sprite(sprite_head)
  enemy:set_sprite_damage(shadow, 0)
  enemy:set_sprite_damage(sprite_head, 12)
  enemy:set_attack_consequence_sprite(sprite_head, "sword", "custom")
  -- General properties.
  enemy:set_sprite_damage(sprite_body, 2)
  enemy:set_life(4)
end

function enemy:update_head_animation()
  local body_animation = sprite_body:get_animation()
  if (body_animation == "walking" or body_animation == "stopped") then
    local head_animation = body_animation .. "_head"
    if sprite_head:get_animation() ~= head_animation then
      sprite_head:set_animation(head_animation)
    end
  else sprite_head:stop_animation() end
end

function enemy:on_restarted()
  -- Counterattack if enemy was hurt by hero sword.
  if was_hurt_by_sword then
    was_hurt_by_sword = false
    enemy:counterattack()
    return
  end
  -- Random walk.
  local m = sol.movement.create("straight")
  m:set_smooth(false)
  m:set_angle(math.random(0, 3) * math.pi / 2)
  m:set_speed(math.random(10, 35))
  m:set_max_distance(math.random(16, 80))
  function m:on_obstacle_reached() enemy:restart() end
  function m:on_finished() enemy:restart() end
  m:start(enemy)
end

-- Update sprites direction.
function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  if direction4 then
    for _, s in enemy:get_sprites() do
      s:set_direction(direction4)
    end
  end
end

-- Attach a custom damage to the sprites of the enemy.
function enemy:get_sprite_damage(sprite)
  return (sprite and sprite.custom_damage) or self:get_damage()
end
function enemy:set_sprite_damage(sprite, damage)
  sprite.custom_damage = damage
end

-- Notify for sword attacks to prepare counterattack.
function enemy:on_hurt_by_sword(hero, enemy_sprite)
  was_hurt_by_sword = true
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  -- Do nothing if enemy sprite cannot hurt hero.
  if enemy:get_sprite_damage(enemy_sprite) == 0 then return end
  local collision_mode = enemy:get_attacking_collision_mode()
  if not hero:overlaps(enemy, collision_mode) then return end  
  -- Otherwise, hero is not protected. Use built-in behavior.
  if enemy_sprite then
    local damage = enemy:get_sprite_damage(enemy_sprite)
    hero:start_hurt(enemy, enemy_sprite, damage)
  else
    local damage = enemy:get_damage()
    hero:start_hurt(enemy, damage)
  end
end

-- Counterattack used after being hurt by sword.
function enemy:counterattack()
  local m = sol.movement.create("target")
  m:set_target(hero)
  m:set_smooth(true)
  m:set_speed(hero:get_walking_speed())
  function m:on_obstacle_reached() enemy:restart() end
  function m:on_finished() enemy:restart() end
  m:start(enemy)
  -- Set max duration for the counterattack.
  local counterattack_duration = 3000
  sol.timer.start(enemy, counterattack_duration, function() enemy:restart() end)
end
