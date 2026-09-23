# A method call walks `ancestors` left to right; `super` continues the walk
# from where the current method was found. Each row is printed by the Python twin too.

def row(n, label, value)
  puts format("%2d. %-58s %s", n, label, value)
end

def failing
  yield
rescue NoMethodError => e
  "#{e.class}: #{e.message}"
end

class Animal
  def speak(times = 1) = "animal x#{times}"
  def shout(times = 1) = "ANIMAL x#{times}"
  def move = "animal moves"
end

module Walkable
  def move = "walk, then " + super           # a module's super reaches the superclass
end

module Wrapped
  def speak(times = 1) = "[" + super + "]"   # prepended: runs before Dog#speak
end

class Dog < Animal
  include Walkable
  prepend Wrapped

  def speak(times = 1) = "dog:" + super      # zsuper: passes the same arguments on

  def shout(times = 1)
    times += 1                               # zsuper passes the parameter's current value
    super
  end

  def method_missing(name, *args)
    name.to_s.start_with?("fl") ? "method_missing caught #{name}" : super
  end

  def inspect = "#<Dog>"
end

class Cat < Animal
  def speak(times = 1) = "cat:" + super()    # super(): passes nothing, so Animal's default applies
  def purr = super                           # no ancestor has purr
end

dog = Dog.new

row 1, "Dog.ancestors", Dog.ancestors.inspect

module A; end
module B; include A; end
module C; include A; end
class D; include B; include C; end           # 2. the diamond, with modules
row 2, "the diamond (B and C include A) -- D.ancestors.take(4)", D.ancestors.take(4).inspect

row 3, "zsuper -- Dog.new.speak(3)", dog.speak(3).inspect
row 4, "super() -- Cat.new.speak(3)", Cat.new.speak(3).inspect
row 5, "zsuper after times += 1 -- Dog.new.shout(3)", dog.shout(3).inspect
row 6, "super inside a module method -- dog.move", dog.move.inspect

class Base
  def initialize = @base = true
end

class Forgetful < Base
  def initialize = @sub = true               # never calls super: Base#initialize is skipped
end

class Careful < Base
  def initialize
    super
    @sub = true
  end
end
row 7, "initialize without super / with super -- instance_variables",
    "#{Forgetful.new.instance_variables.inspect} / #{Careful.new.instance_variables.inspect}"

owners = []
m = dog.method(:speak)
while m
  owners << m.owner
  m = m.super_method
end
row 8, "method(:speak).owner, then super_method, until nil", owners.inspect

row 9, "super with no superclass method -- Cat.new.purr", failing { Cat.new.purr }
row 10, "ends in method_missing -- dog.fly / respond_to?(:fly)",
    "#{dog.fly.inspect} / #{dog.respond_to?(:fly)}"
row 11, "Dog.superclass / BasicObject.superclass / method(:puts).owner",
    "#{Dog.superclass} / #{BasicObject.superclass.inspect} / #{dog.method(:puts).owner}"
