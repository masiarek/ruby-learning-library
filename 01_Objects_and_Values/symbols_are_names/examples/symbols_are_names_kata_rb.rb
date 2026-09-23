# Kata: tally words under symbol keys, then move the same hash between symbol
# keys and string keys and watch what == thinks of the two.

words = %w[apple Banana cherry apple]
tally = words.map { |w| w.downcase.to_sym }.tally
puts "   symbol keys   #{tally.inspect}"
puts "   key classes   #{tally.keys.map(&:class).uniq.inspect}"

strings = tally.transform_keys(&:to_s)
puts "   string keys   #{strings.inspect}"
puts "   key classes   #{strings.keys.map(&:class).uniq.inspect}"

back = strings.transform_keys(&:to_sym)
puts "   strings == tally   #{strings == tally}"
puts "   back == tally      #{back == tally}"
puts "   tally[:apple]      #{tally[:apple].inspect}"
puts "   tally[\"apple\"]     #{tally["apple"].inspect}"
