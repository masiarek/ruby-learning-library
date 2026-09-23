# Kata: a `Documented` hook. Extending a class with it makes `method_added`
# look at the source line above each new `def` and report whether a comment
# is there.
module Documented
  def method_added(name)
    file, line = instance_method(name).source_location
    above = File.readlines(file, chomp: true)[line - 2].to_s.strip
    puts format("%-18s %s", "#{self}##{name}:", above.start_with?("#") ? "documented (#{above})" : "NO COMMENT ABOVE")
    super
  end
end

class Calc
  extend Documented

  # Adds two numbers.
  def add(a, b) = a + b

  def sub(a, b) = a - b

  # Multiplies, the long way.
  def mul(a, b) = a * b
end
