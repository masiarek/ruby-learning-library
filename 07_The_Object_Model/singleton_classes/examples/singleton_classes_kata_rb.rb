# Exercise 1: an object with no class of its own. Build a counter from a bare
# Object.new using singleton methods only, then show what dup and clone keep.

counter = Object.new
counter.instance_variable_set(:@count, 0)

def counter.increment = @count += 1
def counter.count = @count
def counter.inspect = "#<counter #{@count}>"

3.times { counter.increment }
puts "counter                       #{counter.inspect}"
puts "counter.singleton_methods     #{counter.singleton_methods.sort.inspect}"
puts "counter.class                 #{counter.class}"
puts "Object.new.respond_to?(:count) #{Object.new.respond_to?(:count)}"

copy = counter.dup
twin = counter.clone
puts "dup keeps @count?             #{copy.instance_variable_get(:@count)}"
puts "dup.singleton_methods         #{copy.singleton_methods.inspect}"
puts "dup.respond_to?(:increment)   #{copy.respond_to?(:increment)}"
puts "clone.singleton_methods       #{twin.singleton_methods.sort.inspect}"
twin.increment
puts "clone after one increment     #{twin.inspect}"
puts "the original is untouched     #{counter.inspect}"
