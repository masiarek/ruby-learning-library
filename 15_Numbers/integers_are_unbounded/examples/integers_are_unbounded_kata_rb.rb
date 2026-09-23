# Kata: 100! with nothing but Integer — count its digits and bits, find its
# trailing zeros, check Integer.sqrt against the exact square, and see what
# a trip through Float costs.

f = (1..100).inject(:*)
puts "1. 100! has #{f.to_s.size} digits and #{f.bit_length} bits"
puts "2. it starts #{f.to_s[0, 12]}... and ends in #{f.digits.take_while(&:zero?).size} zeros"
root = Integer.sqrt(f)
puts "3. Integer.sqrt(100!) has #{root.to_s.size} digits; root ** 2 <= 100! is #{root**2 <= f}, (root + 1) ** 2 > 100! is #{(root + 1)**2 > f}"
puts "4. 100! as a Float is #{f.to_f}; f.to_f.to_i == f is #{f.to_f.to_i == f}"
puts "5. 100! % 1_000_007 is #{f % 1_000_007}, and (1..100).inject(1) { |acc, i| acc * i % 1_000_007 } is #{(1..100).inject(1) { |acc, i| acc * i % 1_000_007 }}"
