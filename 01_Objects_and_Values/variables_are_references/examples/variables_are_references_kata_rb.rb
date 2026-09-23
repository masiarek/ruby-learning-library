# Kata: trace whether a and b share one object after each step. equal? is the
# identity test; << mutates the shared object, += and dup make a new one.

def sharing?(a, b) = a.equal?(b)

def show(step, a, b)
  puts "   #{step.ljust(12)} a = #{a.inspect.ljust(12)} b = #{b.inspect.ljust(12)} sharing? #{sharing?(a, b)}"
end

a = [1]
b = a
show "b = a", a, b
b << 2
show "b << 2", a, b
b += [3]
show "b += [3]", a, b
b = a.dup
show "b = a.dup", a, b
b << 4
show "b << 4", a, b
