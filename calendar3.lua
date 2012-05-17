-- original code made by Bzed and published on http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
--   + transformed to module
--   + the current day formating is customizable

local string = string
local tostring = tostring
local os = os
local capi = {
   mouse = mouse,
   screen = screen
}
local awful = require("awful")
local naughty = require("naughty")
module("calendar3")

local calendar = {}
local popup

-- modify to change appearance
local header_format = "<span color='white'><b>%s</b></span>"
local day_of_week_format = "<span color='red'>%s</span>"
local current_day_format = "<span color='white'><b>%s</b></span>"
local week_of_year_format = "<span color='yellow'>%s</span>"
-- formatting for calendar, i.e. use monospace font
local calendar_format = "<span font_desc='monospace'>%s</span>"
-- 1 for Sunday, 2 for Monday, etc.
local week_start_day = 1

function drawCalendar()
   popup = naughty.notify({
			     text = string.format(calendar_format,
						  createMonth()),
			     timeout = 0,
			     hover_timeout = 0.5,
			     screen = capi.mouse.screen
			  })
end

function createMonth()
   local cmonth = calendar[1]
   local cyear = calendar[2]

   -- call with month+1 and day=0 to get last day of the month
   local month_days = os.date("*t", os.time{year=cyear, month=cmonth+1, day=0}).day
   local start_offset = (os.date("*t", os.time{year=cyear, month=cmonth, day=1}).wday - week_start_day) % 7

   local lines = "  "

   -- 2006 started on a Sunday, get weekday headers
   for x=0,6 do
      lines = lines .. string.format(day_of_week_format, os.date(" %a",os.time{year=2006,month=1,day=x+week_start_day}))
   end

   -- -- get initial "week of the year"
   lines = lines .. "\n" .. string.format(week_of_year_format, os.date("%V",os.time{year=cyear,month=cmonth,day=1}))

   -- pad first line if month does not start on first day of week
   local writeLine = 0
   while writeLine < start_offset do
      lines = lines .. "    "
      writeLine = writeLine + 1
   end

   for d = 1,month_days do
      local x = d
      local padding = "  "
      local t = os.time{year=cyear, month=cmonth, day=d}
      if (writeLine % 7) == 0 and writeLine ~= 0 then
      	 lines = lines .. "\n" .. string.format(week_of_year_format, os.date("%V", os.time{year=cyear, month=cmonth, day=d+1}))
      end
      if (#tostring(d)) == 1 then
	 padding = "   "
      end
      if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
   	 x = string.format(current_day_format, d)
      end
      lines = lines .. padding .. x
      writeLine = writeLine + 1
   end

   local header = os.date("%B %Y\n",os.time{year=cyear,month=cmonth,day=1})

   local header_padding = (31 - #header) / 2

   for i = 1,header_padding do
      header = " " .. header
   end

   return string.format(header_format, header) .. "\n" .. lines
end

function switchNaughtyMonth(switchMonths)
   local swMonths = switchMonths or 1
   calendar[1] = calendar[1] + swMonths
   naughty.destroy(popup)
   drawCalendar()
end

function addCalendarToWidget(mywidget)
   mywidget:add_signal('mouse::enter', function ()
					  calendar = { os.date('%m'), os.date('%Y') }
					  drawCalendar()
				       end)

   mywidget:add_signal('mouse::leave', function () naughty.destroy(popup) end)

   mywidget:buttons(awful.util.table.join(
		       awful.button({ }, 1, function()
					       switchNaughtyMonth(-1)
					    end),
		       awful.button({ }, 3, function()
					       switchNaughtyMonth(1)
					    end),
		       awful.button({ }, 4, function()
					       switchNaughtyMonth(-1)
					    end),
		       awful.button({ }, 5, function()
					       switchNaughtyMonth(1)
					    end),
		       awful.button({ 'Shift' }, 1, function()
						       switchNaughtyMonth(-12)
						    end),
		       awful.button({ 'Shift' }, 3, function()
						       switchNaughtyMonth(12)
						    end),
		       awful.button({ 'Shift' }, 4, function()
						       switchNaughtyMonth(-12)
						    end),
		       awful.button({ 'Shift' }, 5, function()
						       switchNaughtyMonth(12)
						    end)
		 ))
end
