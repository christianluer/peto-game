-- Magic bar shown under the hearts. Uses sprites/hud/magic_bar.png.
-- The large frame is at (46, 8) and the green fill is at (47, 25).

local magic_bar_builder = {}

local FRAME_X = 46
local FRAME_Y = 8
local FRAME_WIDTH = 88
local FRAME_HEIGHT = 8
local FILL_X = 47
local FILL_Y = 25
local FILL_MAX_WIDTH = 84
local FILL_HEIGHT = 6

function magic_bar_builder:new(game, config)

  local magic_bar = {}

  magic_bar.dst_x, magic_bar.dst_y = config.x, config.y
  magic_bar.surface = sol.surface.create(FRAME_WIDTH, FRAME_HEIGHT)
  magic_bar.image = sol.surface.load("sprites/hud/magic_bar.png")
  magic_bar.magic_displayed = game:get_magic()
  magic_bar.max_magic_displayed = game:get_max_magic()
  magic_bar.transparent = false

  function magic_bar:check()

    local need_rebuild = false
    local max_magic = game:get_max_magic()
    local magic = game:get_magic()

    if max_magic ~= magic_bar.max_magic_displayed then
      need_rebuild = true
      magic_bar.max_magic_displayed = max_magic
    end

    if magic ~= magic_bar.magic_displayed then
      need_rebuild = true
      if magic < magic_bar.magic_displayed then
        magic_bar.magic_displayed = magic_bar.magic_displayed - 1
      else
        magic_bar.magic_displayed = magic_bar.magic_displayed + 1
      end
    end

    if need_rebuild then
      magic_bar:rebuild_surface()
    end

    sol.timer.start(magic_bar, 20, function()
      magic_bar:check()
    end)
  end

  function magic_bar:rebuild_surface()

    magic_bar.surface:clear()
    if magic_bar.max_magic_displayed <= 0 then
      return
    end

    magic_bar.image:draw_region(
      FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT, magic_bar.surface
    )

    local fill_width = math.floor(
      magic_bar.magic_displayed / magic_bar.max_magic_displayed * FILL_MAX_WIDTH
    )
    if fill_width > 0 then
      magic_bar.image:draw_region(
        FILL_X, FILL_Y, fill_width, FILL_HEIGHT, magic_bar.surface, 1, 1
      )
    end
  end

  function magic_bar:on_started()
    magic_bar.magic_displayed = game:get_magic()
    magic_bar.max_magic_displayed = game:get_max_magic()
    magic_bar:check()
    magic_bar:rebuild_surface()
  end

  function magic_bar:set_transparent(transparent)
    magic_bar.transparent = transparent
  end

  function magic_bar:on_draw(dst_surface)

    if magic_bar.max_magic_displayed <= 0 then
      return
    end

    local x, y = magic_bar.dst_x, magic_bar.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    magic_bar.surface:set_opacity(magic_bar.transparent and 128 or 255)
    magic_bar.surface:draw(dst_surface, x, y)
  end

  return magic_bar
end

return magic_bar_builder
