# `+`, `-@`, `[]`, `[]=`, `<=>`, `<<` and `!` are ordinary methods defined
# with `def`, and `1 + 2` is `1.+(2)`; `&&`, `||`, `=`, `?:`, `..`, `and`,
# `or` and `not` are syntax and cannot be defined or looked up.

class Vec
  include Comparable
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(other) = Vec.new(x + other.x, y + other.y)
  def -@ = Vec.new(-x, -y)
  def [](i) = [x, y][i]

  def []=(i, value)
    i.zero? ? @x = value : @y = value
    :ignored
  end

  def <=>(other) = [x, y] <=> [other.x, other.y]
  def <<(n) = Vec.new(x + n, y + n)
  def *(n) = Vec.new(x * n, y * n)

  def !
    "bang called on #{self}"
  end

  def to_s = "Vec(#{x}, #{y})"
  def inspect = to_s
end

v = Vec.new(1, 2)
w = Vec.new(3, 4)

puts "1. an operator is a call:         1 + 2 -> #{1 + 2}, 1.+(2) -> #{1.+(2)}, 1.send(:+, 2) -> #{1.send(:+, 2)}, 1.method(:+).owner -> #{1.method(:+).owner}"
puts "2. def +(other):                  v + w -> #{v + w}, v.+(w) -> #{v.+(w)}"
puts "3. def -@ (unary minus):          -v -> #{-v}"
r = (v[1] = 9)
puts "4. def [] and def []=:            v[0] -> #{v[0]}; v[1] = 9 evaluates to #{r.inspect}, not the body's :ignored; v is #{v}"
v[1] = 2
puts "5. def <=> plus Comparable:       v < w #{v < w}, v == Vec.new(1, 2) #{v == Vec.new(1, 2)}, v != w #{v != w}, [w, v].min -> #{[w, v].min}, v.clamp(w, w) -> #{v.clamp(w, w)}"
puts "6. def <<:                        v << 10 -> #{v << 10}"
puts "7. def ! is a method:             !v -> #{(!v).inspect}, (not v) -> #{(not v).inspect}, v.! -> #{v.!.inspect}"
puts "   every object has one:          1.method(:!).owner -> #{1.method(:!).owner}, !1 -> #{(!1).inspect}"
begin
  2 * v
rescue TypeError => e
  puts "8. def * but no coerce:           v * 2 -> #{v * 2}; 2 * v -> #{e.class}: #{e.message}"
end
begin
  1.method(:"&&")
rescue NameError => e
  puts "9. && is not a method:            1.method(:\"&&\") -> #{e.class}: #{e.message}"
end
begin
  RubyVM::InstructionSequence.compile("def &&(other); end")
rescue SyntaxError => e
  puts "   def &&(other); end            -> #{e.class}"
end
ops = %w[+ - * / % ** == != < <= > >= <=> << >> & | ^ ~ ! -@ +@ [] === && || .. and or not =]
methods, syntax = ops.partition { |op| 1.respond_to?(op.to_sym) }
puts "10. Integer responds to:          #{methods.join(' ')}"
puts "    syntax, not methods:          #{syntax.join(' ')}"
