# An Enumerator can be driven from outside: next pulls one value, peek looks
# ahead, StopIteration marks the end, rewind starts over. Rows are numbered so
# the Python twin (external_enumerators_py.py) can print the same row beside it.

def row(n, label, value) = puts(format("%2d. %-62s %s", n, label, value.inspect))

puts "next, peek, and the end"
e = [1, 2].each
row 1, "e = [1, 2].each; e.class", e.class
row 2, "e.next", e.next
row 3, "e.peek  (looks, does not advance)", e.peek
row 4, "e.next", e.next
begin
  e.next
rescue StopIteration => ex
  row 5, "e.next at the end raises: class, message, ex.result", [ex.class, ex.message, ex.result]
end
begin
  e.next
rescue StopIteration => ex
  row 6, "e.next again: still exhausted", ex.class
end
e.rewind
row 7, "e.rewind; e.next", e.next
row 8, "[1, 2].each.size, [1, 2].cycle.size, Enumerator.new {}.size", [[1, 2].each.size, [1, 2].cycle.size, Enumerator.new { }.size]

puts
puts "loop rescues StopIteration silently, and its value is the result"
arr = [10, 20, 30]
e2 = arr.each
seen = []
value = loop { seen << e2.next }
row 9, "seen; loop { e2.next }.equal?(arr)  (each returned arr)", [seen, value.equal?(arr)]

puts
puts "The external cursor is separate from internal iteration"
e3 = [10, 20, 30].each
first = e3.next
row 10, "e3.next; e3.to_a; e3.next  (to_a starts over, next does not)", [first, e3.to_a, e3.next]
row 11, "[1, 2].each.with_index(1).to_a", [1, 2].each.with_index(1).to_a

puts
puts "Enumerators built by hand, and what they leave in result"
en = Enumerator.new { |y| y << 1; y.yield 2; :done }
two = [en.next, en.next]
begin
  en.next
rescue StopIteration => ex
  row 12, "Enumerator.new { y << 1; y.yield 2; :done }: next x2, result", [two, ex.result]
end

def numbers
  return to_enum(:numbers) unless block_given?
  yield 1
  yield 2
  :the_return
end
em = numbers
row 13, "numbers (to_enum): loop { em.next } is the method's value", loop { em.next }

boom = Enumerator.new { |y| y << "a"; raise "boom" }
first = boom.next
begin
  boom.next
rescue RuntimeError => ex
  row 14, "a raise inside the block comes out of next", [first, "#{ex.class}: #{ex.message}"]
end
row 15, "Enumerator.produce(1) { |x| x * 2 }.take(5)", Enumerator.produce(1) { |x| x * 2 }.take(5)
row 16, "3.times.next, \"abc\".each_char.next, {a: 1}.each.next", [3.times.next, "abc".each_char.next, {a: 1}.each.next]
row 17, "StopIteration.ancestors.take(3)  (a bare rescue catches it)", StopIteration.ancestors.take(3)
begin
  e2.peek
rescue StopIteration => ex
  row 18, "e2.peek on the e2 that loop drained", ex.class
end
