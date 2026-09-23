# Kata: a call-count profiler. Enable a TracePoint for :call while a block
# runs, count calls per method for one class of our own, and print the tally
# sorted by name -- no timings, so the output is the same on every run.

class Shape
  def initialize(sides) = @sides = sides
  def perimeter(side) = @sides * side
  def area(side) = side * side * factor
  def factor = @sides == 4 ? 1 : 0.5
end

def profile(klass)
  counts = Hash.new(0)
  tp = TracePoint.new(:call) { |t| counts[t.method_id] += 1 if t.defined_class == klass }
  tp.enable { yield }
  counts.sort.each { |name, n| puts format("%-10s called %d time%s", name, n, n == 1 ? "" : "s") }
end

profile(Shape) do
  square = Shape.new(4)
  triangle = Shape.new(3)
  square.perimeter(2)
  square.area(2)
  triangle.area(2)
  triangle.area(3)
end
