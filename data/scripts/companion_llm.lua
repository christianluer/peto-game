-- Hook for the companion's replies.
-- base_url stays empty until the Ollama server on the other machine is ready.
-- reply() is the only place that should talk to that server.

local companion_llm = {}

companion_llm.base_url = nil
companion_llm.model = nil

function companion_llm:reply(message, history, callback)
  callback("I can't hear you.")
end

return companion_llm
