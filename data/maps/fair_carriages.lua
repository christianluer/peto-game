-- Draft scenery. Carriages at a fair, a family, and an old man.
-- Nobody speaks yet.

local map = ...

local people = {
  { name = "fair_teacher", sprite = "npc/old_man", x = 200, y = 248, direction = 0 },
  { name = "fair_father", sprite = "npc/green_hat_man", x = 272, y = 224, direction = 2 },
  { name = "fair_mother", sprite = "npc/blonde_woman", x = 272, y = 272, direction = 2 },
  { name = "fair_son", sprite = "npc/blond_boy", x = 320, y = 216, direction = 2 },
  { name = "fair_child", sprite = "npc/blue_haired_boy", x = 320, y = 280, direction = 2 },
  { name = "fair_aunt", sprite = "npc/bun_woman", x = 368, y = 248, direction = 2 },
}

local function silent(npc)
  npc:set_traversable(true)
  function npc:on_interaction()
  end
end

function map:on_started()
  if sol.audio.get_music() ~= "eduardo/overworld" then
    sol.audio.play_music("eduardo/overworld")
  end

  for _, person in ipairs(people) do
    local npc = map:create_npc({
      name = person.name,
      layer = 0,
      x = person.x,
      y = person.y,
      direction = person.direction,
      subtype = 1,
      sprite = person.sprite,
    })
    if person.name == "fair_teacher" then
      npc:set_traversable(true)
      function npc:on_interaction()
        companion.open_chat(map:get_game(), { key = "teacher", label = "Calder" })
      end
    else
      silent(npc)
    end
  end

  map:create_teletransporter({
    layer = 0,
    x = 0,
    y = 168,
    width = 16,
    height = 48,
    destination_map = "home_yard",
    destination = "from_fair",
    transition = "fade",
  })
end
