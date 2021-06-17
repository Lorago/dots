pcall(require, "luarocks.loader")
require("awful.autofocus")

local gears		 = require("gears")
local awful		 = require("awful")
local wibox		 = require("wibox")
local beautiful	 = require("beautiful")
local naughty	 = require("naughty")
local menubar	 = require("menubar")
local help_utils = require("help_utils")

myawesomemenu = {
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal }
	}
})

mylauncher = {
	{
		{
			widget = awful.widget.launcher({
				image = beautiful.icon,
				menu = mymainmenu
			}),
		},
		widget = wibox.container.margin,
		top = 3,
		bottom = 3,
		left = 3,
		right = 3
	},
	widget = wibox.container.background,
	shape = gears.shape.rounded_bar,
	bg = beautiful.secondary
}

-- Creates the textclock widget.
mytextclock = wibox.widget {
	{
		{
			{
				id = "clock",
				widget = wibox.widget.textclock("%H:%M")
			},
			widget = wibox.container.margin,
			left = 12,
			right = 12
		},
		widget = wibox.container.background,
		shape = gears.shape.rounded_bar,
		bg = beautiful.secondary
	},
	widget = wibox.container.margin,
	top = 1,
	bottom = 1
}

mytextclock:connect_signal("mouse::enter", function()
	mytextclock:get_children_by_id("clock")[1].format = "%a %d %b, %H:%M"
end)

mytextclock:connect_signal("mouse::leave", function()
	mytextclock:get_children_by_id("clock")[1].format = "%H:%M"
end)

-- Creates the system tray.
tray = wibox.widget.systray()
mysystemtray = {
	{
		{
			widget = tray,
			id = "tray"
		},
		top = 5,
		bottom = 5,
		left = 10,
		right = 10,
		widget = wibox.container.margin
	},
	shape      = gears.shape.rounded_bar,
	shape_border_color = beautiful.secondary,
	shape_border_width = 3,
	shape_clip = true,
	widget     = wibox.container.background,
	bg = beautiful.secondary
}

-- Creates the wibox for each screen and adds it.
local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Creates the tasklist buttons.
local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal(
				"request::activate",
				"tasklist",
				{raise = true}
			)
		end
	end),
	awful.button({ }, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
	end)
)

-- Everything related to the battery bar.
mybatterybar = wibox.widget {
	{
		{
			{
				{
					align  = 'center',
					valign = 'center',
					widget = wibox.widget.textbox,
					font = beautiful.font_big,
					text = "",
					id = "icon"
				},
				widget = wibox.container.margin,
				left = 10,
			},
			{
				{
					{
						id = "progress_bar",
						widget = wibox.widget.progressbar,
						forced_width = 80,
						shape = gears.shape.rounded_bar,
						background_color = beautiful.secondary
					},
					{
						id = "text_box",
						align  = 'center',
						valign = 'center',
						widget = wibox.widget.textbox,
					},
					widget = wibox.widget,
					layout = wibox.layout.stack
				},
				widget = wibox.container.margin,
				top    = 4,
				bottom = 4,
				left   = 4,
				right  = 4,
			},
			widget = wibox.widget,
			layout = wibox.layout.fixed.horizontal
		},
		widget = wibox.container.background,
		shape = gears.shape.rounded_bar,
		bg = beautiful.secondary
	},
	widget = wibox.container.margin,
	top = 1,
	bottom = 1
}

function get_battery_icon()
	local battery = help_utils.get_battery()
	local status = help_utils.get_battery_status()

	local battery_icons
	local n_icons
	if status == "Charging" then	
		battery_icons = {
			"",
			"",
			"",
			"",
			"",
			"",
			""
		}
		n_icons = 7
	else
		battery_icons = {
			"",
			"",
			"",
			"",
			"",
			"",
			"",
			"",
			"",
			""
		}
		n_icons = 10
	end
	local icon_index = math.floor(battery/100 * (n_icons-1)+1)
	local icon = battery_icons[icon_index]
	return icon
end

hovering_battery = false
function update_battery()
	local battery = help_utils.get_battery()

	if hovering_battery then
		local textbox = mybatterybar:get_children_by_id("text_box")[1]
		textbox.text = battery.."%"
	end

	local progressbar = mybatterybar:get_children_by_id("progress_bar")[1]

	local colors = {
		beautiful.progress_bar_normal,
		beautiful.secondary
	}
	progressbar:set_value(battery/100)
	progressbar.color = {
		type  = "linear",
		from  = { 0, 0, 0 },
		to 	  = { 90, 0, 0 },
		stops = { { 0, colors[1] }, { battery/100, colors[2] } }
	}
    local icon_widget = mybatterybar:get_children_by_id("icon")[1]
 	local icon = get_battery_icon()

	icon_widget.text = icon.." "
end

update_battery()

gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function()
		update_battery()
    end
}

mybatterybar:connect_signal("mouse::enter", function()
	hovering_battery=true
	update_battery()
end)

mybatterybar:connect_signal("mouse::leave", function()
	hovering_battery=false
	update_battery()

	local textbox = mybatterybar:get_children_by_id("text_box")[1]
	textbox.text = ""
end)

-- Everything related to the volume bar.
myvolumebar = wibox.widget {
	{
		{
			{
				{
					align  = 'center',
					valign = 'center',
					widget = wibox.widget.textbox,
					font = beautiful.font_big,
					text = "墳 "
				},
				widget = wibox.container.margin,
				left = 10,
			},
			{
				{
					{
						id = "progress_bar",
						widget = wibox.widget.progressbar,
						forced_width = 80,
						shape = gears.shape.rounded_bar,
						background_color = beautiful.secondary
					},
					{
						id = "text_box",
						align  = 'center',
						valign = 'center',
						widget = wibox.widget.textbox,
					},
					widget = wibox.widget,
					layout = wibox.layout.stack
				},
				widget = wibox.container.margin,
				top    = 4,
				bottom = 4,
				left   = 4,
				right  = 4,
			},
			widget = wibox.widget,
			layout = wibox.layout.fixed.horizontal
		},
		widget = wibox.container.background,
		shape = gears.shape.rounded_bar,
		bg = beautiful.secondary
	},
	widget = wibox.container.margin,
	top = 1,
	bottom = 1
}

hovering_volume = false
function update_volume()
	local volume = help_utils.get_volume()
	local muted = help_utils.get_muted()

	if hovering_volume then
		local textbox = myvolumebar:get_children_by_id("text_box")[1]
		if muted then
			textbox.text = "muted"
		else
			textbox.text = volume.."%"
		end
	end

	local progressbar = myvolumebar:get_children_by_id("progress_bar")[1]

	local colors = {
		beautiful.progress_bar_normal,
		beautiful.secondary
	}
	if muted then
		colors = {
			beautiful.progress_bar_off,
			beautiful.secondary
		}
	end
	progressbar:set_value(volume/100)
	progressbar.color = {
		type  = "linear",
		from  = { 0, 0, 0 },
		to 	  = { 90, 0, 0 },
		stops = { { 0, colors[1] }, { volume/100, colors[2] } }
	}
end

update_volume()

awesome.connect_signal("volume_refresh", update_volume)

myvolumebar:connect_signal("mouse::enter", function()
	hovering_volume=true
	update_volume()
end)

myvolumebar:connect_signal("mouse::leave", function()
	hovering_volume=false
	update_volume()

	local textbox = myvolumebar:get_children_by_id("text_box")[1]
	textbox.text = ""
end)

awful.screen.connect_for_each_screen(function(s)
	-- Tagtable for each screen.
	awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

	-- Creates the layout indicator.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end)
	))

	-- Everything related to the taglist is here.
	update_taglist = function(self, t, index, tags)
		local has_client = false
		local has_focus = false

		for _, c in ipairs(client.get()) do
			if t == c.first_tag then
				has_client = true
				break
			end
		end
		for _,tag in ipairs(awful.screen.focused().selected_tags) do
			if t == tag then
				has_focus = true
			end
		end

		self.fg = beautiful.foreground
		if has_focus then
			self:get_children_by_id('index_role')[1].markup = '<b> '..''..' </b>'
		else
			self:get_children_by_id('index_role')[1].markup = '<b> '..''..' </b>'
		end
		if not has_focus and not has_client then
			self.fg = beautiful.foreground_dark
		end
	end

	local taglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		widget_template = {
			{
				{
					{
						{
							{
								id     = 'index_role',
								widget = wibox.widget.textbox,
							},
							widget  = wibox.container.margin,
						},
						shape  = gears.shape.circle,
						widget = wibox.container.background,
					},
					{
						{
							id     = 'icon_role',
							widget = wibox.widget.imagebox,
						},
						widget  = wibox.container.margin,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left  = 8,
				right = 8,
				widget = wibox.container.margin,
			},
			id     = 'background_role',
			widget = wibox.container.background,
			create_callback = function(self, t, index, tags)
				update_taglist(self,t,index,tags)

				self:connect_signal('mouse::enter', function()
					if self.bg ~= beautiful.secondary_bright then
						self.backup     = self.bg
						self.has_backup = true
					end
					self.bg = beautiful.secondary_bright

					if #t:clients() > 0 then
						awesome.emit_signal("bling::tag_preview::update", t)
						awesome.emit_signal("bling::tag_preview::visibility", s, true)
					end
				end)
				self:connect_signal('mouse::leave', function()
					if self.has_backup then self.bg = self.backup end

					awesome.emit_signal("bling::tag_preview::visibility", s, false)
				end)
			end,
			update_callback = function(self, t, index, tags)
				update_taglist(self,t,index,tags)
			end,
		},
		buttons = taglist_buttons,
	}

	s.mytaglist = wibox.widget {
		{
			widget = taglist
		},
		shape      = gears.shape.rounded_bar,
		shape_border_color = beautiful.secondary,
		shape_border_width = 3,
		shape_clip = true,
		widget     = wibox.container.background,
		bg = beautiful.secondary
	}

	-- Creates the tasklist widget.
	local tasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
			spacing = 0,
			layout = wibox.layout.fixed.horizontal
		},
		widget_template = {
			{
				{
					{
						{
							id = 'icon_role',
							widget = wibox.widget.imagebox
						},
						margins = 4,
						widget = wibox.container.margin
					},
					layout = wibox.layout.fixed.horizontal
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin
			},
			id = 'background_role',
			widget = wibox.container.background,
			style = {
				shape = gears.shape.rounded_bar,
			}
		}
	}
	-- Creates the rounded shape of the tasklist.
	s.mytasklist = wibox.widget {
		{
			widget = tasklist
		},
		shape      = gears.shape.rounded_bar,
		shape_border_color = beautiful.secondary,
		shape_border_width = 3,
		shape_clip = true,
		widget     = wibox.container.background,
	}

	-- Creates the wibox.
	s.mywibox = awful.wibar({ position = "top", screen = s, height = 36 })

	tray = nil
	if s == screen.primary then
		tray = mysystemtray
	end

	-- Creates the widgets.
	s.mywibox:setup {
		{
			{
				layout = wibox.layout.align.horizontal,
				expand = "none",

				-- Left.
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 8,
					mylauncher,
					s.mytaglist,
				},

				-- Middle.
				s.mytasklist,

				-- Right.
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 8,
					tray,
					mybatterybar,
					myvolumebar,
					mytextclock,
					s.mylayoutbox,
				}
			},
			bottom = 4,
			top = 4,
			left = 7,
			right = 4,
			color = beautiful.bg_normal,
			widget = wibox.container.margin
		},
		bottom = 3,
		color = beautiful.secondary,
		widget = wibox.container.margin
	}
end)
