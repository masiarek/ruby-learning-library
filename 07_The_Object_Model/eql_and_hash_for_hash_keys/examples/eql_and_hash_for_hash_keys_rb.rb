# A Hash finds a key by hash first and eql? second; == plays no part. The
# Python twin, eql_and_hash_for_hash_keys_py.py, prints the same rows.

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-42s %s", label, value))

class Pt
  attr_accessor :x, :y
  def initialize(x, y) = (@x, @y = x, y)
  def ==(other) = other.is_a?(Pt) && x == other.x && y == other.y
  def inspect = "Pt(#{x},#{y})"
end

S = Struct.new(:x, :y)
D = Data.define(:x, :y)

section 1, "== alone: two equal points are two keys"
row "Pt.new(1, 2) == Pt.new(1, 2)", Pt.new(1, 2) == Pt.new(1, 2)
row "Pt.new(1, 2).eql?(Pt.new(1, 2))", Pt.new(1, 2).eql?(Pt.new(1, 2))
row "Pt.new(1, 2).hash == Pt.new(1, 2).hash", Pt.new(1, 2).hash == Pt.new(1, 2).hash
h = { Pt.new(1, 2) => :a, Pt.new(1, 2) => :b }
row "{ Pt(1,2) => :a, Pt(1,2) => :b }.size", h.size
row "h[Pt.new(1, 2)]", h[Pt.new(1, 2)].inspect

section 2, "what == alone still does, and what it does not"
pair = [Pt.new(1, 2), Pt.new(1, 2)]
row "[Pt(1,2)].include?(Pt(1,2))  (uses ==)", pair.first(1).include?(Pt.new(1, 2))
row "[Pt(1,2), Pt(1,2)].uniq.size", pair.uniq.size
row "([Pt(1,2)] - [Pt(1,2)]).size", (pair.first(1) - pair.last(1)).size
row "Set[Pt(1,2), Pt(1,2)].size", Set[*pair].size
row "[Pt(1,2), Pt(1,2)].tally.size", pair.tally.size
row "[Pt(1,2), Pt(1,2)].group_by(&:itself).size", pair.group_by(&:itself).size

section 3, "eql? and hash together fix it"
class Pt
  alias eql? ==
  def hash = [x, y].hash
end
row "Pt.new(1, 2).eql?(Pt.new(1, 2))", Pt.new(1, 2).eql?(Pt.new(1, 2))
row "Pt.new(1, 2).hash == Pt.new(1, 2).hash", Pt.new(1, 2).hash == Pt.new(1, 2).hash
h = { Pt.new(1, 2) => :a, Pt.new(1, 2) => :b }
row "{ Pt(1,2) => :a, Pt(1,2) => :b }.size", h.size
row "h[Pt.new(1, 2)]", h[Pt.new(1, 2)].inspect
row "[Pt(1,2), Pt(1,2)].uniq.size", pair.uniq.size
row "Set[Pt(1,2), Pt(1,2)].size", Set[*pair].size
row "[Pt(1,2), Pt(1,2)].tally", pair.tally.inspect

section 4, "Struct and Data get both for free"
row "S.new(1, 2).eql?(S.new(1, 2))", S.new(1, 2).eql?(S.new(1, 2))
row "{ S(1,2) => 1, S(1,2) => 2 }.size", { S.new(1, 2) => 1, S.new(1, 2) => 2 }.size
row "{ D(1,2) => 1, D(1,2) => 2 }.size", { D.new(1, 2) => 1, D.new(1, 2) => 2 }.size
row "S.new(1, 2) == S.new(1, 2.0)", S.new(1, 2) == S.new(1, 2.0)
row "S.new(1, 2).eql?(S.new(1, 2.0))", S.new(1, 2).eql?(S.new(1, 2.0))

section 5, "an Array key works by value; a mutated key is lost until rehash"
row "{ [1, 2] => :arr }[[1, 2]]", { [1, 2] => :arr }[[1, 2]].inspect
key = [1]
h = { key => :arr }
key << 2
row "key = [1]; h = { key => :arr }; key << 2", "(the key changed after insertion)"
row "h[[1, 2]]", h[[1, 2]].inspect
row "h[key]", h[key].inspect
row "h.keys", h.keys.inspect
h.rehash
row "h.rehash; h[[1, 2]]", h[[1, 2]].inspect

section 6, "1 and 1.0 are == but not eql?"
row "1 == 1.0", 1 == 1.0
row "1.eql?(1.0)", 1.eql?(1.0)
row "1.hash == 1.0.hash", 1.hash == 1.0.hash
row "{ 1 => :int }[1.0]", { 1 => :int }[1.0].inspect
row "{ 1 => :int, 1.0 => :float }", { 1 => :int, 1.0 => :float }.inspect
row "[1, 1.0].uniq.size", [1, 1.0].uniq.size
row "Set[1, 1.0].size", Set[1, 1.0].size

section 7, "a String key is copied and frozen"
s = +"key"
h = { s => 1 }
row "s = +\"key\"; h = { s => 1 }", "(a mutable String as the key)"
row "h.keys.first.frozen?", h.keys.first.frozen?
row "s.frozen?", s.frozen?
row "s.equal?(h.keys.first)", s.equal?(h.keys.first)
s << "!"
row "s << \"!\"; h[\"key\"]", h["key"].inspect
row "h[\"key!\"]", h["key!"].inspect

section 8, "compare_by_identity switches to equal?"
by_id = {}.compare_by_identity
by_id["a"] = 1
by_id["a"] = 2
row "two \"a\" literals as keys, by identity", by_id.size
one = "b"
by_id[one] = 3
by_id[one] = 4
row "the same String object twice", by_id.size

section 9, "the rules"
class BadHash
  def hash = "nope"
end
begin
  { BadHash.new => 1 }
rescue TypeError => e
  row "hash returning a String", "#{e.class}: #{e.message}"
end
class OnlyEql
  def eql?(_other) = true
end
class OnlyHash
  def hash = 1
end
row "eql? without hash: keys kept", { OnlyEql.new => 1, OnlyEql.new => 2 }.size
row "hash without eql?: keys kept", { OnlyHash.new => 1, OnlyHash.new => 2 }.size
row "Object.instance_method(:eql?).owner", Object.instance_method(:eql?).owner
row "Object.instance_method(:hash).owner", Object.instance_method(:hash).owner
row "Object.instance_method(:==).owner", Object.instance_method(:==).owner
