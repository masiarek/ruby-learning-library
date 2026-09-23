# Kata: for a few fixed dates, the next leap day and how many days away it is,
# with Date arithmetic only -- Date.leap?, Date.new and Date - Date.
require "date"

def next_leap_day(from)
  year = from.year
  year += 1 until Date.leap?(year) && Date.new(year, 2, 29) > from
  Date.new(year, 2, 29)
end

[Date.new(2024, 1, 1), Date.new(2024, 2, 29), Date.new(2099, 6, 15), Date.new(2100, 1, 1)].each do |from|
  leap = next_leap_day(from)
  puts format("%s -> %s in %4d days (%s)", from, leap, (leap - from).to_i, Date::DAYNAMES[leap.wday])
end
