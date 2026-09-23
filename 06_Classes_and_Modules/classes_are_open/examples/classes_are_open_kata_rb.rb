# Exercise 1: give Integer `minutes` and `hours` (in seconds, as ActiveSupport
# does), use them, then take them away again with remove_method.

class Integer
  def minutes = self * 60
  def hours   = self * 3600
end

puts "5.minutes:                    #{5.minutes}"
puts "2.hours:                      #{2.hours}"
puts "2.hours + 5.minutes:          #{2.hours + 5.minutes}"
puts "owner of minutes:             #{Integer.instance_method(:minutes).owner}"
puts "Integer.method_defined?(:hours): #{Integer.method_defined?(:hours)}"

class Integer
  remove_method :minutes, :hours
end

begin
  5.minutes
rescue NoMethodError => e
  puts "after remove_method:          #{e.class}: #{e.message}"
end
