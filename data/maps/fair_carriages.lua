-- Draft scenery. Carriages at a fair.
-- Calder opens the chat on G. The troupe says one fixed line each on G.
-- Arliden and Laurian are the parents. Trip, Teren, and Shandi are the friends.

local map = ...

local people = {
  { name = "fair_teacher", sprite = "npc/old_man", x = 200, y = 248, direction = 0, chat_who = { key = "teacher", label = "Calder" } },
  { name = "fair_arliden", sprite = "npc/green_hat_man", x = 272, y = 224, direction = 2, dialog_id = "fair.arliden" },
  { name = "fair_laurian", sprite = "npc/blonde_woman", x = 272, y = 272, direction = 2, dialog_id = "fair.laurian" },
  { name = "fair_trip", sprite = "npc/red_hood_man", x = 328, y = 208, direction = 2, dialog_id = "fair.trip" },
  { name = "fair_teren", sprite = "npc/blue_haired_boy", x = 328, y = 288, direction = 2, dialog_id = "fair.teren" },
  { name = "fair_shandi", sprite = "npc/bun_woman", x = 376, y = 248, direction = 2, dialog_id = "fair.shandi" },
}

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
    npc:set_traversable(true)
    function npc:on_interaction()
    end
    npc.chat_who = person.chat_who
    npc.dialog_id = person.dialog_id
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
