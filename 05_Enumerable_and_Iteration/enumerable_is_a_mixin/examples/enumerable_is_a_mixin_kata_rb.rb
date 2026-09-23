# Kata: a Fibonacci sequence that stops at a limit, made Enumerable by one `each`.
class Fib
  include Enumerable

  def initialize(limit) = @limit = limit

  def each
    return to_enum(:each) unless block_given?
    a, b = 0, 1
    while a <= @limit
      yield a
      a, b = b, a + b
    end
    self
  end
end

def row(n, label, value) = puts(format("%2d. %-42s %s", n, label, value.inspect))

fib = Fib.new(100)
row 1, "to_a", fib.to_a
row 2, "select(&:even?)", fib.select(&:even?)
row 3, "each_cons(2).map { |a, b| b - a }", fib.each_cons(2).map { |a, b| b - a }
row 4, "include?(21), include?(22)", [fib.include?(21), fib.include?(22)]
row 5, "sum", fib.sum
row 6, "min_by { |x| (x - 50).abs }", fib.min_by { |x| (x - 50).abs }
row 7, "each_slice(4).to_a", fib.each_slice(4).to_a
row 8, "each.class, each.next", [fib.each.class, fib.each.next]
row 9, "lazy.map { |x| x * x }.first(3)", fib.lazy.map { |x| x * x }.first(3)
row 10, "each_with_index.select { |x, i| x == i }", fib.each_with_index.select { |x, i| x == i }.map(&:first)
