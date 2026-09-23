# `include` puts a module behind the class, `prepend` in front of it, and
# `extend` adds it to one object. Each row is printed by the Python twin too.

def row(n, label, value)
  puts format("%2d. %-58s %s", n, label, value)
end

def failing
  yield
rescue NoMethodError, TypeError => e
  "#{e.class}: #{e.message}"
end

TRACE = []

module Greeting
  def greet
    TRACE << :Greeting
    "hello from #{name}"
  end
end

class Person
  include Greeting                           # 1. behind Person in the chain
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def inspect = "#<Person #{@name}>"
end

ann = Person.new("ann")
bob = Person.new("bob")

row 1, "include Greeting -- Person.ancestors.first(3)",
    "#{Person.ancestors.first(3).inspect}; ann.greet: #{ann.greet.inspect}"
row 2, "Person.include?(Greeting) / included_modules - Object's",
    "#{Person.include?(Greeting)} / #{(Person.included_modules - Object.included_modules).inspect}"

module Shouting
  def shout = "#{name.upcase}!"
end
bob.extend(Shouting)                          # 3. this one object only
row 3, "bob.extend(Shouting) -- bob.shout / ann.shout",
    "#{bob.shout.inspect} / #{failing { ann.shout }}"

module Counting
  def count = "#{self} counts"
end

class Registry
  extend Counting                             # 4. into the class's singleton: a class method
end
row 4, "extend in a class body -- Registry.count",
    "#{Registry.count.inspect}; singleton_class.include?: #{Registry.singleton_class.include?(Counting)}"

module Loud
  def greet
    TRACE << :Loud
    super.upcase                              # reaches Person#greet
  end
end

class Person
  prepend Loud                                # 5. in front of Person in the chain

  def greet
    TRACE << :Person
    "person says " + super                    # reaches Greeting#greet
  end
end
row 5, "prepend Loud -- Person.ancestors.first(4)", Person.ancestors.first(4).inspect

TRACE.clear
result = ann.greet
row 6, "ann.greet: the result / the order the methods ran", "#{result.inspect} / #{TRACE.inspect}"

before = Person.ancestors.size
Person.include(Greeting)                      # 7. already there: nothing changes
row 7, "include Greeting a second time -- ancestors grew?", (Person.ancestors.size != before).to_s

class Version
  include Comparable                          # 8. one method in, six methods out
  attr_reader :n

  def initialize(n)
    @n = n
  end

  def <=>(other) = n <=> other.n
  def inspect = "v#{n}"
end
row 8, "include Comparable + <=> -- v1 < v2 / v5.clamp(v1, v3)",
    "#{Version.new(1) < Version.new(2)} / #{Version.new(5).clamp(Version.new(1), Version.new(3)).inspect}"

class Deck
  include Enumerable                          # 9. one method in, dozens out

  def each
    %w[b a c].each { |card| yield card }
  end
end
row 9, "include Enumerable + each -- sort / include?(\"a\")",
    "#{Deck.new.sort.inspect} / #{Deck.new.include?("a")}"

row 10, "a module is not a class: Class.new(Greeting)", failing { Class.new(Greeting) }
