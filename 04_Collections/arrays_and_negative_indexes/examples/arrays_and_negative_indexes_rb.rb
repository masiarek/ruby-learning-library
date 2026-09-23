# Arrays: negative indexes, nil past the end, [start, length] slices, shared defaults.
# The Python twin (arrays_and_negative_indexes_py.py) prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-44s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

a = [10, 20, 30, 40]
row 1,  "a = [10, 20, 30, 40]; a.length",           a.length
row 2,  "a[0], a[-1]  (negative: from the end)",    [a[0], a[-1]].inspect
row 3,  "a[10], a[-10]  (past either end)",          [a[10], a[-10]].inspect
row 4,  "a.fetch(10)  (the raising form)",           raises(IndexError) { a.fetch(10) }
row 5,  "a.fetch(10, :none)",                        a.fetch(10, :none).inspect
row 6,  "a[1..2]  (two dots: end included)",         a[1..2].inspect
row 7,  "a[1...3]  (three dots: end excluded)",      a[1...3].inspect
row 8,  "a[1..]  (endless range: to the end)",       a[1..].inspect
row 9,  "a[1, 2]  (start, length)",                  a[1, 2].inspect
row 10, "a[4..], a[5..]  (slice at / past the end)", [a[4..], a[5..]].inspect

b = a.dup
b[5] = 99
row 11, "b[5] = 99 on a 4-element copy (pads)",      b.inspect
d = a.dup
row 12, "d = a.dup; d[-5] = 1  (before the start)", raises(IndexError) { d[-5] = 1 }
row 13, "a.first(2), a.last(2), [].first",           [a.first(2), a.last(2), [].first].inspect
row 14, "a.values_at(0, 2, 10)",                     a.values_at(0, 2, 10).inspect

x = Array.new(3, [])
x[0] << 1
row 15, "Array.new(3, []) then x[0] << 1  (shared)", x.inspect
y = Array.new(3) { [] }
y[0] << 1
row 16, "Array.new(3) { [] } then y[0] << 1 (fresh)", y.inspect

nested = [[1], [2, [3, [4]]]]
row 17, "nested.flatten, nested.flatten(1)",         [nested.flatten, nested.flatten(1)].inspect

c = [1, 2]
row 18, "c = [1, 2]; c.push(3) << 4  (returns c)",   (c.push(3) << 4).inspect
row 19, "c.pop, c.shift, then c",                    [c.pop, c.shift, c].inspect
row 20, "c.unshift(0)  (returns c)",                 c.unshift(0).inspect

def f(*args) = args
row 21, "[*a, 5], [*1..3], f(*a) with def f(*args)", [[*a, 5], [*1..3], f(*a)].inspect
row 22, "a - [20], a & [20, 99], a | [99]",          [a - [20], a & [20, 99], a | [99]].inspect
