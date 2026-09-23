# Set in Ruby 4.0: a core class (no require, written in C) that keeps insertion
# order and identifies an element by hash and eql?. The Python twin
# (set_is_a_core_class_py.py) prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-64s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

class Plain
  def initialize(v) = @v = v
end

class ByValue
  attr_reader :v
  def initialize(v) = @v = v
  def eql?(other) = other.is_a?(ByValue) && v == other.v
  def hash = v.hash
end

class EqOnly
  attr_reader :v
  def initialize(v) = @v = v
  def ==(other) = other.is_a?(EqOnly) && v == other.v
end

row 1,  'defined?(Set), require "set"  (core: nothing to load)',   [defined?(Set), require("set")].inspect
row 2,  "Set.instance_method(:add).source_location  (C, no file)", Set.instance_method(:add).source_location.inspect
row 3,  "Set[3, 1, 2], [3, 1].to_set, Set.new(1..3)",               [Set[3, 1, 2], [3, 1].to_set, Set.new(1..3)].inspect

s = Set[3, 1, 2]
before = s.to_a
s.delete(1)
s.add(1)
row 4,  "Set[3, 1, 2].to_a; after delete(1) then add(1)",           [before, s.to_a].inspect

s = Set[1, 2]
row 5,  "s = Set[1, 2]; s << 3 (returns s); s.add?(3); s.add?(4)",  [s << 3, s.add?(3), s.add?(4)].inspect
row 6,  "Set[1, 2] | Set[2, 3], &, -, ^",                            [Set[1, 2] | Set[2, 3], Set[1, 2] & Set[2, 3], Set[1, 2] - Set[2, 3], Set[1, 2] ^ Set[2, 3]].inspect
row 7,  "Set[1] <= Set[1, 2], subset?, <, Set[1].disjoint?(Set[2])", [Set[1] <= Set[1, 2], Set[1].subset?(Set[1, 2]), Set[1] < Set[1, 2], Set[1].disjoint?(Set[2])].inspect
row 8,  "Set[1, 2] == Set[2, 1], Set[Set[1]].include?(Set[1])",      [Set[1, 2] == Set[2, 1], Set[Set[1]].include?(Set[1])].inspect
verdict = case 2 when Set[1, 2] then "in" else "out" end
row 9,  "Set[1, 2] === 2; case 2 when Set[1, 2]",                    [Set[1, 2] === 2, verdict].inspect
row 10, "map, select, sort, | : the class each returns; select's owner", [s.map { it }.class, s.select { true }.class, s.sort.class, (s | s).class, Set.instance_method(:select).owner].inspect
row 11, "s.delete(9) (returns s, no error), s.delete?(9)",           [s.delete(9), s.delete?(9)].inspect
row 12, "Set[1].freeze << 2",                                        raises(FrozenError) { Set[1].freeze << 2 }
row 13, "Set[x, x'].size for Plain, ByValue (eql?+hash), EqOnly (==)", [Set[Plain.new(1), Plain.new(1)].size, Set[ByValue.new(1), ByValue.new(1)].size, Set[EqOnly.new(1), EqOnly.new(1)].size].inspect
row 14, "Set[[1, 2]].include?([1, 2]), Set[1, 1.0, true].size",      [Set[[1, 2]].include?([1, 2]), Set[1, 1.0, true].size].inspect

arr = [1]
ms = Set[arr]
arr << 2
found_before = ms.include?([1, 2])
ms.reset
row 15, "arr << 2 after Set[arr]: include?([1, 2]), then after reset", [found_before, ms.include?([1, 2])].inspect
row 16, "defined?(SortedSet)  (removed in 3.0; a gem now)",          defined?(SortedSet).inspect
row 17, 'Set.new("hello".chars).to_a, Set[3, 1, 2].first(2)',        [Set.new("hello".chars).to_a, Set[3, 1, 2].first(2)].inspect
row 18, "Set[1, 2] <=> Set[1, 2, 3], Set[1] <=> Set[2]",             [Set[1, 2] <=> Set[1, 2, 3], Set[1] <=> Set[2]].inspect
