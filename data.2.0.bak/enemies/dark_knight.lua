local enemy = ...
--local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local vision_cone
local check
local point
local awareness = 0
--local awareness_max = 100
local awareness_degrade_time = 300
local awareness_degrade_value = 2
local defualt_movement = nil
local defualt_x, defualt_y, defualt_layer = enemy:get_center_position()
local defualt_dir
local is_suspicious = false
local suspicion_level =  25
local is_alerted = false
local alert_level = 50

-- Updates the enemy and vision cone sprites direction
--
-- dir - the direction [0-3] please see Solarus sprite documentation for details.
--
-- Example
--   update_direction(0)
--
-- Returns nothing
local function update_direction(dir)
  enemy:get_sprite():set_direction(dir)
  vision_cone:update_sprite_dir(dir)
end

local function set_point(x, y, layer)
  point:set(x, y, layer)
end

-- Sets the movement for enemy
--
-- move_type - Name of the movement type, please see Solarus movement documentation for details (String)
-- speed - The speed in pixels per second.(Number)
-- smooth - Determine if the movement is smooth, please see Solarus straight movement documentation for details (Boolean)
-- distance - The maximum distance in pixels.(Number)
-- callback - A function to call when the movement finishes.(Function)
-- angle - The direction angle in radians.(Number)
-- target - The target of the movement.(Entity)
--
-- Example
--   set_movement("straight", 48, false, 29, suspicious_move_end, 3.4198923125949, hero)
--
-- Returns nothing
local function set_movement(move_type, speed, smooth, distance, callback, angle, target)
  local movement = sol.movement.create(move_type)
  movement:set_speed(speed)
  if move_type == "path_finding" then
    movement:set_target(target)
  else -- movement either straight or random
    movement:set_smooth(smooth)
    movement:set_max_distance(distance)
    if move_type == "straight" then movement:set_angle(angle) end
  end
  movement:start(enemy,function() callback() end)
end

-- Returns entity back to it's original patrol route.
local function return_to_patrol_route()
  enemy:get_sprite():set_direction(defualt_dir)
  update_direction(defualt_dir)
  vision_cone:update_direction(enemy)
  if defualt_movement ~= nil then defualt_movement:start(enemy) end
end

-- Returns the enemy to the non alert state
local function alert_end()
  is_suspicious = false
  -- Sends the enemy back to it's original patrol
  set_point(defualt_x, defualt_y, defualt_layer)
  set_movement("path_finding",48, nil, nil, return_to_patrol_route, nil, point)
  --set_movement("straight",48, false, enemy:get_distance(defualt_x,defualt_y), return_to_patrol_route, enemy:get_angle(defualt_x,defualt_y))
end

-- Starts the awareness degrade timer
local function start_awareness_degrade()
  sol.timer.start(enemy, awareness_degrade_time, function()
    awareness = awareness - awareness_degrade_value
    if awareness < suspicion_level then is_alerted = false end
    if awareness > 0 then return true
    elseif is_suspicious == true then alert_end() end
  end)
end

-- When enemy is created the sprite is created, the life and damage are set
--
-- Example
--   N/A
--
-- Returns nothing
function enemy:on_created()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(2)
  enemy:set_damage(1)

  local dir = enemy:get_sprite():get_direction()
  local x, y, layer = enemy:get_center_position()
  local prop = {model = "check", x = x, y = y, layer = layer, direction = dir, width = 16, height = 16, enabled_at_start = false}
  check = map:create_custom_entity(prop)

  prop = {model = "point", x = 0, y = 0, layer = 0, direction = 0, width = 8, height = 8, enabled_at_start = false}
  point = map:create_custom_entity(prop)
  point:set_enemy_ref(enemy)
end

-- Called when the enemy is restarted by the engine
--
-- Example
--   N/A
--
-- Returns nothing
function enemy:on_restarted()
  local dir = enemy:get_sprite():get_direction()
  local x, y, layer = enemy:get_center_position()
  local prop = {model = "vision_cone", x = x, y = y, layer = layer, direction = dir, width = 16, height = 16}
  vision_cone = map:create_custom_entity(prop)
  vision_cone:setup_vision_cone(enemy)
  defualt_dir = dir
end

-- Function called by Solarus when the enemy's movement changes
--
-- move - Solarus Movement Object
--
-- Example
--   N/A
--
-- Returns nothing
function enemy:on_movement_changed(move)
  update_direction(move:get_direction4())
end

-- Function called by Solarus when the enemy's position changes
--
-- Example
--   N/A
-- Returns
function enemy:on_position_changed()
  vision_cone:update_direction(enemy)
end

-- Sets the search movement apon reaching the point where the hero was last spotted.
-- local function suspicious_move_end()
--   set_movement("random", 48, false, 16)
-- end

-- Moves the enemy to where hero was last spotted.
local function suspicious()
  if is_suspicious == false then
    defualt_movement = enemy:get_movement()
    defualt_dir = enemy:get_sprite():get_direction()
    is_suspicious = true
  end
end

-- Sets the hero as the target of enemy movement.
local function alert()
  if is_alerted == false then
    set_movement("path_finding", 55, nil, nil, nil, nil, hero)
    is_alerted = true
  end
end

-- Function called by vision cone when the hero is detected
function enemy:hero_detected()
  if check:is_enabled() == false then
    check:send(enemy, hero)
  end
end

-- Increse the awarness metter
function enemy:increase_awareness()
  if awareness <= 0 then
    awareness = 0
    start_awareness_degrade()
  end

  awareness = awareness + 6
  if (awareness >= suspicion_level or is_suspicious == true) and is_alerted == false then
     suspicious()
  end
  if awareness >= alert_level then  alert() end
end

function enemy:point_hit()
  --local x, y, layer = point:get_position()
  -- local callback
  -- if is_suspicious == true then callback = suspicious_move_end
  -- else callback = return_to_patrol_route end
end
