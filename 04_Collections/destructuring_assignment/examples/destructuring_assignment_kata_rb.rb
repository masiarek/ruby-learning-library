# Kata: destructure "name age city ..." records with a splat, tolerating missing
# and extra fields -- a missing field is nil, extra fields land in the splat --
# then destructure the pairs that divmod, minmax and partition return.

lines = ["ada 36 london", "bob 41", "cy 29 paris texas"]
lines.each do |line|
  name, age, *rest = line.split
  city = rest.first || "(unknown)"
  extra = rest.drop(1)
  printf("%-4s age %-4s city %-10s extra %s\n", name, age.inspect, city, extra.inspect)
end

first, *middle, last = lines
puts "first #{first.inspect}, middle #{middle.inspect}, last #{last.inspect}"

lo, hi = [5, 3, 9].minmax
q, r = 17.divmod(5)
evens, odds = (1..6).partition(&:even?)
puts "minmax #{[lo, hi].inspect}, divmod #{[q, r].inspect}, partition #{[evens, odds].inspect}"
