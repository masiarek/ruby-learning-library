# Exercise 1: a Version with a to_s for people and an inspect for programmers.
# Print it every way a value gets printed, and show that p hands it back.

class Version
  include Comparable
  attr_reader :parts

  def initialize(text) = @parts = text.split(".").map(&:to_i)
  def <=>(other) = parts <=> other.parts
  def to_s = parts.join(".")
  def inspect = "#<Version #{self}>"
end

v = Version.new("1.2.3")

print "puts v          -> "
puts v
print "p v             -> "
p v
puts "\"\#{v}\"          -> #{v}"
puts "[v].to_s        -> #{[v]}"
puts "format %s / %p  -> #{format('%s / %p', v, v)}"
puts "p returns it    -> #{p(v).to_s}"
puts "sorted          -> #{[Version.new('1.10.0'), v, Version.new('1.2.10')].sort.inspect}"
