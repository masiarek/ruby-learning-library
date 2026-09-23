# Exercise 1: a parser with no else, called with a good and a bad event; the
# exceptions are rescued and read, then the two forms that never raise.

def parse(event)
  case event
  in {type: "click", x: Integer => x, y: Integer => y} then "click at #{x},#{y}"
  in {type: "key", key: String => key} then "key #{key}"
  end
end

good = {type: "key", key: "q"}
bad = {type: "scroll", delta: 3}
puts "good event -> #{parse(good)}"
begin
  parse(bad)
rescue NoMatchingPatternError => e
  puts "bad event  -> #{e.class}"
end

begin
  good => {type:, modifiers:}
rescue NoMatchingPatternKeyError => e
  puts "=> with a missing key -> #{e.class}, key #{e.key.inspect}"
end

puts "boolean in -> #{(bad in {type: "click"})}"
puts "case/when  -> #{(case bad when Hash then "a hash" end)}"
