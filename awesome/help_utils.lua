local help_utils = {}

function help_utils.get_volume()
	local fd = io.popen("amixer sget Master")
	local status = fd:read("*all")
	fd:close()

	return tonumber(string.match(status, "(%d?%d?%d)%%"))
end

function help_utils.get_muted()
	local fd = io.popen("amixer sget Master")
	local status = fd:read("*all")
	fd:close()

	status = string.match(status, "%[(o[^%]]*)%]")

	if string.find(status, "on", 1, true) then
		return false
	end
	return true
end

function help_utils.get_brightness(relative)
	local fd = io.popen("~/scripts/brightness.sh get")
	local status = tonumber(fd:read("*all"):sub(1,-2))
	fd:close()
	if relative then
		local fd = io.popen("~/scripts/brightness.sh max")
		local max = tonumber(fd:read("*all"):sub(1,-2))
		fd:close()
		local fd = io.popen("~/scripts/brightness.sh min")
		local min = tonumber(fd:read("*all"):sub(1,-2))
		fd:close()

		status = (status-min)/(max-min) * 100
	end

	return status
end

function help_utils.get_battery()
	local fd = io.popen("cat /sys/class/power_supply/BAT0/capacity")
	local status = fd:read()
	fd:close()
	return tonumber(status)
end

function help_utils.get_battery_status()
	local fd = io.popen("cat /sys/class/power_supply/BAT0/status")
	local status = fd:read()
	fd:close()
	return status
end

return help_utils
