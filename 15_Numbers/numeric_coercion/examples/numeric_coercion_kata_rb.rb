# Kata: a Celsius class that mixes with plain numbers on either side —
# c + 1, 1 + c, c * 2, 2.5 * c — and compares and sorts, because coerce
# and <=> are defined and Comparable is included.

class Celsius
  include Comparable
  attr_reader :degrees

  def initialize(degrees) = @degrees = degrees
  def +(other) = Celsius.new(degrees + Celsius.degrees_of(other))
  def *(other) = Celsius.new(degrees * Celsius.degrees_of(other))
  def <=>(other) = degrees <=> Celsius.degrees_of(other)
  def coerce(number) = [Celsius.new(number), self]
  def self.degrees_of(x) = x.is_a?(Celsius) ? x.degrees : x
  def to_s = "#{degrees} C"
  def inspect = "#<Celsius #{degrees}>"
end

c = Celsius.new(20)
puts "1. c + 1    -> #{c + 1}"
puts "2. 1 + c    -> #{1 + c}       (Integer#+ called c.coerce(1))"
puts "3. c * 2    -> #{c * 2}"
puts "4. 2.5 * c  -> #{2.5 * c}     (Float#* called c.coerce(2.5))"
puts "5. c > 15   -> #{c > 15}, c.between?(10, 30) -> #{c.between?(10, 30)}   (Comparable, built on <=>)"
puts "6. sort     -> #{[Celsius.new(30), c, Celsius.new(-5)].sort.inspect}"
puts "7. max      -> #{[c, Celsius.new(30)].max}, c.clamp(0, 10) -> #{c.clamp(0, 10)}"
begin
  c + "hot"
rescue TypeError => e
  puts "8. c + \"hot\" -> #{e.class}: #{e.message}"
end
