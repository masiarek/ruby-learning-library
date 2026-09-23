# Kata: attendance over two days -- who came both days, one day only, either day.
# A Set drops the duplicates and, in Ruby, keeps first-seen order. The results of
# the set operators are sorted for the printout, so the answer does not depend
# on which operand the operator happens to walk first.

monday  = %w[ada bob cy ada dee]
tuesday = %w[dee bob eve bob fay]
m = monday.to_set
t = tuesday.to_set

puts "monday          #{m.to_a.inspect}  (duplicate ada dropped, order kept)"
puts "tuesday         #{t.to_a.inspect}  (duplicate bob dropped)"
puts "both days       #{(m & t).sort.inspect}"
puts "monday only     #{(m - t).sort.inspect}"
puts "tuesday only    #{(t - m).sort.inspect}"
puts "exactly one day #{(m ^ t).sort.inspect}"
puts "either day      #{(m | t).sort.inspect}"
puts "both-days is a subset of monday? #{(m & t) <= m}"
puts "first seen, either day: #{(monday + tuesday).to_set.to_a.inspect}"
