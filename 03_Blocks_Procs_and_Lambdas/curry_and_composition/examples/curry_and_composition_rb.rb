# `curry` turns a lambda of n arguments into a chain of one-argument
# lambdas, `>>` and `<<` compose any two callables into a new lambda, and
# `parameters` and `arity` describe what a proc or method expects. The
# Python twin prints the same rows with functools.partial, a hand-written
# compose and inspect.signature.

W = 48
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def f(x) = x + 1
def g(x) = x * 10

add = ->(a, b) { a + b }
add3 = ->(a, b, c) { a + b + c }
pr = proc { |a, b| [a, b] }
vsum = ->(*xs) { xs.sum }
double = ->(x) { x * 2 }
sq = ->(x) { x * x }

row 1, "curry: one argument at a time, or all at once:", "add.curry[1][2] = #{add.curry[1][2]}, .(1).(2) = #{add.curry.(1).(2)}, [1, 2] = #{add.curry[1, 2]}"
inc = add.curry[1]
row 2, "a partly applied lambda is a value:", "inc = add.curry[1]; inc[41] = #{inc[41]}, #{inc.class}, lambda? #{inc.lambda?}"
row 3, "three arguments, split any way:", "[1][2][3] = #{add3.curry[1][2][3]}, [1, 2][3] = #{add3.curry[1, 2][3]}, [1][2, 3] = #{add3.curry[1][2, 3]}"
row 4, "curry on a proc keeps the proc rules:", "pr.curry[1][2] = #{pr.curry[1][2]}, lambda? #{pr.curry.lambda?}; a curried lambda's arity is #{add.curry.arity}"

too_many = begin
  add.curry(3)
rescue ArgumentError => e
  "#{e.class}: #{e.message}"
end
row 5, "a variadic needs curry(n); a fixed one refuses:", "vsum.curry[1] = #{vsum.curry[1]}, vsum.curry(3)[1][2][3] = #{vsum.curry(3)[1][2][3]}; add.curry(3): #{too_many}"

fg = method(:f) >> method(:g)
gf = method(:f) << method(:g)
row 6, ">> runs left then right, << the other way:", "(f >> g).call(1) = #{fg.call(1)}, (f << g).call(1) = #{gf.call(1)}"
row 7, "composition returns a lambda, from any callables:", "#{fg.class}, lambda? #{fg.lambda?}; (double >> :to_s.to_proc >> :size.to_proc).call(50000) = #{(double >> :to_s.to_proc >> :size.to_proc).call(50000)}, map(&(double >> f)) #{[1, 2].map(&(double >> method(:f)))}"
pipeline = [double, sq, method(:f)].reduce(:>>)
row 8, "a pipeline by reduce(:>>); order matters:", "[double, sq, f].reduce(:>>).call(3) = #{pipeline.call(3)}, (sq << double).call(3) = #{(sq << double).call(3)}, (sq >> double).call(3) = #{(sq >> double).call(3)}"

callable = Class.new { def call(x) = x + 100 }.new
plain = begin
  callable >> double
rescue NoMethodError => e
  e.class
end
row 9, "anything with call composes on the right:", "(double >> callable).call(1) = #{(double >> callable).call(1)}; callable >> double: #{plain}, a plain object has no >>"

full = ->(a, b = 1, *c, d:, e: 2, **f, &g) {}
row 10, "parameters and arity describe the shape:", "add #{add.parameters} #{add.arity}, pr #{pr.parameters} #{pr.arity}, full #{full.parameters} #{full.arity}, method(:f).curry[4] = #{method(:f).curry[4]}"
