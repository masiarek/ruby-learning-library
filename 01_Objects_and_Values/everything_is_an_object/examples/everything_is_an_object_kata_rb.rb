# Kata: describe(x) prints the class of x and its ancestors up to Object, so a
# reader can see that a literal, nil, a string, an array and a class all sit on
# the same kind of chain.

def describe(x)
  chain = x.class.ancestors.take_while { |m| m != Kernel }
  puts "   #{x.inspect.ljust(8)} #{x.class.to_s.ljust(9)} #{chain.join(' > ')}"
end

puts "value    class     ancestors up to Object"
[1, nil, "a", [], Integer].each { |x| describe(x) }
