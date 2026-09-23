# A block that names no parameters can still read them: `_1`, `_2`, ... since
# Ruby 2.7 and `it` since Ruby 3.4. They are parameters, not variables, so
# the parser polices them: no mixing, no nesting of `_1`, none beside an
# ordinary `|x|`. Outside a block, `it` is an ordinary name and `_1` is
# reserved. Every SyntaxError row compiles a string inside a rescue and
# prints the class only. The Python twin prints the same rows.

W = 56
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def compiles?(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

def local_it_wins
  it = "local"
  [10].map { it }
end

def no_local_it
  [10].map { it }
end

def it_in_a_method_body
  it                            # no block, no local: a method call, and there is none
end

pairs = [[1, 2], [3, 4]]
row 1, "_1 names the first parameter:", "[1, 2].map { _1 * 2 } = #{[1, 2].map { _1 * 2 }}"
row 2, "it (Ruby 3.4) names it too:", "[1, 2].map { it * 2 } = #{[1, 2].map { it * 2 }}"
row 3, "_2 makes a two-parameter block:", "{ _1 + _2 } = #{pairs.map { _1 + _2 }}, each_with_index.map { _1 * _2 } = #{[1, 2].each_with_index.map { _1 * _2 }}"
row 4, "it and a lone _1 take the whole pair, _2 splats it:", "it.size #{[[1, 2]].map { it.size }}, _1.size #{[[1, 2]].map { _1.size }}, _1 + _2 #{[[1, 2]].map { _1 + _2 }}"
row 5, "arity and parameters:", "proc { it } #{proc { it }.arity} #{proc { it }.parameters}, proc { _2 } #{proc { _2 }.arity} #{proc { _2 }.parameters}, lambda { it } #{lambda { it }.parameters}"
row 6, "nested it is allowed, nested _1 is not:", "#{[[1, 2], [3]].map { it.map { it * 10 } }}, #{compiles?("[[1]].map { _1.map { _1 } }")}"
row 7, "it and _1 in one block:", compiles?("[1].map { _1 + it }")
row 8, "it or _1 beside an ordinary |x|:", "#{compiles?("[1].map { |x| it }")}, #{compiles?("[1].map { |x| _1 }")}"
row 9, "it is an ordinary name elsewhere, _1 is reserved:", "a local it wins in a block: #{local_it_wins}, no local: #{no_local_it}, _1 = 5: #{compiles?("_1 = 5")}"
begin
  it_in_a_method_body
  row 10, "it in a method body, no block:", "no error (unexpected)"
rescue NameError => e
  row 10, "it in a method body, no block:", "#{e.class}: #{e.message}"
end
