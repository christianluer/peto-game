-- Lua script of map demo_map/start_map.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local npc = map:get_entity("NPC_Knight")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  function npc:on_interaction()
    game:start_dialog('demo.start_dialog')
    end
end
