-- Overrides default bow. The bow is assumed to be item slot 1. Only allows for bow
-- to be fired when both fire button is depressed and bow ready animation on hero is done
-- Allows for strafing

local item = ...
local bow_readied, bow_command_released
local map = nil
local hero = nil
local hero_tunic_sprite = nil
local game = item:get_game()

-- Starting function that sets up the save game variable and makes item assignable
--
-- Returns nothing
function item:on_created()
  self:set_savegame_variable("i1102")
  self:set_assignable(true)
end

-- Called from the Solarus Engine when player uses the item
--
-- Returns nothing
function item:on_using()
  map = item:get_map()
  hero = map:get_hero()
  hero_tunic_sprite = hero:get_sprite()
  if game:is_suspended() then return end -- check if game is suspended as early as possible to avoid wasting resources

  hero:freeze()
  bow_readied, bow_command_released = false, false
  hero_tunic_sprite:set_animation("bow", function () item:prepared_to_fire() end)
end

-- Function called when the item button is released (Called by Solarus only)
--
-- command - name of the game command button command being released.
--
-- Return true (So Solarus doen't propogate to other Event functions)
function game:on_command_released(command)
  if command == "item_1" then
    bow_command_released = true
    item:try_to_fire()
    return true
  end
end

-- This function is called when the bow animation is complete
--
-- Return nothing
function item:prepared_to_fire()
    local dir = hero:get_direction()
    hero:lock_direction("bow_stopped", "bow_walking",dir)
    hero:unfreeze()
    bow_readied = true
    self:try_to_fire()
end

-- only fire when both ready animation is done AND item botton is released
--
-- Returns nothing
function item:try_to_fire()
  if bow_command_released and bow_readied then
    self:shoot_arrow()
    bow_command_released, bow_readied = false, false
  end
end

-- Spawns the arrow on the map
--
-- Returns nothing
function item:shoot_arrow()
  map = self:get_map()
  local dir = hero:get_direction()
  local x, y, layer = hero:get_center_position()

  hero:freeze()
  hero_tunic_sprite:set_animation("bow_finished", function() item:finish_using() end)

  local arrow_shift = {}
  for i = 0,3 do arrow_shift[i] = {x = 0, y = 0} end
  x = x + arrow_shift[dir].x
  y = y + arrow_shift[dir].y

  local prop = {model = "arrow", x = x, y = y, layer = layer, direction = dir, width = 16, height = 16}
  local arrow = map:create_custom_entity(prop)
  arrow:start()
end

-- Called when the map changes and call the finish using fuction if the item was used on the previous map
-- (Called only by Solarus)
--
-- Returns nothing
function item:on_map_changed(_)
  if hero ~= nil then self:finish_using() end
end

-- Set the hero the the neutral postion and tells the engine the item is finished being used.
--
-- Returns nothing
function item:finish_using()
  hero:lock_direction()
  hero:unfreeze()
  self:set_finished()
end
