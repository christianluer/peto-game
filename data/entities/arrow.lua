-- Arrow shot by the bow.
-- Replaces the built-in one to allow silver arrows.

local arrow = ...
local map = arrow:get_map()
local hero = map:get_hero()
local direction = hero:get_direction()
local sprite_id
local sprite


-- Set traverseable objects that the arrow can traverse
local traverse = {"crystal", "crystal_block", "hero", "jumper", "stream", "switch","teletransporter"}
for _, value in ipairs(traverse) do arrow:set_can_traverse(value, true) end

-- Set traverseable object that the arrow can NOT traverse
arrow:set_can_traverse("stairs", false)

-- Set traverseable ground objects that the arrow can traverse
local traverse_ground ={ "deep_water", "shallow_water", "hole", "lava", "prickles", "low_wall"}
for _, value in ipairs(traverse_ground) do arrow:set_can_traverse_ground(value, true) end

arrow.apply_cliffs = true

-- Once reached animation is complete the animation is set back to frame 0 unill the arrow is removed by the timmer.
--
-- Example
-- N/A
-- Returns nothing
local function reached_animation_complete()
  sprite:set_frame(0)
  sprite:set_paused(true)
  sol.timer.start(map, 1000, function() arrow:remove()end)
end

-- Function sets the reached obstacle animation and stop the arrow movement
--
-- Example
-- N/A
-- Returns nothing
local function attach_to_obstacle()
  sprite:set_animation("reached_obstacle",function() reached_animation_complete() end)
  arrow:stop_movement()
end

-- This handle when the arrow collides with something.
--
-- Example
-- N/A
-- Returns nothing
local function collision_handler(_, entity)
  if entity:get_type() == "enemy" then
    local enemy_sprite = entity:get_sprite()
    entity:hurt(1)
    if entity:get_life() <= 0 and
        enemy_sprite ~= nil and
        enemy_sprite:get_animation() ~= "hurt" then
          arrow:remove()
    end
  end

-- Add collisions checks here.
end

arrow:add_collision_test("sprite", function(projectile, entity) collision_handler(projectile, entity) end)
arrow:add_collision_test("overlapping", function(projectile, entity) collision_handler(projectile, entity) end)

-- Sets up the sprite for arrow
--
-- Example
-- N/A
-- Returns nothing
local function setup_sprite()
  sprite = arrow:create_sprite(sprite_id)
  sprite:set_animation("flying")
  sprite:set_direction(direction)
  local sprite_x, sprite_y = sprite:get_size("flying", direction)
  arrow:set_size(sprite_x,sprite_y)
  arrow:set_origin(math.floor(sprite_x / 2), math.floor(sprite_y / 2))
end

-- Sets up the movement for arrow
--
-- Example
-- N/A
-- Returns nothing
local function setup_movement()
  local movement = sol.movement.create("straight")
  local angle = direction * math.pi / 2
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  local width, height = map:get_size()
  local dist = math.max(width, height) + 24
  movement:set_max_distance(dist)
  movement:start(arrow)
end

-- Called when the arrow reaches an obstacle
--
-- Example
-- N/A
-- Returns nothing
function arrow:on_obstacle_reached()
  attach_to_obstacle()
end

-- Start the setups for the arrow to fire
--
-- Example
-- N/A
-- Return
function arrow:start()
  sprite_id = "entities/arrow"
  setup_sprite()
  setup_movement()
end