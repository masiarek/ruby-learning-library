# Kata: a Version that sorts numerically -- "1.10" after "1.9" -- from one <=>
# and Comparable; then the newest of a list, and a clamp into a supported range.

class Version
  include Comparable
  attr_reader :parts

  def initialize(text) = @parts = text.split(".").map { Integer(it) }
  def <=>(other) = other.is_a?(Version) ? parts <=> other.parts : nil
  def to_s = parts.join(".")
  def inspect = "v#{self}"
end

strings = %w[1.10 1.9 1.2.1 2.0 1.2]
puts "sorted as strings:  #{strings.sort.inspect}"
versions = strings.map { Version.new(it) }
puts "sorted as versions: #{versions.sort.inspect}"
puts "newest: #{versions.max}, oldest: #{versions.min}"

lo, hi = Version.new("1.5"), Version.new("1.10")
versions.sort.each do |v|
  puts "  #{v.to_s.ljust(5)} between? #{v.between?(lo, hi).to_s.ljust(5)} clamp(#{lo}, #{hi}) -> #{v.clamp(lo, hi)}"
end

puts "v1.10 == v1.10.0? #{Version.new('1.10') == Version.new('1.10.0')}  ([1, 10] <=> [1, 10, 0] is #{[1, 10] <=> [1, 10, 0]})"
