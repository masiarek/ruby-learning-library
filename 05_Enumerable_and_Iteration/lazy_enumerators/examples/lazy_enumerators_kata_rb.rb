# Kata: primes, lazily. An endless range, one select, and consumers that stop.
def row(n, label, value) = puts(format("%2d. %-46s %s", n, label, value.inspect))

tested = 0
prime = ->(n) { tested += 1; (2..Integer.sqrt(n)).none? { |d| (n % d).zero? } }
primes = (2..).lazy.select(&prime)

row 1, "primes.first(10)", primes.first(10)
row 2, "candidates tested for those ten", tested
tested = 0
row 3, "primes.find { |p| p > 1000 }", primes.find { |p| p > 1000 }
row 4, "candidates tested for that one", tested
row 5, "primes.each_slice(3).first(2)", primes.each_slice(3).first(2)
row 6, "twin primes: each_cons(2).select { gap 2 }.first(4)", primes.each_cons(2).select { |a, b| b - a == 2 }.first(4)
row 7, "primes.map { p * p }.take_while { < 200 }.to_a", primes.map { |p| p * p }.take_while { |x| x < 200 }.to_a
row 8, "primes.with_index(1).find { |_, i| i == 100 }", primes.with_index(1).find { |_, i| i == 100 }
