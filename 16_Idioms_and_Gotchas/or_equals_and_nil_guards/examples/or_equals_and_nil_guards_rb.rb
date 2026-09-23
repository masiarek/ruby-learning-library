# `x ||= v` is `x || (x = v)`: it assigns when x is nil OR false, and only then.
# The Python twin asks the same twelve questions of `x = x or v` and its cousins.

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

puts "The ||= operator, value by value"
x = nil;   x ||= 5; row 1, "x = nil;   x ||= 5", x.inspect
x = false; x ||= 5; row 2, "x = false; x ||= 5   (false is replaced too)", x.inspect
x = 0;     x ||= 5; row 3, "x = 0;     x ||= 5   (0 is truthy: kept)", x.inspect
x = "";    x ||= 5; row 4, "x = \"\";    x ||= 5   (\"\" is truthy: kept)", x.inspect

puts
puts "Memoization with ||="
$runs = 0
def compute
  $runs += 1
  "value"
end

def cached
  @cache ||= compute
end
3.times { cached }
row 5, "@cache ||= compute, called 3 times: ran", "#{$runs} time(s)"

$runs = 0
def compute_false
  $runs += 1
  false
end

def cached_false
  @flag ||= compute_false
end
3.times { cached_false }
row 6, "@flag ||= (a false result), called 3 times: ran", "#{$runs} time(s)  <- the trap"

$runs = 0
def cached_right
  return @right if defined?(@right)
  @right = compute_false
end
3.times { cached_right }
row 7, "defined?(@right) guard instead, 3 calls: ran", "#{$runs} time(s)"

puts
puts "The cousins"
a = 1;   a &&= a + 1
b = nil; b &&= b + 1
row 8, "a = 1; a &&= a + 1 / b = nil; b &&= b + 1", "#{a.inspect} / #{b.inspect}"

h = {}
(h[:k] ||= []) << 1
(h[:k] ||= []) << 2
row 9, "(h[:k] ||= []) << 1, then << 2", h.inspect

row 10, "nil.to_a / Array(nil) / Array([1]) / Array(1..2)",
        "#{nil.to_a.inspect} / #{Array(nil).inspect} / #{Array([1]).inspect} / #{Array(1..2).inspect}"

h = { a: 1 }
row 11, 'h[:z] / h.fetch(:z, 0) / h.fetch(:z) { |k| "no #{k}" }',
        "#{h[:z].inspect} / #{h.fetch(:z, 0).inspect} / #{h.fetch(:z) { |k| "no #{k}" }.inspect}"

p1 = nil || 5
p2 = nil or 5
row 12, "p1 = nil || 5 / p2 = nil or 5", "#{p1.inspect} / #{p2.inspect}  (or binds below =)"
