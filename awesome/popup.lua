local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local Popup = {}

function Popup:new(info)
	info = info or {}
	info.box = wibox{
		x = 100,
		y = 100,
		width = 300,
		height = 40,
		ontop = true,
		visible = false,
		screen = awful.screen.focused(),
		widget = wibox.widget{
			{
				widget = wibox.widget.progressbar,
				shape = gears.shape.rounded_bar,
				background_color = beautiful.secondary,
				id = "progress_bar"
			},
			widget = wibox.container.margin,
			top = 15,
			bottom = 15,
			left = 15,
			right = 15
		}
	}
	info.hide_timer = gears.timer {
		timeout = 1,
		autostart = false,
		callback = function()
			info.box.visible = false
			info.hide_timer:stop()
		end
	}
	setmetatable(info, self)
	self.__index = self
	return info
end

function Popup:set_value(value)
	local new_value = -1
	local toggled = false

	if value then
		new_value = math.max(0, value)
	elseif self.get_value ~= nil then
		if self.get_toggled ~= nil and self.get_toggled() then
			toggled = true
		end
		new_value = math.max(0, self.get_value())
	end

	local progressbar = self.box:get_children_by_id("progress_bar")[1]
	progressbar:set_value(new_value/100)
	if toggled then
		progressbar.color = beautiful.red
	else
		progressbar.color = beautiful.progress_bar_normal
	end
end

function Popup:show(value)
	self.box.screen = awful.screen.focused()
	self.box.x = (self.box.screen.geometry.width - self.box.width) / 2
	self.box.y = (self.box.screen.geometry.height- self.box.height) / 2
	self.box.visible = true

	self:set_value(value)

	-- First stops the timer to make sure it resets on consecutive calls.
	self.hide_timer:stop()
	self.hide_timer:start()
end

return Popup
