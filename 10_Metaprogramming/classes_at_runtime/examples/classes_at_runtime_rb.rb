# classes_at_runtime_rb.rb — a class is an object; Class.new makes one, a constant names it.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

HOOK_LOG = []
class Animal
  def speak = "..."
  def self.inherited(sub) = (HOOK_LOG << sub.name; super)           # 9. sees the name — or nil
end

k = Class.new(Animal) { def speak = "woof" }             # 1. the block is class_eval'd
row 1, 'k = Class.new(Animal) { def speak = "woof" }', "k.new.speak = #{k.new.speak.inspect}"
row 2, "k.name -- anonymous so far", k.name.inspect
Dog = k                                                  # 3. the first constant assignment names it
row 3, "Dog = k; k.name", k.name.inspect
Hound = Dog
row 4, "Hound = Dog; Hound.name -- the first name sticks", Hound.name.inspect

module Zoo; end
cat = Class.new
Zoo.const_set(:Cat, cat)                                 # 5. naming under a module
row 5, "Zoo.const_set(:Cat, cat); cat.name", cat.name.inspect
row "", 'Object.const_get("Zoo::Cat").equal?(cat)', Object.const_get("Zoo::Cat").equal?(cat)

greeting = Module.new { def hi = "hi" }                  # 6. an anonymous module
Dog.include(greeting)
row 6, "Dog.include(Module.new { def hi }); Dog.new.hi", "#{Dog.new.hi.inspect}, module name = #{greeting.name.inspect}"
Greeting = greeting
row "", "Greeting = greeting; Dog.ancestors.first(2)", Dog.ancestors.first(2).inspect

Point = Struct.new(:x, :y)                               # 7. the built-in class factories
Coord = Data.define(:lat, :lng)
row 7, "Point = Struct.new(:x, :y); Point.new(1, 2)", Point.new(1, 2).inspect
row "", "Coord = Data.define(:lat, :lng); Coord.new(1, 2)", Coord.new(1, 2).inspect

row 8, "k.class / k.superclass / Class.new.superclass", "#{k.class} / #{k.superclass} / #{Class.new.superclass}"
row "", "k.is_a?(Module) / k.instance_of?(Class)", "#{k.is_a?(Module)} / #{k.instance_of?(Class)}"

class Kitten < Animal; end
row 9, "Animal.inherited saw, in order (k, then Kitten)", HOOK_LOG.inspect

factor = 3                                               # 10. the block is a closure
triple = Class.new { define_method(:triple) { |x| x * factor } }
row 10, "Class.new { define_method(:triple) { |x| x * factor } }", "new.triple(3) = #{triple.new.triple(3)}"

begin                                                    # 11. what cannot be a superclass
  Class.new(Class)
rescue TypeError => e
  row 11, "Class.new(Class)", "#{e.class}: #{e.message}"
end
begin
  Class.new(Comparable)
rescue TypeError => e
  row "", "Class.new(Comparable) -- a Module", "#{e.class}: #{e.message}"
end

begin                                                    # 12. a name must be a constant
  Object.const_set(:lower, Class.new)
rescue NameError => e
  row 12, "Object.const_set(:lower, Class.new)", "#{e.class}: #{e.message}"
end

row 13, "Object.const_defined?(:Hound)", Object.const_defined?(:Hound)
removed = Object.send(:remove_const, :Hound)
row "", "Object.send(:remove_const, :Hound) -> then defined?", "#{removed.name.inspect} / #{Object.const_defined?(:Hound)}"

def make_class = Class.new { def id = :made }             # 14. a fresh class per call
row 14, "make_class.equal?(make_class) / make_class.name", "#{make_class.equal?(make_class)} / #{make_class.name.inspect}"
row 15, "Class.new(Animal) takes no keyword options", "configure with a class method afterwards"
