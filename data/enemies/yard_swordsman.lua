-- Soldier body plus a sword sprite. Wanders the south edge until the hero
-- is close enough to notice, then walks in and the sword hits at melee range.
-- Notice range is four 16px tiles shorter than the hero's spell.

local enemy = ...

local AWARENESS = 230
local MELEE = 28
local WANDER_SPEED = 36
local CHASE_SPEED = 56
local BAND_HEIGHT = 80

local sword_damage = 1
local body
local sword

local function set_direction(direction)
  if direction == nil then
    return
  end
  body:set_direction(direction)
  sword:set_direction(direction)
end

local function set_animation(animation)
  if body:has_animation(animation) then
    body:set_animation(animation)
  end
  if sword:has_animation(animation) then
    sword:set_animation(animation)
  end
end

function enemy:on_created()
  sword_damage = enemy:get_game():get_ability("sword")
  if sword_damage < 1 then
    sword_damage = 1
  end

  enemy:set_life(4)
  enemy:set_damage(0)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_pushed_back_when_hurt(true)
  body = enemy:create_sprite("enemies/soldier")
  sword = enemy:create_sprite("enemies/soldier_sword")
end

function enemy:on_restarted()
  enemy:set_damage(0)
  set_animation("walking")
  enemy:choose_movement()
end

function enemy:on_movement_changed(movement)
  set_direction(movement:get_direction4())
end

function enemy:choose_movement()
  local hero = enemy:get_map():get_hero()
  local distance = enemy:get_distance(hero)
  local movement

  if distance <= AWARENESS then
    enemy:set_damage(distance <= MELEE and sword_damage or 0)
    set_direction(enemy:get_direction4_to(hero))
    movement = sol.movement.create("path_finding")
    movement:set_speed(CHASE_SPEED)
    movement:set_target(hero)
    sol.timer.start(enemy, 150, function()
      local hero_now = enemy:get_map():get_hero()
      local gap = enemy:get_distance(hero_now)
      if gap > AWARENESS then
        enemy:stop_movement()
        enemy:choose_movement()
        return false
      end
      enemy:set_damage(gap <= MELEE and sword_damage or 0)
      set_direction(enemy:get_direction4_to(hero_now))
      return true
    end)
  else
    enemy:set_damage(0)
    local _, map_height = enemy:get_map():get_size()
    local _, y = enemy:get_position()
    local band_top = map_height - BAND_HEIGHT
    if y < band_top then
      movement = sol.movement.create("straight")
      movement:set_speed(WANDER_SPEED)
      movement:set_angle(3 * math.pi / 2)
      movement:set_max_distance(band_top - y + 16)
      movement:set_smooth(false)
    else
      movement = sol.movement.create("random")
      movement:set_speed(WANDER_SPEED)
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
  end

  movement:start(enemy)
end
