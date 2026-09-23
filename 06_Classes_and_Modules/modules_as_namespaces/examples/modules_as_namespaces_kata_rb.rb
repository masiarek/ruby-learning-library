# Exercise 1: a Geometry namespace with a module_function and a nested class
# that uses it, and the two things a module cannot do.

module Geometry
  module_function

  def area(radius) = (3.14159 * radius * radius).round(2)

  class Circle
    def initialize(radius)
      @radius = radius
    end

    def area = Geometry.area(@radius)     # the module method, by its full name
    def inspect = "#<Geometry::Circle r=#{@radius}>"
  end
end

puts "Geometry.area(1):              #{Geometry.area(1)}"
puts "Geometry::Circle.new(2).area:  #{Geometry::Circle.new(2).area}"
puts "Geometry.constants:            #{Geometry.constants.inspect}"
begin
  Geometry.new
rescue NoMethodError => e
  puts "Geometry.new:                  #{e.class}: #{e.message}"
end
begin
  Class.new(Geometry)
rescue TypeError => e
  puts "Class.new(Geometry):           #{e.class}: #{e.message}"
end
