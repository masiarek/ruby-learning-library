# Destructuring: multiple assignment collects the right-hand side into an Array
# and distributes it -- a missing value is nil, an extra one is dropped, * gathers
# -- and a block auto-splats an Array argument across its parameters.
# The Python twin (destructuring_assignment_py.py) prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-56s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

a, b = 1, 2
row 1,  "a, b = 1, 2",                                          [a, b].inspect
a, b = b, a
row 2,  "a, b = b, a  (swap)",                                  [a, b].inspect
a, *b = [1, 2, 3]
*c, d = [1, 2, 3]
row 3,  "a, *b = [1, 2, 3]; *c, d = [1, 2, 3]",                 [[a, b], [c, d]].inspect
a, *b, c = 1, 2, 3, 4
row 4,  "a, *b, c = 1, 2, 3, 4",                                [a, b, c].inspect
(a, b), c = [1, 2], 3
row 5,  "(a, b), c = [1, 2], 3  (nested)",                      [a, b, c].inspect
first, = [1, 2]
row 6,  "first, = [1, 2]  (trailing comma: take the first)",    first.inspect
a, b = [1]
row 7,  "a, b = [1]  (too few: nil)",                           [a, b].inspect
a, b = 1, 2, 3
row 8,  "a, b = 1, 2, 3  (too many: dropped)",                  [a, b].inspect
a = 1, 2
row 9,  "a = 1, 2  (one target: an Array)",                     a.inspect
a, b = "xy"
row 10, 'a, b = "xy"  (a String does not splat)',               [a, b].inspect
a, b = {x: 1, y: 2}
row 11, "a, b = {x: 1, y: 2}  (nor does a Hash)",               [a, b].inspect
a, b = nil
row 12, "a, b = nil",                                           [a, b].inspect
v = (a, b = 1, 2)
row 13, "v = (a, b = 1, 2)  (the assignment is an expression)", v.inspect

pairs = [[1, 2], [3, 4]]
row 14, "pairs.map { |x, y| x + y }  (a block auto-splats)",    pairs.map { |x, y| x + y }.inspect
row 15, "pairs.each_with_index.map { |(x, y), i| }",            pairs.each_with_index.map { |(x, y), i| "#{i}:#{x + y}" }.inspect
row 16, '{a: 1, b: 2}.map { |k, v| "#{k}#{v}" }',               {a: 1, b: 2}.map { |k, v| "#{k}#{v}" }.inspect
def m(x, y) = x + y
row 17, "->(x, y) {}.call([1, 2]); proc { |x, y| }.call([1, 2]); m([1, 2])", [raises(ArgumentError) { ->(x, y) { x + y }.call([1, 2]) }, proc { |x, y| [x, y] }.call([1, 2]), (m([1, 2]) rescue $!.class)].inspect

class Pair
  def initialize(a, b) = (@a, @b = a, b)
  def to_ary = [@a, @b]
end
Point = Struct.new(:x, :y)
a, b = Pair.new(7, 8)
c, d = Point.new(1, 2)
row 18, "a, b = obj with to_ary; c, d = a Struct (no to_ary)",  [[a, b], [c, d]].inspect

def two = (return 1, 2)
a, b = two
row 19, "def two = (return 1, 2); two, then a, b = two",        [two, [a, b]].inspect
