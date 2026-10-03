-- Lua script of map home_yard.
-- The grass outside the hero's cottage. Draft layout, not story canon.

local map = ...

local function south_spots(map)
  local map_width, map_height = map:get_size()
  local y = map_height - 32
  local spots = {}
  for x = 32, map_width - 32, 16 do
    if map:get_ground(x, y, 0) == "traversable" then
      spots[#spots + 1] = x
    end
  end
  if #spots == 0 then
    spots[1] = math.floor(map_width / 2 / 8) * 8
  end
  return spots, y
end

function map:on_started()
  if sol.audio.get_music() ~= "eduardo/village" then
    sol.audio.play_music("eduardo/village")
  end

  local spots, y = south_spots(map)
  local count = math.random(1, 3)
  count = math.min(count, #spots)
  for i = 1, count do
    local index = math.floor((i - 0.5) * #spots / count) + 1
    map:create_enemy({
      name = "yard_swordsman_" .. i,
      breed = "yard_swordsman",
      x = spots[index],
      y = y,
      layer = 0,
      direction = 3,
    })
  end

  local map_width, map_height = map:get_size()
  local gate_x = map_width - 16
  local gate_y = 160
  for try = 160, map_height - 48, 16 do
    if map:get_ground(gate_x, try, 0) == "traversable" then
      gate_y = try
      break
    end
  end
  if map:get_entity("from_fair") == nil then
    map:create_destination({
      name = "from_fair",
      layer = 0,
      x = gate_x - 24,
      y = gate_y,
      direction = 2,
    })
  end
  map:create_teletransporter({
    layer = 0,
    x = gate_x,
    y = gate_y - 16,
    width = 16,
    height = 48,
    destination_map = "fair_carriages",
    destination = "from_yard",
    transition = "fade",
  })
end

function map:on_opening_transition_finished()

end
