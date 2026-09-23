# Exercise 1: Ring yields an array's elements starting at an offset and
# wrapping around; one each, Enumerable included, an Enumerator with the
# right size when no block is given.

class Ring
  include Enumerable

  def initialize(items, offset = 0)
    @items = items
    @offset = offset
  end

  def each
    return to_enum(:each) { @items.size } unless block_given?
    @items.size.times { |i| yield @items[(i + @offset) % @items.size] }
    self
  end
end

ring = Ring.new([1, 2, 3, 4], 1)
puts "to_a            #{ring.to_a}"
puts "map             #{ring.map { _1 * 10 }}"
puts "each_slice(2)   #{ring.each_slice(2).to_a}"
puts "each.size       #{ring.each.size}"
puts "each.next       #{ring.each.next}"
puts "lazy.select     #{ring.lazy.select(&:even?).first(1)}"
puts "each_with_index #{ring.each_with_index.map { |v, i| "#{i}:#{v}" }.join(' ')}"
