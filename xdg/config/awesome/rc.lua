local awful = require('awful')
awful.autofocus = require('awful.autofocus')
awful.rules = require('awful.rules')

local beautiful = require('beautiful')
local naughty   = require('naughty')
local scratch   = require('scratch')
local vicious   = require('vicious')
local wibox     = require('wibox')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

beautiful.init(awful.util.getdir('config') .. '/themes/current/theme.lua')

local modkey = 'Mod4'
local wiboxheight = 20

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local layouts =
{
  awful.layout.suit.max,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.top
  -- awful.layout.suit.tile,
  -- awful.layout.suit.tile.bottom,
}

local tags = {
  names = {
    1, 2, 3, 4, 5, 6, 7, 8, 9
  },
  layout = {
    layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]
  }
}

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function wrap(s, c) return '<span color="' .. c .. '">' .. s .. '</span>' end
function num(s) return wrap(s, 'darkgray')  end
function let(s) return wrap(s, 'lightblue') end
function sym(s) return wrap(s, '#606060')   end

awful.util.spawnwait = function (cmd)
  awful.util.pread(cmd)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local space = wibox.widget.textbox()
space:set_text(' ')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local volumebar = awful.widget.progressbar()
volumebar:set_width(4)
-- volumebar:set_height(wiboxheight)
volumebar:set_vertical(true)
volumebar:set_border_color(nil)

vicious.register(
  volumebar,
  vicious.widgets.volume,
  function (widget, args)
    if args[2] == '♩' then
      widget:set_background_color('#000000')
      widget:set_color('#ff8e76')
    else
      widget:set_background_color('#494b4f')
      widget:set_color('#aecf96')
    end
    return args[1]
  end,
  0,
  'Master'
)

vicious.force({ volumebar })

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local timebox = wibox.widget.textbox()
local format = num('%H') .. sym(':') .. num('%M') -- .. sym(':') .. num('%S')

vicious.register(timebox, vicious.widgets.date, format, 61)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local datebox = wibox.widget.textbox()
local format = num('%Y') .. ' ' .. num('%m') .. sym('/') .. let('%b') .. ' ' .. num('%d') .. sym('/') .. let('%a')

vicious.register(datebox, vicious.widgets.date, format, 61)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local membar = awful.widget.progressbar()
membar:set_width(4)
-- membar:set_height(4)
membar:set_vertical(true)
membar:set_background_color('#494b4f')
membar:set_border_color(nil)
membar:set_color('#aecf96')

vicious.register(membar, vicious.widgets.mem, '$1', 3)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local cpugraph = awful.widget.graph()
cpugraph:set_width(16)
-- cpugraph:set_height(wiboxheight)
cpugraph:set_background_color('#494b4f')
cpugraph:set_color('#ff5656')

vicious.register(cpugraph, vicious.widgets.cpu, "$1", 2)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local batterybar = awful.widget.progressbar()
batterybar:set_width(4)
-- batterybar:set_height(wiboxheight)
batterybar:set_vertical(true)
batterybar:set_background_color('#494b4f')
batterybar:set_border_color(nil)
batterybar:set_color('#aecf96')

vicious.register(
  batterybar,
  vicious.widgets.bat,
  function (widget, args)
    bat_state  = args[1]
    bat_charge = args[2]
    -- bat_time   = args[3]
    if bat_state == '↯' or bat_state == '+' or bat_state == '⌁' then
      widget:set_color('#aecf96')
    else
      widget:set_color('#ff8e76')
    end
    return bat_charge
  end,
  11,
  'BAT0'
)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local mywibox   = {}
local mytaglist = {}

for s = 1, screen.count() do
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
  mywibox[s] = awful.wibox({ position = 'top', height = wiboxheight, screen = s })

  local left_wibox = wibox.layout.fixed.horizontal()
  left_wibox:add(mytaglist[s])
  left_wibox:add(space)
  left_wibox:add(volumebar)

  local right_wibox = wibox.layout.fixed.horizontal()
  right_wibox:add(cpugraph)
  right_wibox:add(space)
  right_wibox:add(membar)
  right_wibox:add(space)
  right_wibox:add(datebox)
  right_wibox:add(space)
  right_wibox:add(timebox)
  right_wibox:add(space)
  right_wibox:add(batterybar)

  local wibox_layout = wibox.layout.align.horizontal()
  wibox_layout:set_left(left_wibox)
  wibox_layout:set_right(right_wibox)

  mywibox[s]:set_widget(wibox_layout)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function makefocusbydirection(d)
  return
    function ()
      awful.client.focus.bydirection(d)
      if client.focus then
        client.focus:raise()
      end
    end
end

globalkeys = awful.util.table.join(
  awful.key({ modkey            }, 'u',     awful.tag.viewprev),
  awful.key({ modkey            }, 'o',     awful.tag.viewnext),
  awful.key({ modkey            }, 'q',     awful.tag.history.restore),

  awful.key({ modkey            }, 'j',     makefocusbydirection('down')),
  awful.key({ modkey            }, 'k',     makefocusbydirection('up')),
  awful.key({ modkey            }, 'h',     makefocusbydirection('left')),
  awful.key({ modkey            }, 'l',     makefocusbydirection('right')),

  awful.key({ modkey, 'Control' }, 'j',     function () awful.client.swap.bydirection('down')  end),
  awful.key({ modkey, 'Control' }, 'k',     function () awful.client.swap.bydirection('up')    end),
  awful.key({ modkey, 'Control' }, 'h',     function () awful.client.swap.bydirection('left')  end),
  awful.key({ modkey, 'Control' }, 'l',     function () awful.client.swap.bydirection('right') end),

  awful.key({ modkey, 'Shift'   }, 'l',     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, 'Shift'   }, 'h',     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey, 'Shift'   }, 'j',     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, 'Shift'   }, 'k',     function () awful.tag.incmwfact( 0.05)    end),

  awful.key({ modkey,           }, 'space', function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts, -1) end),

  awful.key({ modkey            }, '0',     function () awful.util.spawn('lock-screen', false) end),
  awful.key({ modkey            }, 'i',     function () awful.util.spawn('run-terminal', false) end),
  awful.key({ modkey            }, 'p',     function () awful.util.spawn('run-program', false) end),
  awful.key({ modkey            }, 'y',     function () scratch.drop('run-terminal', 'center', 'center', 0.5, 0.5) end),

  awful.key({ modkey            }, 'e',     function ()
                                              -- local idx = 1
                                              -- local objs = {}
                                              keygrabber.run(
                                                function (modkeys, key, eventtype)
                                                  -- objs[idx] = naughty.notify({ text = tostring(eventtype)..' '..tostring(key), bg = "#00aa00", fg = "#ffffff", border_color = "#ffffff", timeout = 0 })
                                                  -- idx = idx + 1
                                                  if eventtype == 'release' then
                                                    return
                                                  end
                                                  if eventtype == 'press' and key == 'Escape' then
                                                    keygrabber.stop()
                                                    -- for i=1, idx-1 do naughty.destroy(objs[i]) end
                                                    return
                                                  end
                                                  if eventtype == 'press' and key:match('^Shift_[LR]$') then
                                                    return
                                                  end
                                                  keygrabber.stop()
                                                  -- for i=1, idx-1 do naughty.destroy(objs[i]) end
                                                  if key:match('^[%a%d]$') then
                                                    awful.util.spawn('search-web' .. ' ' .. key, false)
                                                  end
                                                end
                                              )
                                            end),

  -- pizza keys
  awful.key({                   }, '#122',  function () awful.util.spawnwait('decrease-volume Master 4'); vicious.force({ volumebar }) end),
  awful.key({                   }, '#123',  function () awful.util.spawnwait('increase-volume Master 4'); vicious.force({ volumebar }) end),
  awful.key({                   }, '#121',  function () awful.util.spawnwait('toggle-mute Master');       vicious.force({ volumebar }) end),
  -- pageup, pagedown, left arrow
  awful.key({ modkey,           }, '#112',  function () awful.util.spawnwait('decrease-volume Master 4'); vicious.force({ volumebar }) end),
  awful.key({ modkey,           }, '#117',  function () awful.util.spawnwait('increase-volume Master 4'); vicious.force({ volumebar }) end),
  awful.key({ modkey            }, '#113',  function () awful.util.spawnwait('toggle-mute Master');       vicious.force({ volumebar }) end),

  awful.key({ modkey, 'Shift'   }, 'r',     awesome.restart),
  awful.key({ modkey, 'Shift'   }, 'x',     awesome.quit)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, 'f',      function (c) c.fullscreen = not c.fullscreen end),
  awful.key({ modkey,           }, 'c',      function (c) c:kill() end),
  awful.key({ modkey,           }, 't',      awful.client.floating.toggle),
  awful.key({ modkey,           }, 'Return', function (c) c:swap(awful.client.getmaster()) end)
)

local keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key(
      { modkey }, '#' .. i + 9,
      function ()
        local screen = mouse.screen
        if awful.tag.selected(screen) ~= tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
      end),
    awful.key({ modkey, 'Shift' }, '#' .. i + 9,
      function ()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.movetotag(tags[client.focus.screen][i])
        end
      end)
  )
end

root.keys(globalkeys)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local clientbuttons = awful.util.table.join(
  awful.button({        }, 1, function(c) client.focus = c c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

awful.rules.rules = {
  { rule = { },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus        = true,
                   keys         = clientkeys,
                   buttons      = clientbuttons } },
  { rule = { class = 'Audacity' },
    properties = { floating = true } },
  { rule = { class = 'MPlayer' },
    properties = { floating = true } },
  { rule = { class = 'vncviewer' },
    properties = { floating = true } },
  { rule = { class = 'Anki' },
    properties = { floating = true } },
  { rule = { class = 'Gimp' },
    properties = { floating = true } },
  { rule = { name = 'GLFW Window' },
    properties = { floating = true } },
  { rule = { name = 'Mozilla Firefox' },
    properties = { tag = tags[1][3] } },
  { rule = { class = 'Chromium' },
    properties = { tag = tags[1][4] } },
  { rule = { class = 'Inkscape' },
    properties = { tag = tags[1][4] } },
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- client.connect_signal(
--   'manage',
--   function(c, startup)
--     -- Enable sloppy focus
--     c:connect_signal(
--       'mouse::enter',
--       function(c)
--         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and
--            awful.client.focus.filter(c)
--         then
--           client.focus = c
--         end
--       end
--     )

--     if not startup then
--       awful.client.setslave(c)
--       if not c.size_hints.user_position and not c.size_hints.program_position then
--         awful.placement.no_overlap(c)
--         awful.placement.no_offscreen(c)
--       end
--     end
--   end
-- )

client.connect_signal('focus',   function (c) c.border_color = beautiful.border_focus  end)
client.connect_signal('unfocus', function (c) c.border_color = beautiful.border_normal end)
