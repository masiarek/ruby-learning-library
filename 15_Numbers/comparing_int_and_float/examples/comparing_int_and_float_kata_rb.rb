# Kata: same_key?(a, b) says whether a Hash would treat a and b as one key
# (eql? and hash must both agree), and a real Hash confirms each answer.

def same_key?(a, b) = a.eql?(b) && a.hash == b.hash

pairs = [[1, 1.0], [1, 1r], [1.0, 1.0], [0.0, -0.0], ["a", "a"], [:a, "a"], [2 ** 64, 2 ** 64]]
puts format("%-22s %-22s  %-6s %-10s %s", "a", "b", "a == b", "same_key?", "keys in {a => 1, b => 2}")
pairs.each do |a, b|
  puts format("%-22s %-22s  %-6s %-10s %d", a.inspect, b.inspect, a == b, same_key?(a, b), { a => 1, b => 2 }.size)
end
