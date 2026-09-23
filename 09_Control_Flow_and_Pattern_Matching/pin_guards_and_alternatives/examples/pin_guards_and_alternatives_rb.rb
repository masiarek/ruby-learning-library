# In a pattern a bare name binds, so comparing with a variable needs the pin
# operator ^. Guards add a condition, | joins alternatives, and the parser
# refuses a few combinations. The Python twin asks `match` the same questions.

def row(n, label, value)
  puts format("%2d. %-40s -> %s", n, label, value)
end

def compiles(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

# 1. ^expected compares the subject with the variable's value
expected = 5
row 1, "5 in ^expected (expected = 5)", "#{(5 in ^expected)}; 6 in ^expected -> #{(6 in ^expected)}"

# 2. a bare name binds -- and rebinds the outer local
case 7
in expected then nil
end
row 2, "case 7; in expected", "matches anything; expected is now #{expected.inspect}"

# 3. bind then pin inside one pattern: [a, ^a] is a pair of equals
same = ([3, 3] in [a, ^a])
diff = ([3, 4] in [a, ^a])
row 3, "[3, 3] / [3, 4] in [a, ^a]", "#{same} / #{diff}; in [x, x] -> #{compiles("case [3, 3]\nin [x, x] then 1\nend")}"

# 4. the pin reaches into nested patterns
row 4, "[[1, 2], 2] / [[1, 2], 3] in [[_, x], ^x]", "#{([[1, 2], 2] in [[_, x], ^x])} / #{([[1, 2], 3] in [[_, x], ^x])}"

# 5. ^(expression), ^@ivar and ^$gvar pin other things than a local
class Gate
  def initialize(limit) = @limit = limit

  def check(n)
    case n
    in ^@limit then "at the limit"
    in Integer => v if v < @limit then "under"
    else "over"
    end
  end
end
gate = Gate.new(10)
$max = 9
row 5, "^(2 * 3), ^@limit, ^$max",
    "6 in ^(2 * 3) -> #{(6 in ^(2 * 3))}; Gate(10): #{[10, 3, 12].map { gate.check(_1) }.join(" / ")}; 9 in ^$max -> #{(9 in ^$max)}"

# 6. a constant is a value pattern with no pin; a literal or a constant cannot be pinned
LIMIT = 5
row 6, "5 / 6 in LIMIT (a constant)", "#{(5 in LIMIT)} / #{(6 in LIMIT)}; in ^1 -> #{compiles("case 5\nin ^1 then 1\nend")}; in ^Integer -> #{compiles("case 5\nin ^Integer then 1\nend")}"

# 7. guards: if and unless after the pattern
def order(pair)
  case pair
  in [x, y] if x > y then "descending"
  in [x, y] unless x > y then "not descending"
  end
end
row 7, "in [x, y] if x > y / unless x > y", "#{order([5, 3])} / #{order([1, 9])}"

# 8. alternatives with |, then one binding for whichever matched
kind = case 2.5
       in Integer | Float => num then "number #{num}"
       in String => s then "string #{s}"
       end
row 8, "2.5 in Integer | Float => num", kind.inspect

# 9. a named variable inside an alternative is refused; an _underscored one is allowed
named = compiles("case [1, 2]\nin [x, y] | [x, y, _] then 1\nend")
under = case [1, 2]
        in [_x, _y] | [_x, _y, _] then "matched, _x = #{_x}"
        end
row 9, "[x, y] | [x, y, _] / [_x, _y] | [_x, _y, _]", "#{named} / #{under}"

# 10. a bare name binds even when a method of that name exists
def limit = 5
case 8
in limit then nil
end
row 10, "def limit = 5; case 8; in limit", "binds a local: limit = #{limit}; in ^limit -> #{compiles("case 8\nin ^limit then 1\nend")}; 5 in ^(limit()) -> #{(5 in ^(limit()))}"
