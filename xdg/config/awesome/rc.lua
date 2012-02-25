require('awful')
require('awful.autofocus')
require('awful.rules')
require('beautiful')
require('naughty')

require('scratch')
require('vicious')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

beautiful.init(os.getenv('HOME') .. '/.config/awesome/themes/current/theme.lua')

modkey = 'Mod4'
wiboxheight = 20

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

layouts =
{
  awful.layout.suit.tile,
  awful.layout.suit.max
}

tags = {
  names = {
    1, 2, 3, 4, 5, 6, 7, 8, 9
  },
  layout = {
    layouts[1], layouts[1],
    layouts[2], layouts[2],
    layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]
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

awful.util.spawnwait =
  function (cmd)
    awful.util.pread(cmd)
  end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

space = widget({ type = 'textbox' })
space.text = ' '

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

volumebar = awful.widget.progressbar()
volumebar:set_width(4)
volumebar:set_height(wiboxheight)
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

timebox = widget({ type = 'textbox' })
format = num('%H') .. sym(':') .. num('%M') .. sym(':') .. num('%S')

vicious.register(timebox, vicious.widgets.date, format, 1)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

datebox = widget({ type = 'textbox' })
format = num('%Y') .. ' ' .. num('%m') .. sym('/') .. let('%b') .. ' ' .. num('%d') .. sym('/') .. let('%a')

vicious.register(datebox, vicious.widgets.date, format, 61)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

membar = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
membar:set_width(4)
membar:set_height(wiboxheight)
membar:set_vertical(true)
membar:set_background_color('#494b4f')
membar:set_border_color(nil)
membar:set_color('#aecf96')

vicious.register(membar, vicious.widgets.mem, '$1', 3)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

cpugraph = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
cpugraph:set_width(16)
cpugraph:set_height(wiboxheight)
cpugraph:set_background_color('#494b4f')
cpugraph:set_color('#ff5656')
cpugraph:set_gradient_colors({ '#ff5656', '#88a175', '#aecf96' })

vicious.register(cpugraph, vicious.widgets.cpu, '$1', 1)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

batterybar = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
batterybar:set_width(4)
batterybar:set_height(wiboxheight)
batterybar:set_vertical(true)
batterybar:set_background_color('#494b4f')
batterybar:set_border_color(nil)

vicious.register(
  batterybar,
  vicious.widgets.bat,
  function (widget, args)
    if args[1] == '↯' or args[1] == '+' then
      widget:set_color('#aecf96')
    else
      widget:set_color('#ff8e76')
    end
    return args[2]
  end,
  11,
  'BAT0'
)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

mywibox   = {}
mytaglist = {}

for s = 1, screen.count() do
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, {})

  mywibox[s] = awful.wibox({ position = 'top', height = wiboxheight, screen = s })
  mywibox[s].widgets = {
    {
      mytaglist[s], space,
      volumebar,
      layout = awful.widget.layout.horizontal.leftright
    },
    batterybar, space,
    cpugraph,   space,
    membar,     space,
    timebox,    space,
    datebox,
    layout = awful.widget.layout.horizontal.rightleft
  }
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

  awful.key({ modkey, 'Shift'   }, 'l',     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey, 'Shift'   }, 'h',     function () awful.tag.incmwfact(-0.05)    end),

  awful.key({ modkey,           }, 'space', function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts, -1) end),

  awful.key({ modkey            }, '0',     function () awful.util.spawn('lock-screen', false) end),
  awful.key({ modkey            }, 'i',     function () awful.util.spawn('run-terminal', false) end),
  awful.key({ modkey            }, 'p',     function () awful.util.spawn('run-program', false) end),
  awful.key({ modkey            }, 'y',     function () scratch.drop('run-terminal', 'center', 'center', 0.4, 0.4) end),

  awful.key({ modkey            }, 'e',     function ()
                                              keygrabber.run(
                                                function (modkeys, key, eventtype)
                                                  if eventtype == 'press' and key:match('^%a$') then
                                                    awful.util.spawn('search-web ' .. key, false)
                                                    return false
                                                  end
                                                  return true
                                                end
                                              )
                                            end),

  -- the official weird buttons
  awful.key({                   }, '#122',  function () awful.util.spawnwait('decrease-volume Master 5'); vicious.force({ volumebar }) end),  -- page up
  awful.key({                   }, '#123',  function () awful.util.spawnwait('increase-volume Master 5'); vicious.force({ volumebar }) end),  -- page down
  awful.key({                   }, '#121',  function () awful.util.spawnwait('toggle-mute Master');       vicious.force({ volumebar }) end),  -- left
  -- the back/forward buttons and left arrow
  awful.key({ modkey            }, '#166',  function () awful.util.spawnwait('decrease-volume Master 5'); vicious.force({ volumebar }) end),  -- page up
  awful.key({ modkey            }, '#167',  function () awful.util.spawnwait('increase-volume Master 5'); vicious.force({ volumebar }) end),  -- page down
  awful.key({ modkey            }, '#113',  function () awful.util.spawnwait('toggle-mute Master');       vicious.force({ volumebar }) end),  -- left

  awful.key({ modkey, 'Shift'   }, 'r',     awesome.restart),
  awful.key({ modkey, 'Shift'   }, 'x',     awesome.quit)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, 'f',      function (c) c.fullscreen = not c.fullscreen end),
  awful.key({ modkey,           }, 'c',      function (c) c:kill() end),
  awful.key({ modkey,           }, 't',      awful.client.floating.toggle),
  awful.key({ modkey,           }, 'Return', function (c) c:swap(awful.client.getmaster()) end)
)

keynumber = 0
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

clientbuttons = awful.util.table.join(
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
  { rule = { name = 'luakit' },
    properties = { tag = tags[1][3] } },
  { rule = { name = 'Mozilla Firefox' },
    properties = { tag = tags[1][3] } },
  { rule = { name = 'New Tab - Chromium' },
    properties = { tag = tags[1][4] } },
  { rule = { name = 'Aurora' },
    properties = { tag = tags[1][5] } },
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

client.add_signal(
  'manage',
  function(c, startup)
    -- Enable sloppy focus
    c:add_signal(
      'mouse::enter',
      function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and
           awful.client.focus.filter(c)
        then
          client.focus = c
        end
      end
    )

    if not startup then
      awful.client.setslave(c)
      if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    end
  end
)

client.add_signal('focus',   function(c) c.border_color = beautiful.border_focus  end)
client.add_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
