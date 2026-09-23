# Ruby has two pairs of boolean operators. `&&` and `||` bind tightly; `and`
# and `or` bind lower than `=` and have equal precedence with each other.
# The Python twin prints the same rows for Python's single pair.

def row(n, label, value)
  puts format("%2d. %-40s -> %s", n, label, value)
end

def compiles(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

# 1. || binds tighter than =, so x receives the whole disjunction
x = false || true
row 1, "x = false || true; x", x.inspect

# 2. `or` binds lower than =, so it is (x = false) or true
x = false or true
whole = (x = false or true)
row 2, "x = false or true; x", "#{x.inspect}  (the whole expression is #{whole.inspect})"

# 3. the same trap with a default value
y = nil or "d"
row 3, 'y = nil or "d"; y', y.inspect

# 4. || and && return an operand, not a boolean
row 4, 'nil || "d", 1 && 2, nil && 2', [nil || "d", 1 && 2, nil && 2].map(&:inspect).join(", ")

# 5. `and` and `or` have the same precedence, so they group left to right
v = (true or false and false)
row 5, "true or false and false", "#{v.inspect}  ((true or false) and false)"

# 6. ! binds to the nearest term; `not` applies to the whole comparison
row 6, "!nil == false / not nil == false", "#{(!nil == false).inspect} / #{(not nil == false).inspect}"

# 7. ! is a method you can define; && and || are syntax, and truthiness is fixed
class Loud
  def !
    "custom !"
  end
end
row 7, "!obj is a method; && and || are not",
    "!Loud.new -> #{(!Loud.new).inspect}; Loud.new && 1 -> #{(Loud.new && 1).inspect}; 1.respond_to?(:\"&&\") -> #{1.respond_to?(:"&&")}"

# 8. a ||= b assigns only when a is nil or false; 0 and "" are truthy
vals = [nil, false, 0, ""].map { |a| a ||= 5; a.inspect }
row 8, 'a ||= 5 for nil / false / 0 / ""', vals.join(" / ")

# 9. comparisons do not chain: 1 < x is true, and true has no <
x = 2
v = begin
  1 < x < 3
rescue NoMethodError => e
  "#{e.class}: #{e.message}"
end
row 9, "1 < x < 3 with x = 2", v

# 10. and/or cannot sit bare inside an argument list
row 10, "p(true or false) / p((true or false))", "#{compiles('p(true or false)')} / #{compiles('p((true or false))')}"
