# Kata: roll two dice 1000 times with a seeded generator and tally the sums.
# Seeded, the tally is the same on every run, so an answer key can hold it.

r = Random.new(2024)
sums = Array.new(1000) { r.rand(1..6) + r.rand(1..6) }
tally = sums.tally.sort.to_h
tally.each { |sum, count| puts format("%2d %-4d %s", sum, count, "#" * (count / 5)) }
most = tally.max_by { |_, count| count }
puts "most common: #{most[0]} (#{most[1]} times); mean #{sums.sum.fdiv(sums.size)}"
