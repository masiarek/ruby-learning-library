# Ranges: two dots include the end, three exclude it; endless and beginless
# ranges; step; cover? against include?; ranges in case, in slices and in sums.
# The Python twin (ranges_two_dots_and_three_py.py) prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-56s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

row 1,  "(1..5).to_a, (1...5).to_a",                            [(1..5).to_a, (1...5).to_a].inspect
row 2,  "(1..5).size, (1...5).size, (1..5).class",              [(1..5).size, (1...5).size, (1..5).class].inspect
row 3,  '("a".."e").to_a, ("a".."e").to_a.join',                [("a".."e").to_a, ("a".."e").to_a.join].inspect
row 4,  "(1..).first(3), (1..).end  (endless)",                 [(1..).first(3), (1..).end].inspect
row 5,  "(..5).include?(3), (..5).cover?(9)  (beginless)",      [(..5).include?(3), (..5).cover?(9)].inspect
row 6,  "(1..).to_a",                                           raises(RangeError) { (1..).to_a }
row 7,  "(1..10).step(3).to_a, ((1..10) % 3).to_a",             [(1..10).step(3).to_a, ((1..10) % 3).to_a].inspect
row 8,  "(1.0..2.0).step(0.5).to_a  (a Float range)",           (1.0..2.0).step(0.5).to_a.inspect
letters = "a".."z"
row 9,  '("a".."z"): include?("bb"), cover?("bb"), === "bb"',   [letters.include?("bb"), letters.cover?("bb"), letters === "bb"].inspect
row 10, "(1..10).include?(5.5), (1..10).to_a.include?(5.5)",    [(1..10).include?(5.5), (1..10).to_a.include?(5.5)].inspect

x = 42
size = case x
       when 1..10 then "small"
       when 11..100 then "medium"
       else "large"
       end
row 11, "case 42 when 1..10 / when 11..100 / else",             size.inspect

a = [10, 20, 30, 40, 50]
row 12, 'a[1..2], a[1...-1], a[..1], a[2..], "hello"[1..3]',    [a[1..2], a[1...-1], a[..1], a[2..], "hello"[1..3]].inspect
row 13, "(1..100).sum, (1..10**12).sum  (a formula, not a loop)", [(1..100).sum, (1..10**12).sum].inspect
row 14, "(1...5).last, (1...5).last(1), (1...5).max",           [(1...5).last, (1...5).last(1), (1...5).max].inspect
row 15, "(5..1).to_a, 5.downto(1).to_a",                        [(5..1).to_a, 5.downto(1).to_a].inspect
row 16, "(1..5) == (1...6), (1..5).to_a == (1...6).to_a",        [(1..5) == (1...6), (1..5).to_a == (1...6).to_a].inspect
row 17, "(1..5)[1]  (a Range is not indexable)",                raises(NoMethodError) { (1..5)[1] }
row 18, "7.clamp(1..5), (1..5).cover?(2..3), (1..5).frozen?",   [7.clamp(1..5), (1..5).cover?(2..3), (1..5).frozen?].inspect
