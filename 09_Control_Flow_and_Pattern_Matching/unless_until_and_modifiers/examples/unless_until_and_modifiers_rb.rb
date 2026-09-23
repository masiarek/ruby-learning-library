# unless, until, the one-line modifier forms, the do-while that begin...end
# gives, loop do, and how `elsif` must be spelled. A claim about syntax is
# measured by compiling a string: the row prints the exception class, or
# "compiles". The Python twin prints the same rows.

def row(n, label, value)
  puts format("%2d. %-40s -> %s", n, label, value)
end

def compiles(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

# 1. unless ... else: the body runs when the condition is false
x = unless 1 > 2 then "body" else "else branch" end
row 1, "unless 1 > 2 ... else ... end", x.inspect

# 2. unless takes else, but not elsif
row 2, "unless ... elsif ... end", compiles("unless false\n  1\nelsif true\n  2\nend")

# 3. until loops while the condition is false
n = 0
until n >= 4
  n += 1
end
row 3, "n = 0; until n >= 4 ... n += 1", n.inspect

# 4. the trailing modifiers
r = []
r << "if" if true
r << "unless" unless false
row 4, "r << x if c; r << y unless c", r.inspect

# 5. `body while cond` on one line tests the condition first
n = 10
n += 1 while n < 3
row 5, "n = 10; n += 1 while n < 3", "#{n.inspect}  (tested first, never ran)"

# 6. begin ... end while cond runs the body once before testing: do-while
n = 10
begin
  n += 1
end while n < 3
row 6, "n = 10; begin n += 1 end while n < 3", "#{n.inspect}  (ran once, then tested)"

# 7. loop do ... end runs until break; break's argument is the value
i = 0
v = loop do
  i += 1
  break i * 10 if i == 3
end
row 7, "loop do ... break i * 10 ... end", v.inspect

# 8. elsif is the spelling
row 8, "if/elsif/else/end", compiles("if false\n  1\nelsif true\n  2\nelse\n  3\nend")

# 9. `elif` compiles -- as a call to a method named elif -- and fails when run
compiled = compiles("if false\n  1\nelif true\n  2\nend")
ran = begin
  if true
    elif true
  end
rescue NoMethodError => e
  e.class.to_s
end
row 9, "if ... elif true ... end", "#{compiled}; when that branch runs: #{ran}"

# 10. `else if` opens a second, nested if, which needs its own end
one_end = compiles("if false\n  1\nelse if true\n  2\nend")
two_ends = compiles("if false\n  1\nelse if true\n  2\nend\nend")
row 10, "else if ... with one end / two ends", "#{one_end} / #{two_ends}"

# 11. a modifier that never runs still defines the variable it would assign
y = 5 if false
row 11, "y = 5 if false; then y", "#{y.inspect}  (defined? -> #{defined?(y).inspect})"

# 12. no loop-else: the search idiom is find
no_else = compiles("for v in [1]\nelse\nend")
hit = [1, 2, 9].find { |v| v > 5 }
miss = [1, 2, 3].find { |v| v > 5 }
row 12, "for ... else (search with no hit)", "#{no_else}; find -> #{hit.inspect} / #{miss.inspect}"
