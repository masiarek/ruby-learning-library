# 1 + 1.5 works because Integer#+ does not know Float: it asks the Float to
# coerce itself and the Integer into a pair it can add. A class of ours can
# join in by defining coerce; a String cannot, and the two TypeErrors say
# which side refused. to_str and to_int are the other, implicit protocol.

def row(n, expr, value, note = "")
  puts format("%2d. %-28s -> %-28s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue TypeError => e
  "#{e.class}: #{e.message}"
end

class Meters
  attr_reader :n

  def initialize(n) = @n = n
  def +(other) = Meters.new(n + Meters.value_of(other))
  def -(other) = Meters.new(n - Meters.value_of(other))
  def *(other) = Meters.new(n * Meters.value_of(other))

  def coerce(numeric)
    puts "    Meters#coerce(#{numeric.inspect}) called on #{inspect}"
    [Meters.new(numeric), self]
  end

  def self.value_of(x) = x.is_a?(Meters) ? x.n : x
  def inspect = "#<Meters #{n}>"
end

class Name
  def to_str = "Bob"
end

class Index
  def to_int = 1
end

m = Meters.new(3)

row 1,  "1 + Rational(1, 2)",        (1 + Rational(1, 2)).inspect,      "the Integer is promoted to the wider class: #{(1 + Rational(1, 2)).class}"
row 2,  "1 + 1.5",                   (1 + 1.5).inspect,                 (1 + 1.5).class.to_s
row 3,  "Rational(1, 2) + 0.5",      (Rational(1, 2) + 0.5).inspect,    "Rational meets Float: Float wins, and exactness is gone"
row 4,  "1 + 2i",                    (1 + 2i).inspect,                  "#{(1 + 2i).class}; every pairing has a wider class to go to"
row 5,  "1.coerce(2.5)",             1.coerce(2.5).inspect,             "what Integer#+ asks of a Float: both as Floats, the argument first"
row 6,  "2.5.coerce(1)",             2.5.coerce(1).inspect,             "Float#coerce makes the Integer a Float"
row 7,  "m * 2",                     (m * 2).inspect,                   "our own *, with a Numeric argument"
row 8,  "2 * m",                     (2 * m).inspect,                   "Integer#* did not know Meters, so it called m.coerce(2) and multiplied the pair"
row 9,  "2 - m",                     (2 - m).inspect,                   "coerce returned [Meters(2), m], so the operands kept their order"
row 10, "1 + \"1\"",                 caught { 1 + "1" },                "a String has no coerce"
row 11, "\"1\" + 1",                 caught { "1" + 1 },                "and String#+ wants a String: the other message"
row 12, "Integer(\"1\") + 1",        (Integer("1") + 1).inspect,        "convert explicitly; \"1\" + 1.to_s is #{('1' + 1.to_s).inspect}"
row 13, "\"a\" + Name.new",          ("a" + Name.new).inspect,          "to_str is the implicit conversion to String"
row 14, "[10, 20, 30][Index.new]",   [10, 20, 30][Index.new].inspect,   "to_int is the implicit conversion to Integer"
row 15, "1 + Index.new",             caught { 1 + Index.new },          "arithmetic asks for coerce, never for to_int"
row 16, "Integer.ancestors.take(3)", Integer.ancestors.take(3).inspect, "every number is a Numeric and Comparable; 1.is_a?(Numeric) is #{1.is_a?(Numeric)}"
