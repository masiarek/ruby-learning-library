# Kata: a Money class whose +, unary -, and <=> are methods, with Comparable
# supplying <, ==, between? and clamp from the one <=> definition.
class Money
  include Comparable
  attr_reader :cents

  def initialize(cents) = @cents = cents
  def +(other) = Money.new(cents + other.cents)
  def -@ = Money.new(-cents)
  def <=>(other) = cents <=> other.cents
  def to_s = format("$%.2f", cents / 100.0)
  def inspect = to_s
end

a, b, c = Money.new(500), Money.new(1250), Money.new(99)
puts "1. a + b                    -> #{a + b}"
puts "2. -a                       -> #{-a}"
puts "3. [b, a, c].sort           -> #{[b, a, c].sort.inspect}"
puts "4. [b, a, c].max            -> #{[b, a, c].max}"
puts "5. a < b, a == Money.new(500), a != b -> #{a < b}, #{a == Money.new(500)}, #{a != b}"
puts "6. c.between?(a, b)         -> #{c.between?(a, b)}; c.clamp(a, b) -> #{c.clamp(a, b)}"
puts "7. Money.instance_method(:<).owner -> #{Money.instance_method(:<).owner} (Comparable wrote < from <=>)"
