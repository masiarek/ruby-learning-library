# Time (an instant, with an offset) and Date (a calendar day), on fixed instants
# only: TZ is pinned to UTC before any Time is made, and Time.now never appears,
# so this output is the same on every machine and every day.
ENV["TZ"] = "UTC"
require "date"

def row(n, text, value = "")
  puts format("%2d. %-58s %s", n, text, value)
end

t = Time.utc(2024, 2, 29, 12)
row 1, "Time.utc(2024, 2, 29, 12); class; utc?; zone", "#{t}; #{t.class}; #{t.utc?}; #{t.zone}"
later = t + 86400
row 2, "+ 86400 adds seconds; later - t is a Float of seconds", "#{later}; #{later - t} (#{(later - t).class})"
row 3, "+ 0.5 keeps subseconds (inspect shows them); usec", "#{(t + 0.5).inspect}; #{(t + 0.5).usec}"
row 4, 'strftime("%Y-%m-%d %H:%M:%S %z"); ("%A %d %B %Y")', "#{t.strftime("%Y-%m-%d %H:%M:%S %z")}; #{t.strftime("%A %d %B %Y")}"
row 5, 'strftime("%j %U %u %I %p %-d %e|")  (%-d and %e are Ruby\'s own)', t.strftime("%j %U %u %I %p %-d %e|")
row 6, "iso8601 and xmlschema are core methods in 4.0 (no require)", "#{t.iso8601}; #{t.xmlschema}; #{t.iso8601(3)}"
row 7, "to_i, to_f, to_r are seconds since the epoch", "#{t.to_i}; #{t.to_f}; #{t.to_r}"
row 8, "Time.at(0) is local time (TZ=UTC here): utc? is false; .utc", "#{Time.at(0)}; #{Time.at(0).utc?}; #{Time.at(0).utc}"
local = Time.new(2024, 2, 29, 12)
row 9, "Time.new(2024, 2, 29, 12) is local: utc?; zone; == t", "#{local}; #{local.utc?}; #{local.zone}; #{local == t}"
plus2 = Time.new(2024, 2, 29, 12, in: "+02:00")
row 10, 'Time.new(..., in: "+02:00"); getutc; utc_offset; == t', "#{plus2}; #{plus2.getutc}; #{plus2.utc_offset}; #{plus2 == t}"
g = t.getlocal("+02:00")
row 11, 't.getlocal("+02:00") is the same instant shown elsewhere', "#{g}; hour=#{g.hour}; == t: #{g == t}"
row 12, "t <=> t + 1; == and eql? with an equal Time; equal?", "#{t <=> t + 1}; #{t == Time.utc(2024, 2, 29, 12)}; #{t.eql?(Time.utc(2024, 2, 29, 12))}; #{t.equal?(Time.utc(2024, 2, 29, 12))}"
hour_err = begin
  Time.utc(2024, 2, 29, 25)
rescue ArgumentError => e
  "#{e.class}: #{e.message}"
end
row 13, "Time.utc(2024, 2, 30) rolls over; hour 25 does not", "#{Time.utc(2024, 2, 30)}; #{hour_err}"
row 14, "(t + 0.5).round; t.to_a", "#{(t + 0.5).round}; #{t.to_a.inspect}"
before = Time.respond_to?(:parse)
require "time"
row 15, 'Time.parse/iso8601/strptime need require "time": before, after', "#{before}, #{Time.respond_to?(:parse)}"
row 16, 'Time.iso8601("2024-02-29T12:00:00+02:00").utc; Time.strptime', "#{Time.iso8601("2024-02-29T12:00:00+02:00").utc}; #{Time.strptime("29/02/2024", "%d/%m/%Y")}"
row 17, "Time.new also parses a String (3.2+)", Time.new("2024-02-29 12:00:00 UTC").to_s

d = Date.new(2024, 1, 31)
row 18, "Date.new(2024, 1, 31); + 1 is a day; >> 1 is a month (clamped)", "#{d}; #{d + 1}; #{d >> 1}; #{d >> 13}; #{d << 1}"
diff = d - Date.new(2024, 1, 1)
row 19, "Date - Date is a Rational number of days", "#{diff.inspect} (#{diff.class}); to_i=#{diff.to_i}"
row 20, "Date.parse, Date.iso8601, Date.strptime", "#{Date.parse("March 1, 2024")}; #{Date.iso8601("2024-03-01")}; #{Date.strptime("01/03/2024", "%d/%m/%Y")}"
date_err = begin
  Date.new(2024, 2, 30)
rescue Date::Error => e
  "#{e.class}: #{e.message}"
end
row 21, "Date.leap?(2024, 2100, 2000); valid_date?(2024, 2, 30); Date.new", "#{[Date.leap?(2024), Date.leap?(2100), Date.leap?(2000)].inspect}; #{Date.valid_date?(2024, 2, 30)}; #{date_err}"
row 22, "wday (Sunday=0), cwday (Monday=1), yday, cweek; DAYNAMES[wday]", "#{d.wday}; #{d.cwday}; #{d.yday}; #{d.cweek}; #{Date::DAYNAMES[d.wday]}"
row 23, "a negative day counts from the end: Date.new(2024, 2, -1)", "#{Date.new(2024, 2, -1)}; #{Date.new(2023, 2, -1)}"
row 24, "a Range of Dates; step", "#{(Date.new(2024, 1, 1)..Date.new(2024, 1, 3)).map(&:to_s).inspect}; #{Date.new(2024, 1, 1).step(Date.new(2024, 1, 10), 3).map(&:to_s).inspect}"
row 25, "Date#to_time is local midnight; Time#to_date", "#{d.to_time}; #{t.to_date} (#{t.to_date.class})"
row 26, "DateTime exists (DateTime < Date) but Time is the one to use", "#{DateTime.new(2024, 2, 29, 12).to_s}; superclass=#{DateTime.superclass}"
matched = case t
          in {year: 2024, month: 2..3, hour:} then "matched, hour=#{hour}"
          end
row 27, "Time and Date deconstruct_keys for pattern matching (3.2+)", "#{t.deconstruct_keys([:year, :month]).inspect}; #{matched}"
