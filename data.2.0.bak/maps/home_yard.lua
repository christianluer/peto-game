-- Lua script of map home_yard.
-- The grass outside the hero's cottage. Draft layout, not story canon.

local map = ...

function map:on_started()
  if sol.audio.get_music() ~= "eduardo/village" then
    sol.audio.play_music("eduardo/village")
  end
end

function map:on_opening_transition_finished()

end
