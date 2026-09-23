# `case x when y` asks `y === x`, and every kind of object answers === in its
# own way: a class tests membership, a Range tests cover?, a Regexp matches,
# a lambda is called, and anything else compares with ==. The Python twin
# asks the same twelve questions of `match`.

def row(n, label, value)
  puts format("%2d. %-38s -> %s", n, label, value)
end

# 1. a class: Integer === 3 is 3.is_a?(Integer)
v = case 3 when Integer, Float then "number" else "other" end
row 1, "3: when Integer, Float", v.inspect

# 2. a Range: (1..5) === 3 is (1..5).cover?(3)
v = case 3 when 1..5 then "small" when 6.. then "big" end
row 2, "3: when 1..5", "#{v.inspect}  ((\"a\"..\"z\") === \"bb\" -> #{("a".."z") === "bb"}: cover?, since include? -> #{("a".."z").include?("bb")})"

# 3. a Regexp: /(\d+)/ === "id 42" matches and sets $~ and $1
v = case "id 42" when /(\d+)/ then "digits #{$1}" end
row 3, '"id 42": when /(\d+)/ sets $~', "#{v.inspect}; $~ is a #{$~.class}"

# 4. a lambda: ->(n) { n > 100 } === 150 calls the lambda
v = case 150 when ->(n) { n > 100 } then "big" else "small" end
row 4, "150: when ->(n) { n > 100 }", v.inspect

# 5. a splat: when *VOWELS is when "a", "e", "i", "o", "u"
VOWELS = %w[a e i o u]
v = case "e" when *VOWELS then "vowel" else "consonant" end
row 5, '"e": when *VOWELS', v.inspect

# 6. the first matching when wins and nothing falls through
v = case 1 when 1 then "first" when Integer then "second" end
row 6, "1: when 1 ... when Integer", "#{v.inspect}  (no fall-through)"

# 7. case with no subject: each when is a condition
n = -4
v = case
    when n < 0 then "negative"
    when n == 0 then "zero"
    else "positive"
    end
row 7, "case with no subject, n = -4", v.inspect

# 8. no match and no else is nil; else catches the rest
v = case 99 when 1 then "one" end
w = case 99 when 1 then "one" else "other" end
row 8, "99: no when matches", "#{v.inspect}; with else -> #{w.inspect}"

# 9. === is a method, so a class of your own can answer it
class Even
  def self.===(n) = n.is_a?(Integer) && n.even?
end
v = [4, 7].map { |n| case n when Even then "even" else "odd" end }
row 9, "4, 7: when Even (a custom ===)", v.join(" / ")

# 10. a plain value compares with ==, and Integer#== is numeric
v = case 1.0 when 1 then "matched" else "no match" end
row 10, "1.0: when 1", "#{v}  (1 === 1.0 -> #{(1 === 1.0).inspect})"

# 11. nil is a value like any other
v = case nil when nil then "matched" else "no match" end
row 11, "nil: when nil", "#{v}  (NilClass === nil -> #{(NilClass === nil).inspect})"

# 12. the four === answers behind rows 1 to 4
row 12, "what when calls",
    "Integer === 3 -> #{Integer === 3}; (1..5) === 3 -> #{(1..5) === 3}; /ab/ === \"cab\" -> #{/ab/ === "cab"}; lambda === 150 -> #{->(n) { n > 100 } === 150}"
