# Every object has a class of its own: the singleton class. A method defined on
# one object lives there, and so do class methods. The Python twin,
# singleton_classes_py.py, prints the same numbered rows.

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-46s %s", label, value))
def names(mods) = mods.map { |m| m.singleton_class? ? "(singleton)" : m.name }

class Foo
  def initialize(name) = @name = name
  def inspect = "#<#{self.class} #{@name}>"
  def self.make = new("made")
  class << self
    def build = "built by #{name}"
  end
end

class Sub < Foo; end

module Loud
  def shout = "LOUD from #{@name}"
end

obj = Foo.new("obj")
other = Foo.new("other")

section 1, "a method defined on one object"
def obj.greet = "hi from #{@name}"
row "obj.greet", obj.greet
begin
  other.greet
rescue NoMethodError => e
  row "other.greet", e.class
end

section 2, "where that method lives"
row "obj.singleton_methods", obj.singleton_methods.inspect
row "Foo.instance_methods(false).sort", Foo.instance_methods(false).sort.inspect
row "obj.singleton_class.superclass == Foo", obj.singleton_class.superclass == Foo
row "obj.singleton_class.singleton_class?", obj.singleton_class.singleton_class?
row "obj.class", obj.class
row "obj.instance_of?(Foo)", obj.instance_of?(Foo)

section 3, "class << obj opens the singleton class"
class << obj
  def name_length = @name.length
end
row "obj.name_length", obj.name_length
row "obj.singleton_methods.sort", obj.singleton_methods.sort.inspect

section 4, "class methods are singleton methods of the class"
row "Foo.singleton_methods.sort", Foo.singleton_methods.sort.inspect
row "Foo.make", Foo.make.inspect
row "Foo.build", Foo.build
begin
  Foo.new("x").make
rescue NoMethodError => e
  row "Foo.new(\"x\").make", e.class
end

section 5, "a class's singleton class has a name"
row "Foo.singleton_class", Foo.singleton_class
row "Foo.singleton_class.ancestors.first(3)", Foo.singleton_class.ancestors.first(3).inspect
row "Foo.singleton_class.class", Foo.singleton_class.class
row "Foo.singleton_class.superclass", Foo.singleton_class.superclass
row "Class.class", Class.class
row "Sub.singleton_class.superclass", Sub.singleton_class.superclass
row "Sub.make  (class methods are inherited)", Sub.make.inspect

section 6, "define_singleton_method takes a block"
obj.define_singleton_method(:wave) { "wave from #{@name}" }
row "obj.wave", obj.wave

section 7, "extend is include into the singleton class"
obj.extend(Loud)
row "obj.singleton_class.include?(Loud)", obj.singleton_class.include?(Loud)
row "obj.singleton_class.ancestors (names)", names(obj.singleton_class.ancestors).inspect
row "obj.shout", obj.shout
row "other.respond_to?(:shout)", other.respond_to?(:shout)

section 8, "dup drops the singleton class, clone keeps it"
copy = obj.dup
twin = obj.clone
row "obj.dup.singleton_methods", copy.singleton_methods.inspect
row "obj.clone.singleton_methods.sort", twin.singleton_methods.sort.inspect
twin.instance_variable_set(:@name, "clone")
row "clone.wave after renaming the clone", twin.wave

section 9, "immediates have no singleton class"
begin
  1.singleton_class
rescue TypeError => e
  row "1.singleton_class", "#{e.class}: #{e.message}"
end
begin
  :sym.singleton_class
rescue TypeError => e
  row ":sym.singleton_class", "#{e.class}: #{e.message}"
end
row "nil.singleton_class", nil.singleton_class
