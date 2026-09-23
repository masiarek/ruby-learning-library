# <=> answers -1, 0, 1 or nil; `include Comparable` turns that one method into
# <, <=, ==, >, >=, between? and clamp; sort uses <=> and raises when it is nil.
# The Python twin (comparable_and_spaceship_py.py) prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-60s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

class Version
  include Comparable
  attr_reader :parts

  def initialize(text) = @parts = text.split(".").map { Integer(it) }
  def <=>(other) = other.is_a?(Version) ? parts <=> other.parts : nil
  def to_s = parts.join(".")
  def inspect = "v#{self}"
end

class OnlySpaceship
  attr_reader :v

  def initialize(v) = @v = v
  def <=>(other) = v <=> other.v
  def inspect = "S#{v}"
end

row 1,  "1 <=> 2, 2 <=> 2, 3 <=> 2",                                    [1 <=> 2, 2 <=> 2, 3 <=> 2].inspect
row 2,  '1 <=> "a", nil <=> 1, nil <=> nil',                            [1 <=> "a", nil <=> 1, nil <=> nil].inspect
row 3,  '[1, 2] <=> [1, 3], [1, 2] <=> [1, 2, 0], [1, "a"] <=> [1, 2]', [[1, 2] <=> [1, 3], [1, 2] <=> [1, 2, 0], [1, "a"] <=> [1, 2]].inspect
a = Version.new("1.10")
b = Version.new("1.9")
row 4,  "Version a = v1.10, b = v1.9: a > b, a < b, a == v1.10, a >= b", [a > b, a < b, a == Version.new("1.10"), a >= b].inspect
row 5,  "a.between?(b, v2.0), a.clamp(b, b), a.clamp(v0.1..v1.0)",       [a.between?(b, Version.new("2.0")), a.clamp(b, b), a.clamp(Version.new("0.1")..Version.new("1.0"))].inspect
row 6,  "[a, b, v1.2].sort, [a, b].min, [a, b].max",                     [[a, b, Version.new("1.2")].sort, [a, b].min, [a, b].max].inspect
row 7,  'a < "1.0"; a == "1.0"',                                        "#{raises(ArgumentError) { a < "1.0" }}; #{a == "1.0"}"
row 8,  "Comparable.instance_methods.sort",                             Comparable.instance_methods.sort.inspect
row 9,  "Integer, String, Float, Symbol, Array, NilClass: Comparable?", [Integer, String, Float, Symbol, Array, NilClass].map { it.include?(Comparable) }.inspect
row 10, "[1, 2] < [1, 3]  (Array has <=> but not Comparable)",         raises(NoMethodError) { [1, 2] < [1, 3] }
row 11, "[3, nil].sort; [3, nil].max",                                  "#{raises(ArgumentError) { [3, nil].sort }}; #{raises(ArgumentError) { [3, nil].max }}"
row 12, '[3, "a"].sort',                                                raises(ArgumentError) { [3, "a"].sort }
row 13, "[3, nil].compact.sort, [3, nil].sort_by(&:to_i)",              [[3, nil].compact.sort, [3, nil].sort_by(&:to_i)].inspect
s1, s2 = OnlySpaceship.new(1), OnlySpaceship.new(2)
row 14, "OnlySpaceship: [s2, s1].sort, .min; s1 < s2; s1 == S1",        "#{[s2, s1].sort.inspect}, #{[s2, s1].min.inspect}; #{raises(NoMethodError) { s1 < s2 }}; #{s1 == OnlySpaceship.new(1)}"
row 15, "Float::NAN <=> 1.0; [Float::NAN, 1.0].sort",                  "#{(Float::NAN <=> 1.0).inspect}; #{raises(ArgumentError) { [Float::NAN, 1.0].sort }}"
row 16, '"a" <=> "B", "abc" <=> "ab", :a <=> :b',                      ["a" <=> "B", "abc" <=> "ab", :a <=> :b].inspect
row 17, "1 <=> 1.0, 1 == 1.0, [1, 1.0].max.class, [1.0, 1].max.class",   [1 <=> 1.0, 1 == 1.0, [1, 1.0].max.class, [1.0, 1].max.class].inspect
row 18, "[3, 1, 2].sort { |x, y| y <=> x }, .max(2), .minmax",          [[3, 1, 2].sort { |x, y| y <=> x }, [3, 1, 2].max(2), [3, 1, 2].minmax].inspect
row 19, "2.clamp(3, 1)",                                                raises(ArgumentError) { 2.clamp(3, 1) }
