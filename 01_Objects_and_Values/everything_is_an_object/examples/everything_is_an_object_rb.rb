# Everything is an object: a literal, nil, true, a class and Class itself each
# have a class, answer methods and sit on an ancestor chain. The Python twin
# (everything_is_an_object_py.py) prints the same numbered rows.

def row(label, shown)
  puts "   #{label.ljust(30)} #{shown}"
end

puts "1. every value has a class"
row "1.class", 1.class.inspect
row "nil.class", nil.class.inspect
row "true.class", true.class.inspect
row "Integer.class", Integer.class.inspect
row "Class.class", Class.class.inspect

puts "2. an operator is a method call"
row "1 + 2", (1 + 2).inspect
row "1.+(2)", 1.+(2).inspect
row "1.send(:+, 2)", 1.send(:+, 2).inspect

puts "3. nil is an object with methods"
row "nil.to_a", nil.to_a.inspect
row "nil.to_s", nil.to_s.inspect
row "nil.inspect", nil.inspect.inspect

puts "4. a literal is a receiver"
row "3.times.to_a", 3.times.to_a.inspect
row "\"a\".upcase", "a".upcase.inspect
row "1.class (no parentheses)", 1.class.inspect

puts "5. the ancestor chain"
row "Integer.ancestors", Integer.ancestors.inspect
row "NilClass.ancestors", NilClass.ancestors.inspect

puts "6. everything is an Object, classes included"
row "1.is_a?(Object)", 1.is_a?(Object).inspect
row "nil.is_a?(Object)", nil.is_a?(Object).inspect
row "Integer.is_a?(Object)", Integer.is_a?(Object).inspect
row "Integer.is_a?(Class)", Integer.is_a?(Class).inspect

puts "7. even the top level is an object"
row "self.inspect", self.inspect.inspect
row "self.class", self.class.inspect

puts "8. what a small integer cannot do"
begin
  1.singleton_class
rescue TypeError => e
  row "1.singleton_class", e.class.to_s
end
