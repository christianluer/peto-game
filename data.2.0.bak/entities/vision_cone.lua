local vision_cone = ...
local sprite
local enemy

-- Function checks if the hero sprite collided with the vision cone
--
-- entity -  A Solarus Map Entity that collided with the vision cone
--
-- Example
--   collision_handler(Solarus Map Entity)
--
-- Returns nothing
local function collision_handler(entity)
  if entity:get_type() == "hero" then enemy:hero_detected() end
end

vision_cone:add_collision_test("sprite", function(_,entity) collision_handler(entity) end)

-- Sets up the vision cone sprite
--
-- sprite_id - A string containg the directory where the sprite is located
--
-- Example
--   setup_sprite("entities/vision_cone")
--
-- Returns nothing
local function setup_sprite(sprite_id)
  sprite = vision_cone:create_sprite(sprite_id)
  sprite:set_animation("defualt")
end

-- Updated the sprite direction
--
-- dir - the enemy direction [0-3] please see Solarus sprite documentation for details.
--
-- Example
--   vision_cone:update_sprite_dir(0)
--
-- Returns nothing
function vision_cone:update_sprite_dir(dir)
  sprite:set_direction(dir)
end

-- Sets up the map entites size and origin point based on the sprites size
--
-- dir - the enemy direction [0-3] please see Solarus sprite documentation for details.
--
-- Example
--   setup_map_entity(0)
--
-- Returns nothing
local function setup_map_entity(dir)
  local sprite_x, sprite_y = sprite:get_size("defualt", dir)
  vision_cone:set_size(sprite_x,sprite_y)
  vision_cone:set_origin(math.floor(sprite_x/2), math.floor(sprite_y/2))
end

-- Sets the vision cone map enitiy to the right edge of the enemy's bounding box.
--
-- x - enemy x position (Number)
-- y - enemy y position (Number)
-- layer - enemy layer (Number)
-- enemy_width - enemy bounding box width
-- vision_cone_width - vision cone bounding box width
--
-- Example
--   right(136, 109, 0, 16, 100)
--
-- Returns nothing
local function right(x, y, layer, enemy_width, vision_cone_width)
  vision_cone:set_position(x + enemy_width/2 + vision_cone_width/2,y,layer)
end

-- Sets the vision cone map enitiy to the top edge of the enemy's bounding box.
--
-- x - enemy x position (Number)
-- y - enemy y position (Number)
-- layer - enemy layer (Number)
-- enemy_height - enemy bounding box height
-- vision_cone_height - vision cone bounding box height
--
-- Example
--   up(136, 109, 0, 16, 100)
--
-- Returns nothing
local function up(x, y, layer, enemy_height, vision_cone_height)
  vision_cone:set_position(x,y - enemy_height/2 - vision_cone_height/2,layer)
end

-- Sets the vision cone map enitiy to the left edge of the enemy's bounding box.
--
-- x - enemy x position (Number)
-- y - enemy y position (Number)
-- layer - enemy layer (Number)
-- enemy_width - enemy bounding box width
-- vision_cone_width - vision cone bounding box width
--
-- Example
--   left(136, 109, 0, 16, 100)
--
-- Returns nothing
local function left(x, y, layer, enemy_width, vision_cone_width)
  vision_cone:set_position(x - enemy_width/2 - vision_cone_width/2,y,layer)
end

-- Sets the vision cone map enitiy to the bottom edge of the enemy's bounding box.
--
-- x - enemy x position (Number)
-- y - enemy y position (Number)
-- layer - enemy layer (Number)
-- enemy_height - enemy bounding box height
-- vision_cone_height - vision cone bounding box height
--
-- Example
--   down(136, 109, 0, 16, 100)
--
-- Returns nothing
local function down(x, y, layer, enemy_height, vision_cone_height)
  vision_cone:set_position(x,y + enemy_height/2 + vision_cone_height/2,layer)
end

-- Updates enemy's vision cone
--
-- enemy - A Solarus Enemy object
--
-- Example
--   vision_cone:update_direction(Solarus Enemy object)
--
-- Returns nothing
function vision_cone:update_direction(enemies)
  local enemy_dir = enemies:get_sprite():get_direction()
  local enemy_x, enemy_y, enemy_layer = enemies:get_center_position()
  local enemy_size_x, enemy_size_y = enemies:get_size()
  local vs_size_x, vs_size_y = vision_cone:get_size()

  local facing = { [0] = right, [1] = up, [2] = left, [3] = down}
  local func = facing[enemy_dir]
  if (func) then
    if enemy_dir == 0 or enemy_dir == 2 then func(enemy_x, enemy_y, enemy_layer, enemy_size_x, vs_size_x)
    else func(enemy_x, enemy_y, enemy_layer, enemy_size_y, vs_size_y)
    end
  end
end

-- Called when a vision cone map entity is needing to be created.
--
-- enemy_ref - A Solarus Enemy object
--
-- Example
--   vision_con:start(Solarus Enemy Object)
--
-- Returns nothing
function vision_cone:setup_vision_cone(enemy_ref)
  enemy = enemy_ref
  setup_sprite("entities/vision_cone")
  vision_cone:update_sprite_dir(enemy_ref:get_sprite():get_direction())
  setup_map_entity(enemy_ref:get_sprite():get_direction())
  vision_cone:update_direction(enemy_ref)
end
