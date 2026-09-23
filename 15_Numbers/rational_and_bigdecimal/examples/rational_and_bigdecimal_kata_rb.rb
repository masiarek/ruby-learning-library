# Kata: add 0.1 ten times as a Float, a Rational and a BigDecimal, then
# multiply a price by three — and see which results equal what a calculator
# says.
require "bigdecimal"

float_sum    = Array.new(10, 0.1).inject(:+)
rational_sum = Array.new(10, 0.1r).inject(:+)
decimal_sum  = Array.new(10, BigDecimal("0.1")).inject(:+)
puts "1. ten Floats with inject(:+): #{float_sum}   == 1 is #{float_sum == 1}"
puts "2. ten Floats with sum:        #{Array.new(10, 0.1).sum}   == 1 is #{Array.new(10, 0.1).sum == 1} (sum compensates; inject does not)"
puts "3. ten Rationals:              #{rational_sum.inspect}   == 1 is #{rational_sum == 1}"
puts "4. ten BigDecimals:            #{decimal_sum.to_s('F')}   == 1 is #{decimal_sum == 1}"
puts "5. 19.99 * 3: Float #{19.99 * 3}, Rational #{(19.99r * 3).inspect}, BigDecimal #{(BigDecimal('19.99') * 3).to_s('F')}"
