# dup and clone both copy the instance variables, shallowly. clone also
# copies the frozen state and the singleton class; dup starts fresh.
# Marshal is the deep copy. The Python twin, dup_clone_and_frozen_state_py.py,
# prints the same numbered rows.

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-46s %s", label, value))

class Doc
  attr_accessor :title, :tags
  def initialize(title, tags) = (@title, @tags = title, tags)
  def inspect = "#<Doc #{@title.inspect} #{@tags.inspect}>"
end

class Tracked
  attr_reader :log, :items

  def initialize = (@log, @items = [], [])

  def initialize_copy(source)
    @log << :initialize_copy
    super
    @items = @items.dup
  end

  def initialize_dup(source)
    @log << :initialize_dup
    super
  end

  def initialize_clone(source, freeze: nil)
    @log << [:initialize_clone, freeze]
    super
  end
end

D = Data.define(:a)

original = Doc.new("draft", ["a"])
def original.shout = "singleton!"
original.freeze

section 1, "both copy the instance variables"
row "original", original.inspect
row "original.dup", original.dup.inspect
row "original.clone", original.clone.inspect
row "original.dup.equal?(original)", original.dup.equal?(original)

section 2, "frozen state: dup drops it, clone keeps it"
row "original.frozen?", original.frozen?
row "original.dup.frozen?", original.dup.frozen?
row "original.clone.frozen?", original.clone.frozen?
row "original.clone(freeze: false).frozen?", original.clone(freeze: false).frozen?
row "Doc.new(\"u\", []).clone(freeze: true).frozen?", Doc.new("u", []).clone(freeze: true).frozen?
begin
  original.clone.title = "x"
rescue FrozenError => e
  row "original.clone.title = \"x\"", "#{e.class}: #{e.message}"
end
fresh = original.dup
fresh.title = "copy"
row "fresh = original.dup; fresh.title = \"copy\"", fresh.inspect

section 3, "singleton methods: dup drops them, clone keeps them"
row "original.singleton_methods", original.singleton_methods.inspect
row "original.dup.singleton_methods", original.dup.singleton_methods.inspect
row "original.clone.singleton_methods", original.clone.singleton_methods.inspect

section 4, "both are shallow"
row "fresh.tags.equal?(original.tags)", fresh.tags.equal?(original.tags)
fresh.tags << "b"
row "fresh.tags << \"b\"; original.tags", original.tags.inspect
row "original.clone.tags.equal?(original.tags)", original.clone.tags.equal?(original.tags)

section 5, "Marshal round-trip is the deep copy"
plain = Doc.new("plain", ["a"]).freeze
deep = Marshal.load(Marshal.dump(plain))
row "deep = Marshal.load(Marshal.dump(plain))", deep.inspect
row "deep.tags.equal?(plain.tags)", deep.tags.equal?(plain.tags)
row "deep.frozen?  (frozen state is not dumped)", deep.frozen?
begin
  Marshal.dump(original)
rescue TypeError => e
  row "Marshal.dump(original)  (has a singleton)", "#{e.class}: #{e.message}"
end
begin
  Marshal.dump(proc {})
rescue TypeError => e
  row "Marshal.dump(proc {})", "#{e.class}: #{e.message}"
end

section 6, "the hooks: initialize_dup or initialize_clone, then initialize_copy"
row "Tracked.new.dup.log", Tracked.new.dup.log.inspect
row "Tracked.new.clone.log", Tracked.new.clone.log.inspect
row "Tracked.new.clone(freeze: false).log", Tracked.new.clone(freeze: false).log.inspect
tracked = Tracked.new
copy = tracked.dup
row "copy.items.equal?(tracked.items)  (dup'd in the hook)", copy.items.equal?(tracked.items)
row "copy.log.equal?(tracked.log)  (not dup'd: shared)", copy.log.equal?(tracked.log)

section 7, "immediates and frozen literals"
row "1.dup.equal?(1)", 1.dup.equal?(1)
row ":a.clone.equal?(:a)", :a.clone.equal?(:a)
row "nil.dup.equal?(nil)", nil.dup.equal?(nil)
row "\"x\".freeze.dup.frozen?", "x".freeze.dup.frozen?
row "frozen? of  \"lit\"  :sym  1  nil  []  (1..2)",
    ["lit", :sym, 1, nil, [], (1..2)].map(&:frozen?).join("  ")

section 8, "Data stays frozen through dup; make_shareable freezes deep"
data = D.new([1])
row "D.new([1]).frozen?", data.frozen?
row "D.new([1]).dup.frozen?", data.dup.frozen?
row "data.dup.a.equal?(data.a)  (still shallow)", data.dup.a.equal?(data.a)
nested = { list: [1] }
Ractor.make_shareable(nested)
row "Ractor.make_shareable(h); h.frozen?", nested.frozen?
row "h[:list].frozen?", nested[:list].frozen?

section 9, "where they live"
row "Object.instance_method(:dup).owner", Object.instance_method(:dup).owner
row "Object.instance_method(:clone).owner", Object.instance_method(:clone).owner
row "Object.instance_method(:freeze).owner", Object.instance_method(:freeze).owner
row "Kernel.private_instance_methods.include?(:initialize_copy)", Kernel.private_instance_methods.include?(:initialize_copy)
