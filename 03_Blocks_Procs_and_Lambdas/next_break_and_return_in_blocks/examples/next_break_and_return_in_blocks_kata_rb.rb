# Exercise 1: first_over(limit, xs) three ways -- find, each + break, and
# each + return -- and what each returns when nothing matches.

def with_find(limit, xs)
  xs.find { |x| x > limit }
end

def with_break(limit, xs)
  xs.each { |x| break x if x > limit }      # no match: each returns xs itself
end

def with_break_fixed(limit, xs)
  xs.each { |x| break x if x > limit }
  nil                                       # each's value is dropped; nil is explicit
end

def with_return(limit, xs)
  xs.each { |x| return x if x > limit }
  nil
end

xs = [3, 8, 12]
puts "match at 5:    find #{with_find(5, xs)}, break #{with_break(5, xs)}, return #{with_return(5, xs)}"
puts "no match at 20: find #{with_find(20, xs).inspect}, break #{with_break(20, xs).inspect} (the trap), fixed #{with_break_fixed(20, xs).inspect}, return #{with_return(20, xs).inspect}"
puts "all three agree on a match: #{[with_find(5, xs), with_break(5, xs), with_return(5, xs)].uniq.size == 1}"
