# Exercise 1: a Counter with one shared @@total and a per-class @count.

class Counter
  @@total = 0

  def self.total = @@total
  def self.count = @count || 0

  def initialize
    @@total += 1                       # shared by every subclass
    self.class.instance_variable_set(:@count, self.class.count + 1)   # this class only
  end
end

class A < Counter; end
class B < Counter; end

2.times { A.new }
3.times { B.new }

puts "Counter.total: #{Counter.total}"
puts "A.total:       #{A.total}"
puts "A.count:       #{A.count}"
puts "B.count:       #{B.count}"
puts "Counter.count: #{Counter.count}"
