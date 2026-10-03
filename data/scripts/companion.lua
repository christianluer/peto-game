-- A companion who follows the hero, never fights, and opens a chat.
-- The name Denna is a draft Christian asked for, in the manner of that lover.
-- Press the action key while facing them to talk.

local companion_llm = require("scripts/companion_llm")
require("scripts/multi_events")

local SPRITE = "npc/woman_1a" -- woman type 1, sprites/npc/woman_type1_a.png
local TILE = 16
local FOLLOW_DISTANCE = 5 * TILE
local FOLLOW_SPEED = 64
-- Usual talk reach is 32 pixels. This is that reach, half again as wide.
local TALK_RANGE = 48
local MAX_INPUT = 72
local PANEL_W = 320
local PANEL_H = 200
local PANEL_Y = 32
local TEXT_W = PANEL_W - 16
local LINE_H = 16
local INPUT_Y = PANEL_H - 22
local VISIBLE_LINES = math.floor((INPUT_Y - 8) / LINE_H)

local chat_menu = {}
local chat_open = false

local function text_width(text)
  local surface = sol.text_surface.create({
    font = "enter_command",
    font_size = 16,
    text = text,
  })
  return surface:get_size()
end

local function wrap_line(speaker, text)
  local prefix = speaker .. ": "
  local words = {}
  for word in text:gmatch("%S+") do
    words[#words + 1] = word
  end
  if #words == 0 then
    return { prefix }
  end
  local lines = {}
  local current = prefix
  for _, word in ipairs(words) do
    local trial = current == prefix and (prefix .. word) or (current .. " " .. word)
    if text_width(trial) <= TEXT_W then
      current = trial
    else
      if current ~= "" then
        lines[#lines + 1] = current
      end
      current = word
      while text_width(current) > TEXT_W and #current > 1 do
        local cut = current
        while text_width(cut) > TEXT_W and #cut > 1 do
          cut = cut:sub(1, -2)
        end
        lines[#lines + 1] = cut
        current = current:sub(#cut + 1)
      end
    end
  end
  lines[#lines + 1] = current
  return lines
end

local function fit_tail(text)
  local shown = text
  while text_width(shown) > TEXT_W and #shown > 1 do
    shown = shown:sub(2)
  end
  return shown
end

local function lines_for(game)
  local key = chat_menu.who and chat_menu.who.key or "denna"
  if game._chat_lines == nil then
    game._chat_lines = {}
  end
  if game._chat_lines[key] == nil then
    game._chat_lines[key] = {}
  end
  return game._chat_lines[key]
end

local function push_message(game, speaker, text)
  local shown = lines_for(game)
  for _, line in ipairs(wrap_line(speaker, text)) do
    shown[#shown + 1] = line
  end
  while #shown > 80 do
    table.remove(shown, 1)
  end
  chat_menu.scroll = nil
end

function chat_menu:on_started()
  chat_open = true
  self.game:set_suspended(true)
  self.input = ""
  self.waiting = false
  local who = self.who or { key = "denna", label = "Denna" }
  self.who = who
  local shown = lines_for(self.game)
  if #shown == 0 then
    if who.key == "teacher" then
      push_message(self.game, who.label, "Stand still. If you shout at the air, it will not answer.")
    else
      push_message(self.game, who.label, "There you are. I was beginning to think you'd forgotten my name.")
    end
  end
end

function chat_menu:on_finished()
  chat_open = false
  self.game:set_suspended(false)
end

function chat_menu:line_window()
  local lines = lines_for(self.game)
  local max_start = math.max(1, #lines - VISIBLE_LINES + 1)
  local start_at = self.scroll or max_start
  if start_at < 1 then
    start_at = 1
  end
  if start_at > max_start then
    start_at = max_start
  end
  return lines, start_at, max_start
end

function chat_menu:scroll_by(delta)
  local _, start_at, max_start = self:line_window()
  start_at = start_at + delta
  if start_at >= max_start then
    self.scroll = nil
  else
    self.scroll = math.max(1, start_at)
  end
end

function chat_menu:on_draw(dst)
  local panel = sol.surface.create(PANEL_W, PANEL_H)
  panel:fill_color({ 20, 16, 28, 230 })
  local lines, start_at = self:line_window()
  local last = math.min(#lines, start_at + VISIBLE_LINES - 1)
  for i = start_at, last do
    local surface = sol.text_surface.create({
      font = "enter_command",
      font_size = 16,
      color = { 240, 224, 190 },
      text = lines[i],
    })
    surface:draw(panel, 6, 4 + (i - start_at) * LINE_H)
  end
  local prompt = "> " .. (self.input or "")
  if self.waiting then
    prompt = "> ..."
  end
  local input_surface = sol.text_surface.create({
    font = "enter_command",
    font_size = 16,
    color = { 255, 255, 255 },
    text = fit_tail(prompt),
  })
  input_surface:draw(panel, 6, INPUT_Y)
  panel:draw(dst, 0, PANEL_Y)
end

function chat_menu:submit()
  local text = self.input
  if text == nil or text == "" or self.waiting then
    return
  end
  self.input = ""
  self.waiting = true
  push_message(self.game, "You", text)
  local who = self.who or { key = "denna", label = "Denna" }
  companion_llm:reply(text, lines_for(self.game), function(answer)
    push_message(self.game, who.label, answer)
    self.waiting = false
  end)
end

function chat_menu:on_character_pressed(character)
  if self.waiting or #self.input >= MAX_INPUT then
    return true
  end
  self.input = self.input .. character
  return true
end

function chat_menu:on_key_pressed(key)
  if key == "escape" then
    sol.menu.stop(self)
    return true
  end
  if key == "return" or key == "kp return" then
    self:submit()
    return true
  end
  if key == "backspace" then
    self.input = self.input:sub(1, -2)
    return true
  end
  if key == "up" then
    self:scroll_by(-1)
    return true
  end
  if key == "down" then
    self:scroll_by(1)
    return true
  end
  return true
end

function chat_menu:on_command_pressed(command)
  if command == "action" and (self.input == nil or self.input == "") and not self.waiting then
    sol.menu.stop(self)
  end
  return true
end

local function companion_in_range(game)
  local map = game:get_map()
  if map == nil then
    return false
  end
  local npc = map:get_entity("companion")
  local hero = map:get_hero()
  if npc == nil or hero == nil then
    return false
  end
  return npc:get_distance(hero) <= TALK_RANGE
end

local function open_chat(game, who)
  if chat_open then
    return
  end
  chat_menu.game = game
  chat_menu.who = who or { key = "denna", label = "Denna" }
  sol.menu.start(game, chat_menu)
end

local function follow(npc)
  local map = npc:get_map()
  if map == nil or chat_open then
    return
  end
  local hero = map:get_hero()
  local sprite = npc:get_sprite()
  local distance = npc:get_distance(hero)
  if distance > FOLLOW_DISTANCE then
    -- Walk the gap down to 5 tiles. Aiming at the hero's body stops
    -- immediately, because the hero is solid.
    local movement = sol.movement.create("straight")
    movement:set_speed(FOLLOW_SPEED)
    movement:set_angle(npc:get_angle(hero))
    movement:set_max_distance(distance - FOLLOW_DISTANCE)
    movement:set_smooth(false)
    movement:start(npc)
    if sprite ~= nil then
      sprite:set_direction(npc:get_direction4_to(hero))
      sprite:set_animation("walking")
    end
  elseif npc:get_movement() ~= nil then
    npc:stop_movement()
    if sprite ~= nil then
      sprite:set_animation("stopped")
    end
  end
end

local function attach(map)
  if map:get_entity("companion") ~= nil then
    return
  end
  local hero = map:get_hero()
  if hero == nil then
    return
  end
  local x, y, layer = hero:get_position()
  local npc = map:create_npc({
    name = "companion",
    layer = layer,
    x = x - 20,
    y = y + 12,
    direction = hero:get_direction(),
    subtype = 1,
    sprite = SPRITE,
  })
  if npc == nil then
    return
  end
  npc:set_traversable(true)
  function npc:on_movement_changed(movement)
    local direction = movement:get_direction4()
    local sprite = npc:get_sprite()
    if direction ~= nil and sprite ~= nil then
      sprite:set_direction(direction)
    end
  end
  function npc:on_interaction()
    open_chat(map:get_game())
  end
  sol.timer.start(npc, 400, function()
    follow(npc)
    return true
  end)
end

-- Map scripts define map:on_started themselves, so a metatable listener
-- on that event never runs. Spawn when the game changes maps instead.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_key_pressed", function(game, key)
  if key ~= "f" or chat_open or game:is_suspended() then
    return false
  end
  -- Swallow the key so "f" is not typed into the prompt.
  return companion_in_range(game)
end)

game_meta:register_event("on_key_released", function(game, key)
  if key ~= "f" or chat_open or game:is_suspended() then
    return false
  end
  if companion_in_range(game) then
    open_chat(game)
    return true
  end
  return false
end)

game_meta:register_event("on_map_changed", function(game, map)
  sol.timer.start(map, 50, function()
    attach(map)
  end)
end)

return {
  open_chat = open_chat,
}
