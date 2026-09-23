# `&x` in an argument list calls x.to_proc and passes the result as the
# block. Symbol#to_proc builds a lambda that calls the named method on its
# first argument, handing over the rest -- which is why map(&:upcase) and
# inject(&:+) both work. Method, Hash and any class with to_proc take the
# same door. The Python twin prints the same rows.

W = 44
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def double(x) = x * 2

class Doubler
  def to_proc = ->(x) { x * 2 }
end

xs = %w[a b]
row 1, "map(&:upcase):", xs.map(&:upcase).to_s

pr = :upcase.to_proc
row 2, "what &:sym builds, called by hand:", ":upcase -> #{pr.call("a").inspect}, :+ with (1, 2) -> #{:+.to_proc.call(1, 2)}"
row 3, "so inject works; a bare symbol works too:", "inject(&:+) #{[1, 2, 3].inject(&:+)}, inject(:+) #{[1, 2, 3].inject(:+)}, reduce(10, :+) #{[1, 2, 3].reduce(10, :+)}"
row 4, "the proc's shape:", "lambda? #{pr.lambda?}, arity #{pr.arity}, parameters #{pr.parameters}"
row 5, "&method(:double), a Method's to_proc:", "#{[1, 2].map(&method(:double))}, lambda? #{method(:double).to_proc.lambda?}"
row 6, "&\"xaby\".method(:index), bound to a receiver:", xs.map(&"xaby".method(:index)).to_s
row 7, "& calls to_proc on any object:", "map(&Doubler.new) #{[1, 2].map(&Doubler.new)}"
row 8, "a Hash has to_proc, keys in, values out:", "[:a, :b].map(&{a: 1, b: 2}) #{[:a, :b].map(&{a: 1, b: 2})}"

refused = begin
  [1].map(&"upcase")
rescue TypeError => e
  "#{e.class}: #{e.message}"
end
row 9, "&\"upcase\" is refused; &nil passes no block:", "#{refused}; map(&nil) -> #{[1, 2].map(&nil).class}"

begin
  pr.call
rescue ArgumentError => e
  row 10, "the proc needs a receiver:", "#{e.class}: #{e.message}"
end

begin
  [1].map(&:puts)
rescue NoMethodError => e
  row 11, "&:sym dispatches like public_send:", "#{e.class}: #{e.message}"
end
