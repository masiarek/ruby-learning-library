# Exercise 1: the same body under for and under each, then a leak audit with
# local_variables, then three lambdas from each kind of loop.

for i in 1..3
  total_for = i
end

(1..3).each do |j|
  total_each = j
end

%i[i total_for j total_each].each do |name|
  puts format("%-10s leaked? %s", name, local_variables.include?(name))
end

from_for = []
for k in 1..3
  from_for << -> { k }
end

from_each = []
(1..3).each { |m| from_each << -> { m } }

puts "lambdas from for  -> #{from_for.map(&:call).inspect}"
puts "lambdas from each -> #{from_each.map(&:call).inspect}"
