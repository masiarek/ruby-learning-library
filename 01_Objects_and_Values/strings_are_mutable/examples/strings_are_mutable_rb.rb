# A Ruby String is a mutable object: << and the bang methods change it in
# place and keep its identity, while + and the non-bang methods return a new
# string. The Python twin (strings_are_mutable_py.py) prints the same rows
# for an immutable str and the mutable routes Python offers instead.

def row(label, shown)
  puts "   #{label.ljust(48)} #{shown}"
end

puts "1. << mutates in place; += makes a new string"
s = "abc".dup
before = s
s << "d"
row "s = \"abc\".dup; before = s; s << \"d\"; s", s.inspect
row "s.equal?(before)", s.equal?(before).inspect
s += "e"
row "s += \"e\"; s", s.inspect
row "s.equal?(before)", s.equal?(before).inspect
row "before", before.inspect

puts "2. bang methods change the receiver; the others return a copy"
u = "abc".dup
r = u.upcase!
row "u = \"abc\".dup; u.upcase!; u", u.inspect
row "u.upcase! returned u itself", r.equal?(u).inspect
row "\"ABC\".dup.upcase!  (nothing to change)", "ABC".dup.upcase!.inspect
v = "abc"
w = v.upcase
row "v = \"abc\"; w = v.upcase; v", v.inspect
row "w.equal?(v)", w.equal?(v).inspect

puts "3. editing in place"
t = "abc".dup
t[0] = "X"
row "t = \"abc\".dup; t[0] = \"X\"; t", t.inspect
t.insert(1, "-")
row "t.insert(1, \"-\")", t.inspect
t.sub!("b", "B")
row "t.sub!(\"b\", \"B\")", t.inspect
t.replace("new")
row "t.replace(\"new\")", t.inspect
t.clear
row "t.clear", t.inspect

puts "4. a literal is chilled, not frozen"
row "\"a\".frozen?", "a".frozen?.inspect
lit = "lit"
lit << "!"
row "lit = \"lit\"; lit << \"!\"; lit", lit.inspect
row "(+\"a\").frozen?  (a mutable copy on demand)", (+"a").frozen?.inspect
row "(-\"a\").frozen?  (the deduplicated one)", (-"a").frozen?.inspect
row "String.new(\"a\").frozen?", String.new("a").frozen?.inspect

puts "5. building a string"
buf = +""
buf << "a" << "b"
row "buf = +\"\"; buf << \"a\" << \"b\"", buf.inspect
xs = "x".dup
5.times { xs << "x" }
row "xs = \"x\".dup; 5.times { xs << \"x\" }", xs.inspect
row "%w[a b c].join", %w[a b c].join.inspect
chars = "abc".chars
chars[0] = "X"
row "chars = \"abc\".chars; chars[0] = \"X\"; join", chars.join.inspect

puts "6. what mutability costs: a Hash copies and freezes a String key"
key = "key".dup
h = { key => 1 }
row "key = \"key\".dup; h = { key => 1 }", h.inspect
row "h.keys.first.frozen?", h.keys.first.frozen?.inspect
row "h.keys.first.equal?(key)", h.keys.first.equal?(key).inspect
key << "!"
row "key << \"!\"; h[\"key\"]  (the copy is untouched)", h["key"].inspect
