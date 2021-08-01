pcall(require, "luarocks.loader")
require("awful.autofocus")

local gears			= require("gears")
local gfs 			= require("gears.filesystem")
local awful			= require("awful")
local wibox			= require("wibox")
local beautiful		= require("beautiful")
local naughty		= require("naughty")
local menubar		= require("menubar")
local hotkeys_popup	= require("awful.hotkeys_popup")
local xresources 	= require("beautiful.xresources")
local dpi			= xresources.apply_dpi
local popup 		= require("popup")
local help_utils 	= require("help_utils")

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
					 title = "Oops, there were errors during startup!",
					 text = awesome.startup_errors })
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Oops, an error happened!",
						 text = tostring(err) })
		in_error = false
	end)
end

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "something")
beautiful.init(theme_path)

local bling    = require("bling")
local awestore = require("awestore")

-----------
-- bling --
-----------
bling.widget.tag_preview.enable {
	show_client_content = true,
	x = 960 - 288 / 2, -- 288 is the width of the preview window
	y = 90,
	scale = 0.15,
}

------------------------------------
-- popups (volume and brightness) --
------------------------------------
local volume_popup = popup:new {
	get_value = help_utils.get_volume,
	get_toggled = help_utils.get_muted
}
awesome.connect_signal("volume_refresh", function() volume_popup:show() end)

local brightness_popup = popup:new {
	get_value = function() return help_utils.get_brightness(true) end,
}
awesome.connect_signal("brightness_refresh", function() brightness_popup:show() end)

-----------------
-- scratchpads --
-----------------
local anim_y = awestore.tweened(1100, {
	duration = 300,
	easing	 = awestore.easing.cubic_in_out
})
local term_scratch = bling.module.scratchpad:new {
	command					= "alacritty --class term_pad",
	rule					= { instance = "term_pad" },
	sticky					= true,
	autoclose				= true,
	floating				= true,
	geometry				= {x=560, y=240, height=600, width=800},
	reapply					= true,
	dont_focus_before_close = false,
	awestore				= {y = anim_y}
}
local anim_y = awestore.tweened(1100, {
	duration = 300,
	easing	 = awestore.easing.cubic_in_out
})
local discord_scratch = bling.module.scratchpad:new {
	command					= "discord",
	rule					= { instance = "discord" },
	sticky					= false,
	autoclose				= false,
	floating				= true,
	geometry				= {x=410, y=140, height=800, width=1100},
	reapply					= true,
	dont_focus_before_close = false,
	awestore				= {y = anim_y}
}
local anim_y = awestore.tweened(1100, {
	duration = 300,
	easing	 = awestore.easing.cubic_in_out
})
local spotify_scratch = bling.module.scratchpad:new {
	command					= "spotify",
	rule					= { instance = "spotify" },
	sticky					= false,
	autoclose				= false,
	floating				= true,
	geometry				= {x=410, y=140, height=800, width=1100},
	reapply					= true,
	dont_focus_before_close = false,
	awestore				= {y = anim_y}
}

terminal   = "alacritty"
editor	   = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.floating,
	awful.layout.suit.fair.horizontal,
}

menubar.utils.terminal = terminal

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)
end)

dofile(awful.util.getdir("config") .. "/" .. "bar.lua")

root.buttons(gears.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

----------------
-- screenshot --
----------------
function screenshot(specify_region)
	local command="scrot"
	if specify_region then
		command = "sleep 0.2; "..command.." -s --freeze"
	end
	local target="/home/lorago/Pictures/Screenshots/%Y-%m-%d-%T.png"
	-- This code is a mess and needs to be changed.
	awful.spawn.easy_async_with_shell(command.." "..target,
		function(out,err)
			if err == "" then
				awful.spawn.easy_async_with_shell("notify-send \"Screenshot captured\" -i ~/Pictures/Screenshots/$(ls /home/lorago/Pictures/Screenshots/ -t | head -1)")
			end
		end)
end

--------------
-- keybinds --
--------------
globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help,
			  { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev,
			  { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext,
			  { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore,
			  { description = "go back", group = "tag" }),

	awful.key({ modkey }, "p", function() naughty.notify({ title = "Title", text = "This is a test notification." }) end,
			  { description = "test notification", group = "debug" }),

	awful.key({ modkey }, "j",
		function()
			awful.client.focus.byidx(1)
			bling.module.flash_focus.flashfocus(client.focus)
		end,
		{ description = "focus next by index", group = "client"}
	),
	awful.key({ modkey }, "k",
		function()
			awful.client.focus.byidx(-1)
			bling.module.flash_focus.flashfocus(client.focus)
		end,
		{ description = "focus previous by index", group = "client" }
	),
	awful.key({ modkey }, "w", function () mymainmenu:show() end,
			  { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
			  { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
			  { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
			  { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
			  { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto,
			  { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab",
		function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),

	-- Standard programs
	awful.key({ modkey, }, "Return", function () awful.spawn(terminal) end,
			  { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Mod1" }, "r", awesome.restart,
			  { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Mod1" }, "q", awesome.quit,
			  { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
			  { description = "increase master width factor", group = "layout"}),
	awful.key({ modkey,	}, "h", function() awful.tag.incmwfact(-0.05) end,
			  { description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
			  { description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
			  { description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
			  { description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
			  { description = "decrease the number of columns", group = "layout"}),
	awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
			  { description = "select next", group = "layout"}),
	awful.key({ modkey, "Control" }, "space", function () awful.layout.inc(-1) end,
			  { description = "select previous", group = "layout"}),

	awful.key({ modkey, "Control" }, "n",
		function()
		    local c = awful.client.restore()
		    if c then
		  		c:emit_signal("request::activate", "key.unminimize", { raise = true })
		    end
		end,
		{ description = "restore minimized", group = "client" }),

	-- Application runner
	awful.key({ modkey }, "d", function () awful.util.spawn("rofi -show drun") end,
			  { description = "run rofi", group = "launcher" }),
	--awful.key({ modkey }, "d", function () awful.util.spawn("dmenu_run_history") end,
	--		  { description = "run dmenu", group = "launcher" }),

	-- Audio
	awful.key({}, "XF86AudioRaiseVolume", function()
			awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%",
			function() awesome.emit_signal("volume_refresh") end)
		end, { description = "raise volume by 5%", group = "audio" }),
	awful.key({}, "XF86AudioLowerVolume", function()
			awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%",
			function() awesome.emit_signal("volume_refresh") end)
		end, {description = "lower volume by 5%", group = "audio"}),
	awful.key({}, "XF86AudioMute", function()
			awful.spawn.easy_async_with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle",
			function() awesome.emit_signal("volume_refresh") end)
		end, {description = "mute audio", group = "audio"}),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
			awful.spawn.easy_async_with_shell("/home/lorago/scripts/brightness.sh up 700",
				function()
					awesome.emit_signal("brightness_refresh")
				end)
		end, {description = "increase brightness", group = "brightness"}),

	awful.key({}, "XF86MonBrightnessDown", function()
			awful.spawn.easy_async_with_shell("/home/lorago/scripts/brightness.sh down 700",
				function()
					awesome.emit_signal("brightness_refresh")
				end)
		end, {description = "decrease brightness", group = "brightness"}),

	-- Browser
	awful.key({ modkey }, "F2", function() awful.spawn("firefox") end,
			  {description = "open firefox", group = "launcher"}),

	-- Power management
	awful.key({ modkey, "Shift", "Control" }, "s", function() awful.util.spawn("systemctl poweroff") end,
			  { description = "shutdown", group = "power"}),
	awful.key({ modkey, "Shift", "Control" }, "r", function() awful.util.spawn("systemctl reboot") end,
			  { description = "reboot", group = "power"}),

	-- Screenshot
	awful.key({}, "Print", function() screenshot(false) end,
			  { description = "screenshot", group = "screenshot" }),
	awful.key({ modkey }, "Print", function() screenshot(true) end,
			  { description = "screenshot selection", group = "screenshot" }),

	-- Scratchpads
	awful.key({ modkey }, "v", function() term_scratch:toggle() end,
			  { description = "alacritty scratchpad", group = "scratchpad"}),
	awful.key({ modkey }, "c", function() discord_scratch:toggle() end,
			  { description = "discord scratchpad", group = "scratchpad"}),
	awful.key({ modkey }, "x", function() spotify_scratch:toggle() end,
			  { description = "spotify scratchpad", group = "scratchpad"})
)
clientkeys = gears.table.join(
	awful.key({ modkey,			  }, "f",
		function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{description = "toggle fullscreen", group = "client"}),
	awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
			  {description = "close", group = "client"}),
	awful.key({ modkey, "Shift" }, "space",  awful.client.floating.toggle,
			  {description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
			  {description = "move to master", group = "client"}),
	awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
			  {description = "move to screen", group = "client"}),
	awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
			  {description = "toggle keep on top", group = "client"}),
	awful.key({ modkey, }, "n",
		function(c)
			c.minimized = true
		end,
		{ description = "minimize", group = "client" }),
	awful.key({ modkey, }, "m",
		function(c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{ description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m",
		function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end,
		{ description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m",
		function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end ,
		{ description = "(un)maximize horizontally", group = "client" })
)

for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
				  function()
						local screen = awful.screen.focused()
						local tag = screen.tags[i]
						if tag then
						   tag:view_only()
						end
				  end,
				  { description = "view tag #"..i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
				  function()
					  local screen = awful.screen.focused()
					  local tag = screen.tags[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end,
				  { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
				  function()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:move_to_tag(tag)
						  end
					 end
				  end,
				  { description = "move focused client to tag #"..i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
				  function()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:toggle_tag(tag)
						  end
					  end
				  end,
				  { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function (c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

root.keys(globalkeys)

-----------
-- rules --
-----------
awful.rules.rules = {
	{ rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus 		 = awful.client.focus.filter,
			raise 		 = true,
			keys 		 = clientkeys,
			buttons 	 = clientbuttons,
			screen 		 = awful.screen.preferred,
			placement 	 = awful.placement.no_overlap+awful.placement.no_offscreen+awful.placement.centered,
			titlebars_enables = true
		}
	},

	-- Floating clients.
	{ rule_any = {
		instance = {
		},
		class = {
		  "Arandr"
		},

		name = {
		},
		role = {
		  "pop-up",
		}
	  }, properties = { floating = true }},
}

-------------
-- signals --
-------------
client.connect_signal("manage", function (c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
	c.shape = function(cr,w,h)
		gears.shape.rounded_rect(cr,w,h,20)
	end
end)

client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

----------------
-- autostarts --
----------------
awful.spawn.with_shell("picom --experimental-backend")
