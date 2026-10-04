-- Draft scenery. Carriages at a fair.
-- Calder opens the chat on F. The troupe says one fixed line each on F.
-- Arliden and Laurian are the parents. Trip, Teren, and Shandi are the friends.

local map = ...

local people = {
  { name = "fair_teacher", sprite = "npc/old_man", x = 200, y = 248, direction = 0, chat_who = { key = "teacher", label = "Calder" } },
  { name = "fair_arliden", sprite = "npc/green_hat_man", x = 272, y = 224, direction = 2, line = "Keep the song in your mouth, not on the paper. The road listens harder than any crowd." },
  { name = "fair_laurian", sprite = "npc/blonde_woman", x = 272, y = 272, direction = 2, line = "Stay where I can see you. A fair is a kind place until it isn't." },
  { name = "fair_trip", sprite = "npc/red_hood_man", x = 328, y = 208, direction = 2, line = "If they laugh, bow. If they don't, bow anyway. That's the whole trick." },
  { name = "fair_teren", sprite = "npc/blue_haired_boy", x = 328, y = 288, direction = 2, line = "The wagons are hitched. We leave when the song is finished, not before." },
  { name = "fair_shandi", sprite = "npc/bun_woman", x = 376, y = 248, direction = 2, line = "Don't wander past the last carriage. That's where the fair ends." },
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
    npc.line = person.line
  end

  local width, height = map:get_size()
  for i = 1, 5 do
    map:create_enemy({
      name = "fair_slime_" .. i,
      breed = "yard_slime",
      x = width - 96 - ((i - 1) % 3) * 28,
      y = math.floor(height / 2) - 24 + math.floor((i - 1) / 3) * 32,
      layer = 0,
      direction = 2,
    })
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
