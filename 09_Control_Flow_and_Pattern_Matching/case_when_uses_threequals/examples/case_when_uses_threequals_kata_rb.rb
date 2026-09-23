# Exercise 1: one classify method using a class, a Range, a Regexp, a lambda
# and a splat in its when clauses, run over a mixed list of inputs.

KEYWORDS = %w[if unless case]

def classify(x)
  case x
  when *KEYWORDS then "keyword"
  when 1..9 then "digit"
  when Integer then "integer"
  when Float then "float"
  when /\A[a-z]+\z/ then "word"
  when ->(v) { v.is_a?(Array) && v.size > 3 } then "long array"
  else "something else"
  end
end

[7, 42, 2.5, 9.5, "case", "ruby", "Ruby", [1, 2, 3, 4], nil].each do |x|
  puts format("%-14s -> %s", x.inspect, classify(x))
end

puts
puts "(1..9) === 2.5 -> #{(1..9) === 2.5}: a Range answers === with cover?, so 2.5 is a \"digit\""
puts "move `when Float` above the Range if that is not what you meant"
