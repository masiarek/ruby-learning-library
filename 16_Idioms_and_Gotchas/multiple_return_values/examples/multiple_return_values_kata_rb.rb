# Kata: return three values two ways - as a bare Array, then as a Data.

Stats = Data.define(:min, :max, :mean)

def stats(numbers)
  return numbers.min, numbers.max, numbers.sum.fdiv(numbers.size)
end

def stats_data(numbers)
  Stats.new(*stats(numbers))
end

numbers = [4, 8, 15, 16, 23, 42]

lo, hi, mean = stats(numbers)
puts "as an Array:  #{stats(numbers).inspect}"
puts "destructured: min=#{lo} max=#{hi} mean=#{mean}"

s = stats_data(numbers)
puts "as a Data:    #{s.inspect}"
puts "by name:      s.mean=#{s.mean}"
s => { min:, max: }
puts "pattern:      min=#{min} max=#{max}"
