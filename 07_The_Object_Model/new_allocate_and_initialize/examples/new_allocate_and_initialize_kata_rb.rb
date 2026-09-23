# Exercise 1: a shared zero. Money.new(0) always returns one object, built once;
# every other amount is a fresh object. Count how often initialize runs, then
# show that allocate walks around the override entirely.

class Money
  @built = 0

  class << self
    attr_reader :built

    def new(cents)
      return @zero ||= super if cents.zero?
      super
    end

    def count_one = @built += 1
  end

  attr_reader :cents

  def initialize(cents)
    Money.count_one
    @cents = cents
  end

  def inspect = "#<Money #{@cents}c>"
end

zero_a = Money.new(0)
zero_b = Money.new(0)
five_a = Money.new(5)
five_b = Money.new(5)

puts "Money.new(0)                        #{zero_a.inspect}"
puts "Money.new(0).equal?(Money.new(0))   #{zero_a.equal?(zero_b)}"
puts "Money.new(5).equal?(Money.new(5))   #{five_a.equal?(five_b)}"
puts "times initialize ran                #{Money.built}"
puts "Money.allocate.cents                #{Money.allocate.cents.inspect}"
puts "times initialize ran after allocate #{Money.built}"
