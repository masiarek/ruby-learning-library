# Exercise 1: a Temperature that keeps @celsius private, exposes celsius and a
# computed fahrenheit reader, and refuses a value below absolute zero.

class Temperature
  ABSOLUTE_ZERO = -273.15

  attr_reader :celsius

  def initialize(celsius)
    self.celsius = celsius            # go through the writer so the check runs
  end

  def celsius=(value)
    raise ArgumentError, "#{value} is below absolute zero" if value < ABSOLUTE_ZERO

    @celsius = value
  end

  def fahrenheit = @celsius * 9.0 / 5 + 32

  def inspect = "#<Temperature #{@celsius} C>"
end

t = Temperature.new(25)
puts "celsius:               #{t.celsius}"
puts "fahrenheit:            #{t.fahrenheit}"
puts "instance_variables:    #{t.instance_variables.inspect}"

t.celsius = 100
puts "after t.celsius = 100: #{t.fahrenheit}"

begin
  t.celsius = -300
rescue ArgumentError => e
  puts "t.celsius = -300:      #{e.class}: #{e.message}"
end
puts "still:                 #{t.inspect}"

begin
  t.fahrenheit = 0
rescue NoMethodError => e
  puts "t.fahrenheit = 0:      #{e.class} (no writer was defined)"
end
