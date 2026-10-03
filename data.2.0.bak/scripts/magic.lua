-- Magic meter. The bar sprite already lives in sprites/hud/magic_bar.png.
-- A full bar is 84 points, which fills that sprite.
-- Holding the sword and releasing a spin attack spends MAGIC_SPIN_COST.
-- The bar refills on its own while the hero is not charging or spinning.

local MAX_MAGIC = 84
local MAGIC_SPIN_COST = 12
local REFILL_DELAY = 800

require("scripts/multi_events")

local game_meta = sol.main.get_metatable("game")
local hero_meta = sol.main.get_metatable("hero")

local function is_sword_charge(state)
  return state == "sword loading"
    or state == "sword_loading"
    or state == "sword spin attack"
    or state == "sword_spin_attack"
end

local function allow_spin_if_magic(game)
  local can_spin = game:get_magic() >= MAGIC_SPIN_COST
  local level = can_spin and 1 or 0
  if game:get_ability("sword_spin_attack") ~= level then
    game:set_ability("sword_spin_attack", level)
  end
end

local function give_magic_meter(game)
  if game:get_max_magic() == 0 then
    game:set_max_magic(MAX_MAGIC)
    game:set_magic(MAX_MAGIC)
  end
  allow_spin_if_magic(game)
end

game_meta:register_event("on_started", function(game)
  give_magic_meter(game)

  sol.timer.start(game, REFILL_DELAY, function()
    local map = game:get_map()
    if map ~= nil then
      local state = map:get_hero():get_state()
      if not is_sword_charge(state) and game:get_magic() < game:get_max_magic() then
        game:add_magic(1)
      end
    end
    allow_spin_if_magic(game)
    return true
  end)
end)

hero_meta:register_event("on_state_changed", function(hero, state)
  if state == "sword spin attack" or state == "sword_spin_attack" then
    local game = hero:get_game()
    game:remove_magic(math.min(MAGIC_SPIN_COST, game:get_magic()))
    allow_spin_if_magic(game)
  end
end)
