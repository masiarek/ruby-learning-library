# Every Ruby construct evaluates to a value, so any of them can sit on the
# right-hand side of an assignment. The Python twin prints the same numbered
# rows; where Python has only a statement, its row says SyntaxError.

def row(n, label, value)
  puts format("%2d. %-38s -> %s", n, label, value)
end

c = true

# 1. if / else
x = if c then 1 else 2 end
row 1, "if/else as a value", x.inspect

# 2. case / when
x = case 2
    when 1 then "one"
    when 2 then "two"
    end
row 2, "case/when as a value", x.inspect

# 3. begin ... end (the try-block) is a value too
x = begin
  40 + 2
end
row 3, "begin...end as a value", x.inspect

# 4. a loop has nothing to yield, so it yields nil -- unless break gives it something
x = while false; end
y = while true; break 5; end
row 4, "while loop as a value", "#{x.inspect}; with `break 5` -> #{y.inspect}"

# 5. puts returns nil, so an assignment from it is nil
x = (puts "hi")
row 5, "x = (puts \"hi\") leaves x =", x.inspect

# 6. def returns the method's name as a Symbol
x = def greet; end
row 6, "def greet; end evaluates to", x.inspect

# 7. class ... end evaluates to the last expression in its body
x = class Foo; 99; end
y = class Bar; end
row 7, "class Foo; 99; end evaluates to", "#{x.inspect}; an empty class body -> #{y.inspect}"

# 8. chained assignment
x = y = 1
row 8, "chained x = y = 1 gives [x, y]", [x, y].inspect

# 9. an assignment is itself an expression, so it nests
y = (a = 1)
row 9, "nested y = (a = 1) gives [y, a]", [y, a].inspect

# 10. a lambda body can hold any number of statements
f = -> { t = 1; t + 1 }
row 10, "lambda body with two statements", f.call.inspect

# 11-12. one eval handles both an expression and a statement sequence
row 11, "eval(\"1 + 2\")", eval("1 + 2").inspect
row 12, "eval(\"x = 1; x + 1\")", eval("x = 1; x + 1").inspect

# 13. the Symbol from def is an argument: `private def` is private(:helper)
class Toolbox
  private def helper; end
end
row 13, "class ...; private def helper; end", "#{Toolbox.private_instance_methods(false).inspect}  (private received the Symbol)"
