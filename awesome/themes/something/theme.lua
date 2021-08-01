local naughty 	   = require("naughty")
local xresources   = require("beautiful.xresources")
local dpi          = xresources.apply_dpi
local gears        = require("gears")
local theme_path   = string.format("%s/.config/awesome/themes/%s/", os.getenv("HOME"), "something")

local theme = {}

------------
-- colors --
------------
theme.font                 = "SFMono Nerd Font 10"
theme.font_taglist         = "SFMono Nerd Font 13"
theme.font_big             = "SFMono Nerd Font 15"

theme.primary              = "#131313"
theme.primary_dark         = "#101010"

theme.secondary            = "#1e1e1e"
theme.secondary_bright     = "#2a2a2a"

theme.foreground           = "#a8a8a8"
theme.foreground_dark      = "#575064"
theme.foreground_bright    = "#ffffff"

theme.red                  = "#8c6983"
theme.green                = "#828793"
theme.yellow               = "#888293"
theme.blue                 = "#918795"
theme.magenta              = "#92a28e"
theme.cyan                 = "#7d8f8c"

theme.progress_bar_normal  = theme.blue
theme.progress_bar_off     = theme.red

theme.bg_normal            = theme.primary
theme.bg_focus             = theme.secondary
theme.bg_urgent            = theme.red
theme.bg_minimize          = theme.primary_dark
theme.bg_systray           = theme.bg_normal

theme.fg_normal            = theme.foreground
theme.fg_focus             = theme.foreground_bright
theme.fg_urgent            = theme.foreground_bright
theme.fg_minimize          = theme.foreground

theme.useless_gap          = dpi(20)
theme.border_width         = dpi(4)
theme.border_normal        = theme.secondary
theme.border_focus         = theme.secondary_bright
theme.border_marked        = theme.red

theme.wibar_bg             = theme.bg_normal
theme.wibar_fg             = theme.fg_normal

theme.bg_systray           = theme.secondary
theme.systray_icon_spacing = dpi(12)

-----------
-- bling --
-----------
theme.flash_focus_start_opacity = 0.8
theme_flash_focus_step = 0.1

theme.tag_preview_client_opacity = 1
theme.tag_preview_client_bg = theme.primary
theme.tag_preview_widget_bg = theme.primary
theme.tag_preview_widget_border_color = theme.secondary
theme.tag_preview_client_border_color = theme.secondary

theme.tag_preview_client_border_width = 2
theme.tag_preview_widget_border_width = 2

theme.tag_preview_widget_border_radius = 10
theme.tag_preview_client_border_radius = 10

-------------------
-- notifications --
-------------------

theme.notification_max_height = dpi(80)
theme.notification_bg 		  = theme.primary
theme.notification_fg 		  = theme.foreground

naughty.config.padding = 40
naughty.config.spacing = 10
naughty.config.defaults.border_width = dpi(4)

-----------------
-- other stuff --
-----------------
theme.menu_submenu_icon = theme_path.."submenu.png"
theme.menu_height 		= dpi(15)
theme.menu_width  		= dpi(100)

theme.wallpaper         = theme_path.."background.png"

theme.layout_fairh      = theme_path.."layouts/fairhw.png"
theme.layout_fairv      = theme_path.."layouts/fairvw.png"
theme.layout_floating   = theme_path.."layouts/floatingw.png"
theme.layout_magnifier  = theme_path.."layouts/magnifierw.png"
theme.layout_max        = theme_path.."layouts/maxw.png"
theme.layout_fullscreen = theme_path.."layouts/fullscreenw.png"
theme.layout_tilebottom = theme_path.."layouts/tilebottomw.png"
theme.layout_tileleft   = theme_path.."layouts/tileleftw.png"
theme.layout_tile       = theme_path.."layouts/tilew.png"
theme.layout_tiletop    = theme_path.."layouts/tiletopw.png"
theme.layout_spiral     = theme_path.."layouts/spiralw.png"
theme.layout_dwindle    = theme_path.."layouts/dwindlew.png"
theme.layout_cornernw   = theme_path.."layouts/cornernww.png"
theme.layout_cornerne   = theme_path.."layouts/cornernew.png"
theme.layout_cornersw   = theme_path.."layouts/cornersww.png"
theme.layout_cornerse   = theme_path.."layouts/cornersew.png"

theme.icon = theme_path.."arch.png"

theme.char_focused_tag =  ""
theme.char_non_empty_tag = ""
theme.char_empty_tag = ""

return theme
