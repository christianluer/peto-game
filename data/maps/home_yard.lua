-- Lua script of map home_yard.
-- The grass outside the hero's cottage. Draft layout, not story canon.

local map = ...

local function find_south_spawn(map)
  local map_width, map_height = map:get_size()
  local y = map_height - 32
  local x = math.floor(map_width / 2 / 8) * 8
  if map:get_ground(x, y, 0) == "traversable" then
    return x, y
  end
  for step = 16, map_width, 16 do
    for _, try_x in ipairs({ x - step, x + step }) do
      if try_x > 16 and try_x < map_width - 16
          and map:get_ground(try_x, y, 0) == "traversable" then
        return try_x, y
      end
    end
  end
  return x, y
end

function map:on_started()
  if sol.audio.get_music() ~= "eduardo/village" then
    sol.audio.play_music("eduardo/village")
  end

  local x, y = find_south_spawn(map)
  map:create_enemy({
    name = "yard_swordsman",
    breed = "yard_swordsman",
    x = x,
    y = y,
    layer = 0,
    direction = 3,
  })
end

function map:on_opening_transition_finished()

end
