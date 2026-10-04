-- Lua script of map home_yard.
-- The grass outside the hero's cottage. Draft layout, not story canon.

local map = ...

function map:on_started()
  if sol.audio.get_music() ~= "eduardo/village" then
    sol.audio.play_music("eduardo/village")
  end

  local _, map_height = map:get_size()
  if map:get_entity("from_fair") == nil then
    map:create_destination({
      name = "from_fair",
      layer = 0,
      x = 256,
      y = map_height - 48,
      direction = 1,
    })
  end

  local fair_open = false
  local function try_open_fair()
    if fair_open or map:get_entities_count("yard_clucko") > 0 or map:get_entities_count("yard_turtle") > 0 then
      return
    end
    fair_open = true
    map:create_teletransporter({
      layer = 0,
      x = 240,
      y = map_height - 16,
      width = 32,
      height = 16,
      destination_map = "fair_carriages",
      destination = "from_yard",
      transition = "fade",
    })
  end

  local map_width, map_height = map:get_size()
  local turtle = map:create_enemy({
    name = "yard_turtle",
    breed = "yard_turtle",
    x = map_width - 96,
    y = map_height - 64,
    layer = 0,
    direction = 3,
  })
  if turtle ~= nil then
    function turtle:on_dead()
      try_open_fair()
    end
  end

  local clucko_spots = { { 112, 48 }, { 144, 72 }, { 176, 48 } }
  for i, spot in ipairs(clucko_spots) do
    map:create_enemy({
      name = "yard_clucko_" .. i,
      breed = "yard_clucko",
      x = spot[1],
      y = spot[2],
      layer = 0,
      direction = 3,
    })
    local clucko = map:get_entity("yard_clucko_" .. i)
    if clucko ~= nil then
      function clucko:on_dead()
        try_open_fair()
      end
    end
  end
  try_open_fair()
end

function map:on_opening_transition_finished()

end
