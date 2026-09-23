# Exercise 1: Integer#minutes and Integer#hours as a refinement. The rest of
# the file uses them; a method written above the `using` line cannot.

module Durations
  refine Integer do
    def minutes = self * 60
    def hours = self * 3600
  end
end

def early = 1.hours # written above the using line

using Durations

puts "2.hours + 30.minutes             #{2.hours + 30.minutes}"
puts "90.minutes / 60                  #{90.minutes / 60}"
puts "[1, 2].map(&:hours)              #{[1, 2].map(&:hours).inspect}"
puts "3.respond_to?(:hours)            #{3.respond_to?(:hours)}"
puts "Integer.method_defined?(:hours)  #{Integer.method_defined?(:hours)}"
begin
  early
rescue NoMethodError => e
  puts "early  (written above using)     #{e.class}"
end
