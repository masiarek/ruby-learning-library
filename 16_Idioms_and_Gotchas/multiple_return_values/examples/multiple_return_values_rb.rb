# `return a, b` builds an Array; multiple assignment takes it apart. Ruby has no
# tuple type, so every "pair" a core method returns is an Array too.

def row(n, label, value)
  puts format("%2d. %-44s %s", n, label, value)
end

def pair
  return 1, 2
end

def triple
  [1, 2, 3]
end

Pair = Struct.new(:q, :r)
Coord = Data.define(:x, :y)

def div_mod(a, b)
  Pair.new(*a.divmod(b))
end

def nothing; end

row 1, "def pair; return 1, 2; end -> pair, pair.class", "#{pair.inspect}, #{pair.class}"
x, y = pair
row 2, "x, y = pair", "x=#{x} y=#{y}"
row 3, "7.divmod(2)", 7.divmod(2).inspect
row 4, "[1, 2, 3, 4].partition(&:even?)", [1, 2, 3, 4].partition(&:even?).inspect
row 5, "[3, 1, 2].minmax", [3, 1, 2].minmax.inspect
first, *rest = triple
row 6, "first, *rest = triple", "first=#{first} rest=#{rest.inspect}"
_, second = pair
row 7, "_, second = pair", "second=#{second}"
row 8, "{a: 1, b: 2, c: 3}.values_at(:a, :c)", { a: 1, b: 2, c: 3 }.values_at(:a, :c).inspect
row 9, "Struct: div_mod(7, 2), .q", "#{div_mod(7, 2).inspect}, q=#{div_mod(7, 2).q}"
c = Coord.new(x: 1, y: 2)
c => { x:, y: }
row 10, "Data: c = Coord.new(x: 1, y: 2); c => {x:, y:}", "#{c.inspect}; x=#{x} y=#{y}"
a, b = 1
c1, c2 = [1, 2, 3]
row 11, "a, b = 1 / c1, c2 = [1, 2, 3]", "a=#{a.inspect} b=#{b.inspect} / c1=#{c1} c2=#{c2}  (no error)"
row 12, "def nothing; end -> nothing.class", nothing.class.to_s
