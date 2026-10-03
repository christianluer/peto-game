local check = ...
local enemy

-- Set objects the check can traverse
local traverse = {"crystal", "crystal_block","hero", "jumper", "stream", "switch","teletransporter"}
for _, value in ipairs(traverse) do check:set_can_traverse(value, true) end

-- Set NON traversable check objects
check:set_can_traverse("stairs", false)

-- Set traverseable ground objects that the check can traverse
local traverse_ground ={ "deep_water", "shallow_water", "hole", "lava", "prickles", "low_wall"}
for _, value in ipairs(traverse_ground) do check:set_can_traverse_ground(value, true) end

-- Handles what to do on check collision with an object
--
-- entity - A Solarus Map Entity that collided with check
--
-- Example
--   collision_handler(Solarus Map Enitity)
--
-- Returns nothing
local function collision_handler(entity)
  if entity:get_type() == "hero" then
    check:set_enabled(false)
    enemy:increase_awareness()
  end
end

check:add_collision_test("overlapping", function(_, entity) collision_handler(entity) end)

-- Callback function called when movement finished
--
-- Returns nothing
local function movement_finished()
  check:set_enabled(false)
end

-- Function called by solarus when a obstacle is reched
--
-- Example
--   N/A
--
-- Returns nothing
function check:on_obstacle_reached()
  check:set_enabled(false)
end

-- Setup the check entity
--
-- enemy_x - enemy x position (Number)
-- enemy_y - enemy y position (Number)
-- enemy_layer - enemy layer (Number)
--
-- Example
--   setup_map_entity(5,20,0)
--
-- Returns nothing
local function setup_map_entity(enemy_x, enemy_y, enemy_layer)
  check:set_enabled(true)
  check:set_position(enemy_x, enemy_y, enemy_layer)
  check:set_size(8,8)
end

-- Setup the check map entity's movement
--
-- angle - the angle in radians between the origin points of enemy and hero (Number)
-- dist -  the distance between enemy and hero (Number)
--
-- Example
--   setup_movement(2.2, 33)
--
-- Returns nothing
local function setup_movement(angle, dist)
  local movement = sol.movement.create("straight")
  movement:set_speed(500)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:set_max_distance(dist)
  movement:start(check, function() movement_finished()end)
end

-- Function called by enemy's vision cone detects the hero
--
-- enemy_ref - Solarus Enemy Entity
-- hero_ref - Solarus Hero Entity
--
-- Example
--   check:send(Solarus Enemy Entity, Solarus Hero Entity)
--
-- Returns nothing
function check:send(enemy_ref,hero_ref)
  enemy = enemy_ref
  setup_map_entity(enemy_ref:get_center_position())
  setup_movement(enemy_ref:get_angle(hero_ref),check:get_distance(hero_ref) + 24)
end
