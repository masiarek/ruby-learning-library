# Exercise 1: the diamond with modules -- print the chain, then let each
# `name` call super and append itself, so the walk is visible in the result.

module A
  def name = "A"
end

module B
  include A
  def name = "B > " + super
end

module C
  include A
  def name = "C > " + super
end

class D
  include B
  include C
  def name = "D > " + super
end

puts "D.ancestors up to Object: #{D.ancestors.take_while { |m| m != Object }.inspect}"
puts "D.new.name:               #{D.new.name}"
puts "A appears once, and the module included last (C) is reached first"
