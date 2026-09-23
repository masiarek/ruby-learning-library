# An array pattern calls the subject's `deconstruct`; a hash pattern calls
# `deconstruct_keys(keys)`. Define the two and any object can be matched.
# CALLS records every call so each row can show what the pattern asked for.

def row(n, label, value)
  puts format("%2d. %-40s -> %s", n, label, value)
end

CALLS = []

def called = CALLS.slice!(0..).join(", ")

class Point
  attr_reader :x, :y

  def initialize(x, y) = (@x, @y = x, y)

  def deconstruct
    CALLS << "deconstruct"
    [x, y]
  end

  def deconstruct_keys(keys)
    CALLS << "deconstruct_keys(#{keys.inspect})"
    {x: x, y: y}
  end
end

pt = Point.new(1, 2)

# 1. an array pattern asks for deconstruct
v = case pt; in [a, b] then [a, b] end
row 1, "in [a, b] on a Point", "#{v.inspect}  via #{called}"

# 2. Const[...] checks the class first, then asks the same
v = case pt; in Point[a, b] then [a, b] end
row 2, "in Point[a, b]", "#{v.inspect}  via #{called}"

# 3. a hash pattern asks for deconstruct_keys, naming the keys it wants
v = case pt; in {x:, y:} then [x, y] end
row 3, "in {x:, y:}", "#{v.inspect}  via #{called}"

# 4. only the keys the pattern names are asked for
v = case pt; in Point(x:) then x end
row 4, "in Point(x:)", "#{v.inspect}  via #{called}"

# 5. with **rest the pattern needs every key, and passes nil
v = case pt; in {x:, **rest} then rest end
row 5, "in {x:, **rest}", "rest = #{v.inspect}  via #{called}"

# 6. Struct and Data come with both methods
S = Struct.new(:x, :y)
D = Data.define(:x, :y)
s = S.new(1, 2)
d = D.new(x: 1, y: 2)
row 6, "Struct / Data: deconstruct, deconstruct_keys",
    "#{s.deconstruct.inspect} / #{s.deconstruct_keys(nil).inspect}; Data: #{d.deconstruct.inspect} / #{d.deconstruct_keys(nil).inspect}; keys [:x] -> #{s.deconstruct_keys([:x]).inspect} / #{d.deconstruct_keys([:x]).inspect}"

# 7. Array and Hash are their own deconstruction; a String is not a sequence
row 7, "Array#deconstruct, Hash#deconstruct_keys", "#{[1, 2].deconstruct.inspect} / #{({a: 1}.deconstruct_keys(nil)).inspect}; \"ab\" in [_, _] -> #{("ab" in [_, _])}"

# 8. an object with neither method simply does not match
row 8, "5 in [_] (no deconstruct)", "#{(5 in [_])}; 5.respond_to?(:deconstruct) -> #{5.respond_to?(:deconstruct)}"

# 9. the return types are checked
class Broken
  def deconstruct = "not an array"
  def deconstruct_keys(_keys) = "not a hash"
end
bad_array = begin
  Broken.new in [_]
rescue TypeError => e
  "#{e.class}: #{e.message}"
end
bad_hash = begin
  Broken.new in {a:}
rescue TypeError => e
  "#{e.class}: #{e.message}"
end
row 9, "deconstruct returning a String", "#{bad_array}; #{bad_hash}"

# 10. MatchData deconstructs into its captures
m = /(?<a>\d+)-(?<b>\d+)/.match("10-20")
row 10, "MatchData: deconstruct / deconstruct_keys", "#{m.deconstruct.inspect} / #{m.deconstruct_keys(nil).inspect}"
