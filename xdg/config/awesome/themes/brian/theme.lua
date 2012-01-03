local root = os.getenv('HOME') .. '/.config/awesome/themes/brian'

theme = {}

theme.wallpaper_cmd = {}

theme.font          = 'Terminus 8'

theme.bg_normal     = '#222222'
theme.bg_focus      = '#535d6c'
theme.bg_urgent     = '#ff0000'
theme.bg_minimize   = '#444444'

theme.fg_normal     = '#aaaaaa'
theme.fg_focus      = '#ffffff'
theme.fg_urgent     = '#ffffff'
theme.fg_minimize   = '#ffffff'

theme.border_width  = '1'
theme.border_normal = '#000000'
theme.border_focus  = '#535d6c'
theme.border_marked = '#91231c'

theme.taglist_squares_sel   = root .. '/taglist/squarefw.png'
theme.taglist_squares_unsel = root .. '/taglist/squarew.png'

return theme
