# Nineteen idiom pairs, one measured line each, in the order of the page's
# table; then Ruby's aliases (more than one way), the Zen (Ruby has none),
# and a word-frequency program whose output the Python twin reproduces exactly.
require "stringio"

def row(n, label, value)
  puts format("%2d. %-40s %s", n, label, value)
end

puts "The idiom pairs"
out = +""
[1, 2, 3].each { |x| out << x.to_s }
row 1, "[1, 2, 3].each { |x| out << x.to_s }", out.inspect
row 2, "xs.select(&:even?).map { it * it }", [1, 2, 3, 4].select(&:even?).map { it * it }.inspect
row 3, "[].empty? / [1].empty?", "#{[].empty?} / #{[1].empty?}"
a = [3, 1]
row 4, "a = [3, 1]; a.sort! returns", "#{a.sort!.inspect}  (the receiver, now sorted)"
row 5, 'unless [].any? then "empty" end', (unless [].any? then "empty" end).inspect

class Person
  attr_accessor :name
end
person = Person.new
person.name = "ann"
row 6, "attr_accessor :name; person.name = \"ann\"", person.name.inspect
row 7, "nil.class / nil.inspect / nil.to_s", "#{nil.class} / #{nil.inspect} / #{nil.to_s.inspect}"

captured = StringIO.new
$stdout = captured
returned = puts("hi")
$stdout = STDOUT
row 8, "r = puts \"hi\"  (printed #{captured.string.inspect})", "r = #{returned.inspect}"
row 9, 'require "json" twice', "#{require "json"} / #{require "json"}  (loaded once)"
h = { a: 1 }
row 10, "{a: 1}[:a] / [:z] / fetch(:z, 0)", "#{h[:a]} / #{h[:z].inspect} / #{h.fetch(:z, 0)}"
row 11, ':a.equal?(:a) / "a".equal?("a")', "#{:a.equal?(:a)} / #{"a".equal?("a")}"

module Greeting
  def hello = "hello from the mixin"
end

class Host
  include Greeting
end
row 12, "include Greeting; Host.new.hello", "#{Host.new.hello.inspect}  ancestors #{Host.ancestors.first(3).inspect}"

class Version
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(other) = n <=> other.n
end
row 13, "include Comparable, <=> only: V(1) < V(2)", "#{Version.new(1) < Version.new(2)}  between? #{Version.new(2).between?(Version.new(1), Version.new(3))}"

class Bag
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each(&block) = @xs.each(&block)
end
row 14, "include Enumerable, each only: sort / map", "#{Bag.new(2, 1).sort.inspect} / #{Bag.new(2, 1).map { it * 10 }.inspect}"

class Finder
  def method_missing(name, *args)
    return "#{name.to_s.delete_prefix("find_by_")}=#{args.first}" if name.start_with?("find_by_")
    super
  end

  def respond_to_missing?(name, include_private = false) = name.start_with?("find_by_") || super
end
row 15, 'method_missing: Finder.new.find_by_name("x")', Finder.new.find_by_name("x").inspect

Point = Struct.new(:x, :y)
row 16, "Struct.new(:x, :y).new(1, 2)", Point.new(1, 2).inspect
Coord = Data.define(:x, :y)
begin
  Coord.new(x: 1, y: 2).instance_variable_set(:@x, 9)
rescue => e
  frozen = e.class
end
row 17, "Data.define(:x, :y): with(y: 5) / set @x", "#{Coord.new(x: 1, y: 2).with(y: 5).inspect} / #{frozen}"

def shape(v)
  case v
  in [x, y] then "pair #{x},#{y}"
  in { name: String => n } then "named #{n}"
  else "other"
  end
end
row 18, "case/in: shape([1, 2]) / shape({name: \"ann\"})", "#{shape([1, 2]).inspect} / #{shape({ name: "ann" }).inspect}"
row 19, "1/3r + 1/6r", (1/3r + 1/6r).inspect

puts
puts "More than one way: two names, one result"
xs = [1, 2, 3]
puts "    collect==map #{xs.collect { it * 2 } == xs.map { it * 2 }}, filter==select #{xs.filter(&:odd?) == xs.select(&:odd?)}, " \
     "reduce==inject #{xs.reduce(:+) == xs.inject(:+)}, size==length #{xs.size == xs.length}, " \
     "yield_self==then #{5.yield_self { it + 1 } == 5.then { it + 1 }}"
puts "    Method#== (one definition under two names): then/yield_self #{5.method(:then) == 5.method(:yield_self)}, " \
     "map/collect #{[].method(:map) == [].method(:collect)}  (two definitions of one behaviour)"

puts
puts "The Zen: Ruby ships no equivalent of `import this`"
begin
  require "this"
rescue LoadError => e
  puts "    require \"this\" -> #{e.class}: #{e.message}"
end

puts
puts "Word frequency, the same program in both languages"
text = "the quick brown fox jumps over the lazy dog the fox sleeps and the dog barks and barks"
text.downcase.scan(/[a-z']+/).tally
    .sort_by { |word, count| [-count, word] }
    .first(5)
    .each { |word, count| puts format("    %-8s %d", word, count) }
