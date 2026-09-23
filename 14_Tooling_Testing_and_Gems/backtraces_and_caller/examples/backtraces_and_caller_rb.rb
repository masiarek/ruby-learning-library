# A backtrace is an Array of Strings, and caller_locations gives the same
# frames as objects with a label, a path and a line. Labels are printed here;
# the one line that carries a path and a line number is masked as FILE:LINE.
def labels_of(strings) = strings.map { it[/in '([^']+)'/, 1] }

def mask(line) = line.sub(/\A\S+:\d+/, "FILE:LINE")

class Worker
  def outer = inner

  def inner
    puts " 1. caller, reduced to labels:            #{labels_of(caller).inspect}"
    puts " 2. caller_locations(0, 3) labels:        #{caller_locations(0, 3).map(&:label).inspect}"
    puts " 3. ...and their base_labels:             #{caller_locations(0, 3).map(&:base_label).inspect}"
    puts " 4. __method__ inside the method:         #{__method__.inspect}"
    here = caller_locations(0, 1).first
    puts " 5. a location has a path and a line:     #{File.basename(here.path)}, lineno is #{here.lineno.class}"
    raise ArgumentError, "bad input"
  end
end

begin
  Worker.new.outer
rescue ArgumentError => e
  puts " 6. e.backtrace (#{e.backtrace.class}) labels:      #{labels_of(e.backtrace).inspect}"
  puts " 7. e.backtrace_locations labels:         #{e.backtrace_locations.map(&:label).inspect}"
  puts " 8. full_message first line:              #{mask(e.full_message(highlight: false, order: :top).lines.first.chomp)}"
  detailed = e.detailed_message(highlight: false)
  puts " 9. detailed_message first line:          #{detailed.lines.first.chomp}   (error_highlight added a snippet below it: #{detailed.lines.size > 1})"
  e.set_backtrace(["custom:1:in 'made_up'"])
  puts "10. after set_backtrace:                  backtrace #{e.backtrace.inspect}, backtrace_locations still the originals: #{e.backtrace_locations.map(&:label).first == "Worker#inner"}"
end

puts "11. an exception never raised:            RuntimeError.new(\"x\").backtrace is #{RuntimeError.new("x").backtrace.inspect}"
puts "12. caller at the top level:              #{caller.inspect}"
def top_level_method = caller_locations(0, 1).first.label
block_label = [1].map { caller_locations(0, 1).first.label }.first
puts "13. labels elsewhere:                     top-level def: #{top_level_method.inspect}   block: #{block_label.inspect}   main: #{caller_locations(0, 1).first.label.inspect}"
