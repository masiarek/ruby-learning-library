# Foo.new is two steps: Class#allocate makes an empty object, then the private
# instance method initialize fills it in. The Python twin,
# new_allocate_and_initialize_py.py, prints the same numbered rows.

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-44s %s", label, value))

class Point
  attr_reader :x, :y

  def initialize(x, y)
    puts "   (initialize(#{x}, #{y}) runs; self is a #{self.class})"
    @x, @y = x, y
    :the_return_value_is_ignored
  end

  def initialize_copy(original)
    puts "   (initialize_copy runs, copying #{original.inspect})"
    super
  end

  def inspect = "#<Point #{@x.inspect},#{@y.inspect}>"
end

class Point3 < Point
  def initialize(x, y, z)
    super(x, y)
    @z = z
  end

  def inspect = "#<Point3 #{@x},#{@y},#{@z}>"
end

class Color
  @cache = {}
  attr_reader :name

  def self.new(name)
    @cache[name] ||= super
  end

  def initialize(name)
    puts "   (Color#initialize(#{name.inspect}) runs)"
    @name = name
  end

  def inspect = "#<Color #{@name}>"
end

class Shape
  def self.new(*args)
    return super unless self == Shape
    kind, *rest = args
    { circle: Circle, square: Square }.fetch(kind).new(*rest)
  end

  def initialize(size) = @size = size
  def inspect = "#<#{self.class} size=#{@size}>"
end

class Circle < Shape; end
class Square < Shape; end

section 1, "new is allocate, then initialize"
row "Point.new(1, 2)", Point.new(1, 2).inspect
row "Point.method(:new).owner", Point.method(:new).owner
row "Point.method(:allocate).owner", Point.method(:allocate).owner

section 2, "initialize is private automatically"
row "Point.private_instance_methods(false).sort", Point.private_instance_methods(false).sort.inspect
pt = Point.new(1, 2)
begin
  pt.initialize(3, 4)
rescue NoMethodError => e
  row "pt.initialize(3, 4)", "#{e.class}: #{e.message}"
end
pt.send(:initialize, 3, 4)
row "pt.send(:initialize, 3, 4); pt", pt.inspect

section 3, "allocate skips initialize"
blank = Point.allocate
row "Point.allocate", blank.inspect
row "blank.instance_variables", blank.instance_variables.inspect
row "blank.x", blank.x.inspect
blank.send(:initialize, 5, 6)
row "blank.send(:initialize, 5, 6); blank", blank.inspect

section 4, "initialize's return value is ignored"
row "Point.new(0, 0).class", Point.new(0, 0).class

section 5, "arguments go straight to initialize"
begin
  Point.new(1)
rescue ArgumentError => e
  row "Point.new(1)", "#{e.class}: #{e.message}"
end

section 6, "overriding self.new: a cache"
red1 = Color.new("red")
red2 = Color.new("red")
blue = Color.new("blue")
row "Color.new(\"red\").equal?(Color.new(\"red\"))", red1.equal?(red2)
row "red.equal?(blue)", red1.equal?(blue)

section 7, "overriding self.new: a factory"
row "Shape.new(:circle, 3)", Shape.new(:circle, 3).inspect
row "Shape.new(:square, 4)", Shape.new(:square, 4).inspect
row "Circle.new(5)", Circle.new(5).inspect

section 8, "initialize_copy runs on dup and clone"
original = Point.new(7, 8)
row "original.dup", original.dup.inspect
row "original.clone", original.clone.inspect

section 9, "classes with no allocator or no new"
begin
  Integer.allocate
rescue TypeError => e
  row "Integer.allocate", "#{e.class}: #{e.message}"
end
begin
  Integer.new
rescue NoMethodError => e
  row "Integer.new", "#{e.class}: #{e.message}"
end
begin
  NilClass.new
rescue NoMethodError => e
  row "NilClass.new", "#{e.class}: #{e.message}"
end

section 10, "a subclass calls super inside initialize"
row "Point3.new(1, 2, 3)", Point3.new(1, 2, 3).inspect
row "Point3.instance_method(:initialize).arity", Point3.instance_method(:initialize).arity
