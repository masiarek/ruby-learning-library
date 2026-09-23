# Kata: a class with each and `include Enumerable` is a collection as far as
# every Enumerable method is concerned, without being an Array.

class Fibs
  include Enumerable

  def initialize(count) = @count = count

  def each
    return to_enum(:each) unless block_given?

    a, b = 0, 1
    @count.times do
      yield a
      a, b = b, a + b
    end
  end
end

fibs = Fibs.new(10)
puts "   to_a                 #{fibs.to_a.inspect}"
puts "   select(&:even?)      #{fibs.select(&:even?).inspect}"
puts "   each_slice(4).to_a   #{fibs.each_slice(4).to_a.inspect}"
puts "   include?(8)          #{fibs.include?(8)}"
puts "   first(3)             #{fibs.first(3).inspect}"
puts "   max                  #{fibs.max}"
puts "   respond_to?(:lazy)   #{fibs.respond_to?(:lazy)}"
puts "   is_a?(Array)         #{fibs.is_a?(Array)}"
puts "   Enumerable === fibs  #{Enumerable === fibs}"
