# Enumerable is a mixin: a class that defines `each` and includes Enumerable
# gets the whole toolbox. Every row is numbered so the Python twin
# (enumerable_is_a_mixin_py.py) can print the same row beside it.

def row(n, label, value) = puts(format("%2d. %-52s %s", n, label, value.inspect))

class Bare                      # knows how to walk its items, and nothing else
  def each
    yield "Emma"
    yield "Dracula"
  end
end

class Shelf                     # the same `each`, plus one line
  include Enumerable

  def initialize(*titles) = @titles = titles

  def each
    return to_enum(:each) unless block_given?   # no block: hand back an Enumerator
    @titles.each { |t| yield t }
    self
  end
end

shelf = Shelf.new("Emma", "Dracula", "Middlemarch", "Persuasion")   # sizes 4, 7, 11, 10: no ties

puts "A class with only `each`, before and after `include Enumerable`"
bare = Bare.new
row 1, "Bare.new.respond_to?(:map)  (each, no include)", bare.respond_to?(:map)
begin
  bare.map { |t| t }
rescue NoMethodError => e
  row 2, "Bare.new.map { } raises", e.class
end
row 3, "Shelf.ancestors.take(3)", Shelf.ancestors.take(3)
row 4, "shelf.respond_to?(:map)", shelf.respond_to?(:map)

puts
puts "What one `each` bought (a handful of the toolbox)"
row 5, "map(&:upcase)", shelf.map(&:upcase)
row 6, "select { |t| t.size > 6 }", shelf.select { |t| t.size > 6 }
row 7, "sort_by(&:size)", shelf.sort_by(&:size)
row 8, "min_by(&:size)", shelf.min_by(&:size)
row 9, "include?(\"Emma\")", shelf.include?("Emma")
row 10, "first, first(2)", [shelf.first, shelf.first(2)]
row 11, "each_slice(3).to_a", shelf.each_slice(3).to_a
row 12, "to_a", shelf.to_a
row 13, "each_with_index.to_a", shelf.each_with_index.to_a
row 14, "sum(\"\")", shelf.sum("")
row 15, "lazy.class", shelf.lazy.class
row 16, "lazy.map(&:downcase).first(2)", shelf.lazy.map(&:downcase).first(2)
row 17, "each.class, each.next  (no block given)", [shelf.each.class, shelf.each.next]

puts
puts "Core classes that include Enumerable, and two that do not"
[Array, Hash, Range, Struct, Dir, Set, Enumerator, String, Integer].each_with_index do |klass, i|
  row 18 + i, "#{klass}.include?(Enumerable)", klass.include?(Enumerable)
end

puts
puts "The mixin, seen from the module's side"
row 27, "Enumerable.instance_methods.include?(:each)", Enumerable.instance_methods.include?(:each)
row 28, "...include?(:tally), ...size > 50", [Enumerable.instance_methods.include?(:tally), Enumerable.instance_methods.size > 50]
row 29, "Array.instance_method(:map).owner, (:inject).owner", [Array.instance_method(:map).owner, Array.instance_method(:inject).owner]
row 30, "Comparable.instance_methods.sort  (the other mixin)", Comparable.instance_methods.sort
row 31, "Shelf.include?(Comparable)  (mixins are opt-in)", Shelf.include?(Comparable)
