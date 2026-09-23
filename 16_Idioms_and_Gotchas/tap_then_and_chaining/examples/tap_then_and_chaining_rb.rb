# `tap` yields the receiver to the block and returns the RECEIVER (the block's
# value is ignored); `then` yields it and returns the BLOCK'S value. Together
# they let a value flow through a chain with a debugging stop in the middle.

def row(n, label, value)
  puts format("%2d. %-46s %s", n, label, value)
end

row 1, "5.tap  { |v| v * 100 }", 5.tap { |v| v * 100 }.inspect
row 2, "5.then { |v| v * 100 }", 5.then { |v| v * 100 }.inspect

puts "    -- tap inside a chain, printing without breaking it --"
result = [3, 1, 2]
  .tap { |a| puts "       before sort: #{a.inspect}" }
  .sort
  .tap { |a| puts "       after sort:  #{a.inspect}" }
  .map { |v| v * 10 }
row 3, "[3, 1, 2].tap {..}.sort.tap {..}.map { * 10 }", result.inspect

row 4, '"5".then(&:to_i)', "#{"5".then(&:to_i).inspect} (#{"5".then(&:to_i).class})"
row 5, "5.then { it + 1 }", 5.then { it + 1 }.inspect

total = [1, 2, 3]
  .map { it * 2 }
  .select { it > 2 }
  .sum
row 6, "leading-dot chain over four lines, summed", total.inspect

row 7, "[1, 2, 2].group_by(&:itself)", [1, 2, 2].group_by(&:itself).inspect

strip  = ->(s) { s.strip }
lower  = ->(s) { s.downcase }
snake  = ->(s) { s.tr(" ", "_") }
row 8, '"  Hello World ".then(&strip).then(&lower).then(&snake)',
       "  Hello World ".then(&strip).then(&lower).then(&snake).inspect
row 9, "(strip >> lower >> snake).call(same string)", (strip >> lower >> snake).call("  Hello World ").inspect

row 10, "5.method(:then) == 5.method(:yield_self)", (5.method(:then) == 5.method(:yield_self)).inspect
row 11, "5.method(:tap).owner / 5.method(:then).owner", "#{5.method(:tap).owner} / #{5.method(:then).owner}"

seen = [].tap { |a| a << 1; :ignored }
row 12, "[].tap { |a| a << 1; :ignored }", "#{seen.inspect}  (mutation kept, block value dropped)"
