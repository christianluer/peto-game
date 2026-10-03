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
local FALLBACK = {
  denna = "Say that again. I was looking at you, not listening.",
  teacher = "Quiet. I was listening for a name, not for you.",
}

local function finish(callback, text)
  if sol.file.exists(REPLY) then
    sol.file.remove(REPLY)
  end
  callback(text)
end

function companion_llm:reply(message, history, callback, character)
  if sol.file.exists(REQUEST) then
    sol.file.remove(REQUEST)
  end
  if sol.file.exists(REPLY) then
    sol.file.remove(REPLY)
  end

  local key = character or "denna"
  if FALLBACK[key] == nil then
    key = "denna"
  end
  local missed = FALLBACK[key]
  local id = tostring(sol.main.get_elapsed_time())
  local file = sol.file.open(REQUEST, "w")
  if file == nil then
    callback(missed)
    return
  end
  local line = message:gsub("[\r\n]", " ")
  file:write(id .. "\n" .. line .. "\n" .. key)
  file:close()

  local waited = 0
  sol.timer.start(sol.main, POLL_MS, function()
    waited = waited + POLL_MS
    if not sol.file.exists(REPLY) then
      if waited >= TIMEOUT_MS then
        finish(callback, missed)
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
      body = missed
    end
    finish(callback, body)
    return false
  end)
end

return companion_llm
