# `for` and `while` are syntax and open no scope: their variables are the
# enclosing scope's. A block is a scope: its parameters and the locals first
# assigned inside it vanish when it ends. The Python twin asks the same rows.

def row(n, label, value)
  puts format("%2d. %-40s -> %s", n, label, value)
end

def compiles(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

# 1. after a for loop, the loop variable and a body variable are both still there
for i in 1..3
  x = i
end
row 1, "for i in 1..3; x = i; end; then", "i = #{i.inspect}, x = #{x.inspect}  (defined? #{defined?(i)} / #{defined?(x)})"

# 2. after each, neither the block parameter nor a block-local variable exists
[10, 20].each { |j| y = j }
reading_y = begin
  y
rescue NameError => err
  err.class.to_s
end
row 2, "[10, 20].each { |j| y = j }; then", "defined?(j) -> #{defined?(j).inspect}; y -> #{reading_y}"

# 3. for is each in disguise: it calls the collection's each
class Bag
  def each
    CALLS << "Bag#each called"
    yield :a
    yield :b
  end
end
CALLS = []
for v in Bag.new
end
row 3, "for v in Bag.new", "#{CALLS.first}; v after the loop = #{v.inspect}"

# 4. while opens no scope either
n = 0
while n < 2
  w = n
  n += 1
end
row 4, "while n < 2; w = n; ...; then", "n = #{n}, w = #{w}"

# 5. the iterator methods take blocks, so nothing leaks
3.times { |t| tt = t }
1.upto(2) { |u| }
1.step(5, 2) { |s| }
k = 0
loop { k += 1; break if k == 2 }
row 5, "times / upto / step / loop", "defined?(t) #{defined?(t).inspect}, (tt) #{defined?(tt).inspect}, (u) #{defined?(u).inspect}, (s) #{defined?(s).inspect}; loop counted k = #{k}"

# 6. a block sees and assigns an outer variable; only new names are local to it
z = nil
[1].each { |q| z = q }
row 6, "z = nil; [1].each { |q| z = q }", "z = #{z.inspect}"

# 7. for destructures, and those variables leak too
for a, b in [[1, 2], [3, 4]]
end
row 7, "for a, b in [[1, 2], [3, 4]]; then", "a = #{a}, b = #{b}"

# 8. for is an expression: its value is the collection, or what break gives it
whole = for m in [1, 2]; end
broke = for m in [1, 2, 3]; break m * 10 if m == 2; end
row 8, "for ... end as a value", "#{whole.inspect}; with break m * 10 -> #{broke.inspect}"

# 9. a block-local variable |q; outer| shadows instead of assigning
outer = "outer"
[1].each { |q; outer| outer = "shadow" }
row 9, "[1].each { |q; outer| outer = ... }", "outer = #{outer.inspect}"

# 10. an empty for still defines its variable, because the parser saw it
for none in []
end
row 10, "for none in []; end; then none", "#{none.inspect}  (defined? #{defined?(none).inspect})"

# 11. lambdas made in a for share its one variable; each gives every call a fresh one
procs = []
for c in 1..3
  procs << -> { c }
end
blocks = []
(1..3).each { |d| blocks << -> { d } }
row 11, "lambdas capturing the loop variable", "for -> #{procs.map(&:call).inspect}; each -> #{blocks.map(&:call).inspect}"
