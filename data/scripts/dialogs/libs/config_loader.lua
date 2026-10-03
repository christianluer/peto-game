local config_loader = {}
local path_manager = require("scripts/dialogs/libs/paths")
local table_helper = require("scripts/dialogs/libs/table_helpers")

local function load_config(path)
  if sol.file.exists(path) then
    local data = package.loaded[path] --use existing data if loaded previously
    if not data then --need to load it for the first time
      data = {}

      local env = setmetatable({}, {__newindex = function(self, key, value)
        --TODO validation of data here
        data[key] = value
      end})

      local chunk = sol.main.load_file(path)
      assert(chunk, "Error loading config file: "..path) --probably a syntax error
      setfenv(chunk, env)
      package.preload[path] = chunk
      chunk(path)
      package.loaded[path] = data --save data for fast loading next time
    end

    return data
  end
end

  -- loads the scene configuration. It does so by first loading the default then layering
  -- the options of the dialog name. Ex. After the default config is loaded. Assume that the
  -- id is "hero.greetings.friends.emily" first it will check the hero folder and apply
  -- any configs it finds there, then greetings, than friends, than emily. If no more specific
  -- folder is found it will stop.
  --
  -- id - String which is the dialog id
  --
  -- Example:
  --   load_scene_config('hero.greeting')
  --     #=> {}
  function config_loader:load_scene_config(id)
    -- load scene defaults if they exist
    local default_path = path_manager:scene_config_path().."/default.lua"
    local scene_config = table_helper.deep_copy(load_config(default_path))

    -- iterate down through scene groups and add or override the defaults
    local current_path = ""
    for word in (id .. "."):gmatch("([^%.]+)") do
      current_path = current_path.."/"..word
      local config = load_config(path_manager:scene_config_path()..current_path.."/config.lua")
      if config then table_helper.recursive_merge(scene_config, config) end
    end

    -- This error means that you probably messed up your paths.
    assert(next(scene_config) ~= nil, "No Configuration Info Found For Scene: ".. id)

    return scene_config
  end

  -- Load character config
  -- e.g. sprite information, position, etc.
  local function load_character_config(name)
    local path = path_manager:character_config_path().."/"..name:lower()..".lua"
    return table_helper.deep_copy(load_config(path) or {})
  end

  -- Loads default configs for all passed in characters
  --
  -- characters - Array of character names
  --
  -- Example:
  --   load_default_chacter_configs(['smith', 'noah', 'alexis'])
  --     => { 'smith' => { 'sprite' => 'default', 'tansition' => 'enter_right', etc } }
  --
  -- Returns a table of character information (sprite, position, transitions, etc.)
  function config_loader:load_default_character_configs(characters)
    local character_configs = {}

    for _,name in ipairs(characters) do
      if not character_configs[name] then --skip if duplicate entry
        character_configs[name] = load_character_config(name)
      end
    end

    return character_configs
  end

  return config_loader
