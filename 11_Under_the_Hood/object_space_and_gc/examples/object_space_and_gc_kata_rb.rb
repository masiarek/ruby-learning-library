# Kata: count what a block allocates. GC.stat(:total_allocated_objects) is a
# running total, so its difference across a block is the block's allocations.
# Only comparisons are printed: an exact count is an implementation detail
# (the first call of `allocations` itself allocates one object, a call cache,
# which is why it is called once to warm up before anything is measured).

def allocations
  GC.disable
  before = GC.stat(:total_allocated_objects)
  yield
  GC.stat(:total_allocated_objects) - before
ensure
  GC.enable
end

allocations { }
empty = allocations { }
strings = allocations { 100.times { String.new("s") } }
arithmetic = allocations { 1 + 2 }
symbol = allocations { :sym }
arrays = allocations { [[1], [2], [3]] }

puts "1. an empty block allocates nothing:                    #{empty == 0}"
puts "2. 100 String.new calls allocate at least 100 objects:  #{strings >= 100}"
puts "3. 1 + 2 allocates nothing (Integers are immediates):   #{arithmetic == 0}"
puts "4. a symbol literal allocates nothing:                  #{symbol == 0}"
puts "5. [[1], [2], [3]] allocates at least 4 objects:        #{arrays >= 4}"
