# A block, proc or lambda closes over the variables around it -- the variables,
# not their values at the time -- so it sees later assignments and can make
# them. A block parameter is a fresh variable per call; an outer variable
# assigned inside the block is one variable for everyone. The Python twin
# prints the same rows.

W = 52
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def make_counter
  count = 0
  [-> { count += 1 }, -> { count }]      # two lambdas, one variable
end

def sees_n
  n                                      # a def opens a new scope: no n here
end

n = 1
f = -> { n }
n = 2
row 1, "a closure sees the later value of n:", f.call

inc, get = make_counter
inc.call
inc.call
_, get_other = make_counter
row 2, "two lambdas share one count; a new maker starts over:", "#{get.call}, #{get_other.call}"

total = 0
[1, 2, 3].each { |x| total += x }
row 3, "a block assigns the outer total:", total

[1].each { inner = 1 }
row 4, "a name first assigned inside stays inside:", "defined?(inner) = #{defined?(inner).inspect}"

per_call = (1..3).map { |i| -> { i } }
row 5, "a block parameter is fresh per call:", per_call.map(&:call).to_s

j = nil
shared = (1..3).map { |i| j = i; -> { j } }
in_for = []
for i in 1..3
  in_for << -> { i }
end
row 6, "an outer j assigned in the block; a for loop's i:", "#{shared.map(&:call)}, #{in_for.map(&:call)}, i after the loop = #{i}"

x = 10
[1].each { |x| x += 5 }
row 7, "a block parameter shadows the outer x:", "x = #{x}"

tmp = "outer"
[1].each { |x; tmp| tmp = x }
row 8, "|x; tmp| makes tmp block-local:", "tmp = #{tmp.inspect}"

row 9, "the captured variable, seen from outside:", "f.binding.local_variable_get(:n) = #{f.binding.local_variable_get(:n)}"

begin
  sees_n
  row 10, "a def is not a closure:", "sees n (unexpected)"
rescue NameError => e
  row 10, "a def is not a closure:", "#{e.class}: a def cannot see the outer n"
end
