# introspection_rb.rb — asking an object, a class and a method what they are.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

def where(method) = method.source_location.then { |file, line| "#{File.basename(file)}:#{line}" }

module Geometry
  ORIGIN = [0, 0]

  class Point
    include Comparable
    attr_reader :x, :y

    def initialize(x, y) = (@x, @y = x, y)
    def self.origin = new(0, 0)
    def area = 0
    def move!(dx, dy) = (@x += dx; @y += dy; self)
    def configure(a, b = 1, *r, k:, d: 2, **o, &blk) = nil
    def <=>(other) = [x, y] <=> [other.x, other.y]

    private

    def secret = 1
  end
end

class Probe                                            # rows 9-11: inside a method
  def locals = (a = 1; b = 2; local_variables)
  def whoami = __method__
  def defined_table(a)
    [defined?(a), defined?(String), defined?(Nope), defined?(puts), defined?(nope),
     defined?(@x), defined?(a = 1), defined?(3), defined?(self), defined?($stdout), defined?(yield), defined?(super)]
  end
  def initialize = @x = 1
end

point = Geometry::Point.new(1, 2)
klass = Geometry::Point

row 1, "point.methods - Object.instance_methods (sorted)", (point.methods - Object.instance_methods).sort.inspect
row 2, "Point.instance_methods(false).sort", klass.instance_methods(false).sort.inspect
row "", "Point.private_instance_methods(false).sort", klass.private_instance_methods(false).sort.inspect
row 3, "point.instance_variables", point.instance_variables.inspect
row "", "instance_variable_get(:@x) for each", point.instance_variables.to_h { |v| [v, point.instance_variable_get(v)] }.inspect
row 4, "instance_method(:configure).parameters", klass.instance_method(:configure).parameters.inspect
row "", "arity of configure / area / move!",
    "#{klass.instance_method(:configure).arity} / #{klass.instance_method(:area).arity} / #{klass.instance_method(:move!).arity}"
row 5, "instance_method(:area).source_location", where(klass.instance_method(:area))
row 6, "Point.ancestors", klass.ancestors.inspect
row 7, "Geometry.constants.sort", Geometry.constants.sort.inspect
row "", "Geometry.const_source_location(:ORIGIN)", Geometry.const_source_location(:ORIGIN).then { |f, l| "#{File.basename(f)}:#{l}" }
row 8, "Point.singleton_methods", klass.singleton_methods.inspect
point.define_singleton_method(:label) { "P" }
row "", "after define_singleton_method: point.singleton_methods", point.singleton_methods.inspect
probe = Probe.new
row 9, "local_variables inside a method (a = 1; b = 2)", probe.locals.inspect
row 10, "defined?(a) local / String / Nope / puts / nope", probe.defined_table(0)[0, 5].inspect
row "", "defined?(@x) / (a = 1) / 3 / self / $stdout", probe.defined_table(0)[5, 5].inspect
row "", "defined?(yield) / (super) with no block, no parent", probe.defined_table(0)[10, 2].inspect
row 11, "__method__ inside whoami", probe.whoami.inspect
row 12, "method(:area).owner / method(:between?).owner", "#{point.method(:area).owner} / #{point.method(:between?).owner}"
row "", "method_defined?(:area) / (:secret) / private_method_defined?(:secret)",
    "#{klass.method_defined?(:area)} / #{klass.method_defined?(:secret)} / #{klass.private_method_defined?(:secret)}"
row "", "instance_variable_defined?(:@x) / (:@z)", "#{point.instance_variable_defined?(:@x)} / #{point.instance_variable_defined?(:@z)}"
row 13, "point.class / Point.class / Geometry.class", "#{point.class} / #{klass.class} / #{Geometry.class}"
row "", "Point.name / Point.singleton_class", "#{klass.name.inspect} / #{klass.singleton_class.inspect}"
