local point = ...
local enemy_ref
-- local sprite_dir = "entities/arrow"
-- local sprite_anim = "flying"

-- Handles what to do on check collision with an object
--
-- entity - A Solarus Map Entity that collided with check
--
-- Example
--   collision_handler(Solarus Map Enitity)
--
-- Returns nothing
local function collision_handler(entity)
  if entity:get_type() == "enemy" then
	  point:set_enabled(false)
	  enemy_ref:point_hit()
  end
end

-- Called by Solarus when the center point collides with something.
point:add_collision_test("center", function(_, entity) collision_handler(entity) end)

-- local function setup_sprite()
-- 	local sprite = point:create_sprite(sprite_dir)
-- 	sprite:set_animation(sprite_anim)
-- 	sprite:set_direction(point:get_direction())
-- end

-- Function called by enemy's vision cone detects the hero
--
-- enemy_ref - Solarus Enemy Entity
-- hero_ref - Solarus Hero Entity
--
-- Example
--   check:send(Solarus Enemy Entity, Solarus Hero Entity)
--
-- Returns nothing
function point:set(x, y, layer)

	point:set_enabled(true)
	--setup_sprite()
  point:set_position(x, y, layer)
  point:set_size(16,16)
end

-- Sets the enemy_ref to the enemy
function point:set_enemy_ref(enemy)
	enemy_ref = enemy
end
