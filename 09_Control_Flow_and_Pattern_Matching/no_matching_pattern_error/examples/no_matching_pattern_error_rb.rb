# A case/in or a rightward => with nothing matching raises; the boolean `in`
# and the older case/when do not. The message says which check failed, and
# a missing hash key raises the subclass NoMatchingPatternKeyError.

def row(n, label, value)
  puts format("%2d. %-40s -> %s", n, label, value)
end

def compiles(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

def outcome
  yield
rescue NoMatchingPatternError => e
  "#{e.class}: #{e.message}"
end

# 1. case/in with no match and no else raises
row 1, "case 5; in String (no else)", outcome { case 5; in String then "string" end }

# 2. a hash pattern with a missing key raises the subclass, which knows the key
v = begin
  {a: 1} => {b:}
rescue NoMatchingPatternKeyError => e
  "#{e.class}: #{e.message}; key = #{e.key.inspect}, matchee = #{e.matchee.inspect}"
end
row 2, "{a: 1} => {b:}", v

# 3. case/in raises the same subclass for a missing key
row 3, "case {a: 1}; in {b:}", outcome { case {a: 1}; in {b:} then 1 end }

# 4. the rightward form raises for any failed check
row 4, "5 => String", outcome { 5 => String }

# 5. a shape mismatch says what it expected
row 5, "[1, 2] => [a]", outcome { [1, 2] => [a] }

# 6. the boolean form never raises
row 6, "5 in String", (5 in String).inspect

# 7. neither does case/when: no match is nil
row 7, "case 5 when String (no else)", (case 5 when String then "string" end).inspect

# 8. the hierarchy: both are StandardErrors, so a bare rescue catches them
plain = NoMatchingPatternError.ancestors.take_while { _1 != Object }
row 8, "ancestors", "#{plain.inspect}; NoMatchingPatternKeyError.superclass -> #{NoMatchingPatternKeyError.superclass}"
bare = begin
  case "x"; in Integer then 1 end
rescue => e
  "bare rescue caught #{e.class}"
end
row 9, "rescue => e (bare) on case/in", bare

# 10. an else branch prevents the raise
row 10, "case 5; in String ... else", (case 5; in String then "string" else "else branch" end).inspect

# 11. => is a statement: it has no value to assign
row 11, "x = (5 => Integer)", "#{compiles('x = (5 => Integer)')}  (void value); 5 => Integer alone -> #{compiles('5 => Integer')}"

# 12. a nested miss reports the inner hash as the matchee
v = begin
  {a: {b: 1}} => {a: {c:}}
rescue NoMatchingPatternKeyError => e
  "key = #{e.key.inspect}, matchee = #{e.matchee.inspect}"
end
row 12, "{a: {b: 1}} => {a: {c:}}", v
