# Exercise 1: a case-insensitive Word as a Hash key. eql? and hash agree on
# the downcased text, so Hash.new(0) counts "Ruby", "ruby" and "RUBY" as one.

class Word
  attr_reader :text

  def initialize(text) = @text = text
  def ==(other) = other.is_a?(Word) && text.casecmp?(other.text)
  alias eql? ==
  def hash = text.downcase.hash
  def inspect = "Word(#{text})"
end

counts = Hash.new(0)
%w[Ruby ruby RUBY python Python].each { |w| counts[Word.new(w)] += 1 }

puts "counts                     #{counts.inspect}"
puts "counts[Word.new(\"rUbY\")]   #{counts[Word.new('rUbY')]}"
puts "the key kept the first spelling seen:"
puts "counts.keys.map(&:text)    #{counts.keys.map(&:text).inspect}"
puts "Word(\"a\").eql?(Word(\"A\"))  #{Word.new('a').eql?(Word.new('A'))}"
puts "same hash?                 #{Word.new('a').hash == Word.new('A').hash}"
puts "as a Set                   #{Set[Word.new('Go'), Word.new('go'), Word.new('GO')].inspect}"
