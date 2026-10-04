-- Shared notice range, hit, and sprites for the yard enemies.
-- Life points are whole numbers, so a fraction is rounded up to at least 1.

local yard_enemy = {}

yard_enemy.SWORDSMAN_AWARENESS = 230
yard_enemy.SPELL_RANGE = 290
yard_enemy.SPELL_DAMAGE = 2

local function sword_ability(enemy)
  local amount = enemy:get_game():get_ability("sword")
  if amount < 1 then
    amount = 1
  end
  return amount
end

function yard_enemy.raised_sword_damage(enemy)
  return math.max(1, math.ceil(sword_ability(enemy) * 1.2))
end

function yard_enemy.half_sword_damage(enemy)
  return math.max(1, math.floor(sword_ability(enemy) * 0.5))
end

local function set_sprites(enemy, sprites, animation, direction)
  for _, sprite in ipairs(sprites) do
    if animation ~= nil and sprite:has_animation(animation) then
      sprite:set_animation(animation)
    end
    if direction ~= nil and direction < sprite:get_num_directions() then
      sprite:set_direction(direction)
    end
  end
end

function yard_enemy.attach(enemy, config)
  local sprites = {}
  function enemy:on_created()
    enemy:set_life(config.life or 4)
    enemy:set_damage(0)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 13)
    enemy:set_pushed_back_when_hurt(true)
    if config.hurt_style ~= nil then
      enemy:set_hurt_style(config.hurt_style)
    end
    for _, id in ipairs(config.sprites) do
      sprites[#sprites + 1] = enemy:create_sprite(id)
    end
    enemy._shots = 0
  end

  function enemy:on_restarted()
    enemy:set_damage(0)
    set_sprites(enemy, sprites, config.idle_animation or "walking", nil)
    enemy:choose_movement()
  end

  function enemy:on_movement_changed(movement)
    local direction = movement:get_direction4()
    set_sprites(enemy, sprites, nil, direction)
  end

  local function chase(hero)
    local distance = enemy:get_distance(hero)
    local melee = config.melee or 28
    local damage = config.damage(enemy)
    enemy:set_damage(distance <= melee and damage or 0)
    set_sprites(enemy, sprites, "walking", enemy:get_direction4_to(hero))
    local movement = sol.movement.create("path_finding")
    movement:set_speed(config.chase_speed or 56)
    movement:set_target(hero)
    sol.timer.start(enemy, 150, function()
      if enemy:get_map() == nil then
        return false
      end
      local hero_now = enemy:get_map():get_hero()
      local gap = enemy:get_distance(hero_now)
      if gap > config.awareness then
        enemy:stop_movement()
        enemy:choose_movement()
        return false
      end
      enemy:set_damage(gap <= melee and damage or 0)
      set_sprites(enemy, sprites, nil, enemy:get_direction4_to(hero_now))
      return true
    end)
    movement:start(enemy)
  end

  function enemy:choose_movement()
    local hero = enemy:get_map():get_hero()
    local distance = enemy:get_distance(hero)
    if distance > config.awareness then
      enemy:set_damage(0)
      enemy._next_shot = nil
      if config.wander then
        config.wander(enemy, sprites)
      else
        set_sprites(enemy, sprites, config.idle_animation or "stopped", nil)
        sol.timer.start(enemy, 200, function()
          if enemy:get_map() ~= nil then
            enemy:choose_movement()
          end
        end)
      end
      return
    end

    if config.shots ~= nil and enemy._shots < config.shots then
      enemy:set_damage(0)
      set_sprites(enemy, sprites, config.idle_animation or "stopped", enemy:get_direction4_to(hero))
      local now = sol.main.get_elapsed_time()
      local delay = config.shot_delay or 1100
      if enemy._next_shot == nil then
        enemy._next_shot = now + delay
      end
      if now < enemy._next_shot then
        sol.timer.start(enemy, 100, function()
          if enemy:get_map() ~= nil then
            enemy:choose_movement()
          end
        end)
        return
      end
      config.shoot(enemy, hero)
      enemy._shots = enemy._shots + 1
      enemy._next_shot = now + delay
      sol.timer.start(enemy, delay, function()
        if enemy:get_map() ~= nil then
          enemy:choose_movement()
        end
      end)
      return
    end

    chase(hero)
  end
end

function yard_enemy.wander_south(enemy, sprites)
  local _, map_height = enemy:get_map():get_size()
  local _, y = enemy:get_position()
  local band_top = map_height - 80
  local movement
  if y < band_top then
    movement = sol.movement.create("straight")
    movement:set_speed(36)
    movement:set_angle(3 * math.pi / 2)
    movement:set_max_distance(band_top - y + 16)
    movement:set_smooth(false)
  else
    movement = sol.movement.create("random")
    movement:set_speed(36)
    movement:set_max_distance(math.random(24, 64))
    movement:set_smooth(true)
  end
  local queued = false
  local function queue_next()
    if queued then
      return
    end
    queued = true
    sol.timer.start(enemy, 80, function()
      enemy:choose_movement()
    end)
  end
  function movement:on_finished()
    queue_next()
  end
  function movement:on_obstacle_reached()
    queue_next()
  end
  set_sprites(enemy, sprites, "walking", nil)
  movement:start(enemy)
end

function yard_enemy.shoot_fireball(enemy, hero)
  local map = enemy:get_map()
  local x, y, layer = enemy:get_position()
  local ball = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 8,
    height = 8,
    direction = enemy:get_direction4_to(hero),
  })
  ball:set_origin(4, 4)
  ball:set_can_traverse("hero", true)
  ball:set_can_traverse("enemy", true)
  ball:create_sprite("enemies/flame")
  local spent = false
  local function finish()
    if spent or ball:get_map() == nil then
      return
    end
    spent = true
    ball:remove()
  end
  ball:add_collision_test("overlapping", function(_, other)
    if other:get_type() ~= "hero" then
      return
    end
    other:start_hurt(ball, yard_enemy.SPELL_DAMAGE)
    finish()
  end)
  local movement = sol.movement.create("straight")
  movement:set_speed(176)
  movement:set_angle(enemy:get_angle(hero))
  movement:set_max_distance(yard_enemy.SPELL_RANGE / 2)
  movement:set_smooth(false)
  function movement:on_finished()
    finish()
  end
  function movement:on_obstacle_reached()
    finish()
  end
  movement:start(ball)
end

return yard_enemy
