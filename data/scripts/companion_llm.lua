-- Hook for the companion's replies.
-- Quest Lua cannot open HTTP. reply() writes a request into the Solarus
-- write directory and polls for a reply file. The bridge in the sibling
-- repo ollama-peto-game posts that line to Ollama.
-- base_url and model are the server the bridge calls. This file does not.

local companion_llm = {}

companion_llm.base_url = "http://127.0.0.1:11434"
companion_llm.model = "llama3.2:3b"

local REQUEST = "companion_request.txt"
local REPLY = "companion_reply.txt"
local POLL_MS = 200
local TIMEOUT_MS = 45000
local HEAR_YOU = "I can't hear you."

local function finish(callback, text)
  if sol.file.exists(REPLY) then
    sol.file.remove(REPLY)
  end
  callback(text)
end

function companion_llm:reply(message, history, callback)
  if sol.file.exists(REQUEST) then
    sol.file.remove(REQUEST)
  end
  if sol.file.exists(REPLY) then
    sol.file.remove(REPLY)
  end

  local id = tostring(sol.main.get_elapsed_time())
  local file = sol.file.open(REQUEST, "w")
  if file == nil then
    callback(HEAR_YOU)
    return
  end
  file:write(id .. "\n" .. message)
  file:close()

  local waited = 0
  sol.timer.start(sol.main, POLL_MS, function()
    waited = waited + POLL_MS
    if not sol.file.exists(REPLY) then
      if waited >= TIMEOUT_MS then
        finish(callback, HEAR_YOU)
        return false
      end
      return true
    end

    local reply = sol.file.open(REPLY, "r")
    if reply == nil then
      return true
    end
    local reply_id = reply:read("*l")
    local body = reply:read("*a") or ""
    reply:close()
    if reply_id ~= id then
      return true
    end
    body = body:gsub("^%s+", ""):gsub("%s+$", "")
    if body == "" then
      body = HEAR_YOU
    end
    finish(callback, body)
    return false
  end)
end

return companion_llm
