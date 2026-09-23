# One `each` that yields, plus `include Enumerable`, gives a class the whole
# toolbox. `return to_enum(:each) unless block_given?` makes `each` with no
# block an Enumerator, `enum_for(__method__)` does the same for a plain
# method, and `Enumerator.new { |y| ... }` builds one -- lazily, even
# infinitely -- without a class. The Python twin prints the same rows.

W = 50
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

class Countdown
  include Enumerable

  def initialize(from) = @from = from

  def each
    return to_enum(:each) { @from } unless block_given?   # the block gives the size
    @from.downto(1) { |i| yield i }
    self
  end
end

def pair_sums(xs)
  return enum_for(__method__, xs) unless block_given?
  xs.each_cons(2) { |a, b| yield a + b }
end

c = Countdown.new(3)
row 1, "each yields; with a block it returns self:", "c.each { }.equal?(c) = #{c.each { }.equal?(c)}"
row 2, "the class defines each, Enumerable does the rest:", "instance_methods(false) #{Countdown.instance_methods(false)}; map #{c.map { _1 * 10 }}, select #{c.select(&:odd?)}, sort #{c.sort}, include?(2) #{c.include?(2)}, min #{c.min}, sum #{c.sum}, first(2) #{c.first(2)}"
row 3, "more for free:", "each_slice(2) #{c.each_slice(2).to_a}, each_cons(2) #{c.each_cons(2).to_a}, each_with_index #{c.each_with_index.to_a}, reduce(:+) #{c.reduce(:+)}, to_a #{c.to_a}"
e = c.each
row 4, "each without a block is an Enumerator:", "#{e.class}, size #{e.size}, next #{e.next}, with_index(1) #{c.each.with_index(1).to_a}"
row 5, "enum_for(__method__) in a plain method:", "pair_sums([1, 2, 3]) is #{pair_sums([1, 2, 3]).class}, to_a #{pair_sums([1, 2, 3]).to_a}"

three = Enumerator.new { |y| y << 1; y.yield 2; y << 3 }
pulled = [three.next, three.next, three.next]
after = begin
  three.next
rescue StopIteration => ex
  ex.class
end
row 6, "Enumerator.new { |y| y << 1; y.yield 2 }:", "to_a #{three.to_a}, next x3 #{pulled}, then #{after}, size #{three.size.inspect}"

fib = Enumerator.new do |y|
  a, b = 0, 1
  loop { y << a; a, b = b, a + b }     # never ends; the consumer stops it
end
row 7, "an infinite enumerator, consumed a piece at a time:", "take(8) #{fib.take(8)}, first(5) #{fib.first(5)}, each_slice(3).first(2) #{fib.each_slice(3).first(2)}"
row 8, "lazy chains filters without materialising:", "fib.lazy.select(&:even?).first(4) #{fib.lazy.select(&:even?).first(4)}, class #{fib.lazy.select(&:even?).class}, (1..).lazy.map { _1 * _1 }.first(3) #{(1..).lazy.map { _1 * _1 }.first(3)}"
row 9, "Enumerator.produce, a generator from a seed:", "produce(1) { _1 * 2 }.take(5) #{Enumerator.produce(1) { _1 * 2 }.take(5)}"
row 10, "Enumerable is a mixin, so the class says so:", "Countdown.include?(Enumerable) #{Countdown.include?(Enumerable)}, c.is_a?(Enumerable) #{c.is_a?(Enumerable)}"
