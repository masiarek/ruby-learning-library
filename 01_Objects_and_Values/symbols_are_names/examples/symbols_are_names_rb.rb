# A symbol is a name: one frozen object per spelling, used for method names,
# hash keys and &:sym blocks. The Python twin (symbols_are_names_py.py) prints
# the same numbered rows with the closest thing Python has for each.

def row(label, shown)
  puts "   #{label.ljust(44)} #{shown}"
end

puts "1. one object per name"
row ":a.equal?(:a)", :a.equal?(:a).inspect
row "\"a\".equal?(\"a\")", "a".equal?("a").inspect
row "\"a\".to_sym.equal?(:a)", "a".to_sym.equal?(:a).inspect
row "(\"dyn\" + \"amic\").to_sym.equal?(:dynamic)", ("dyn" + "amic").to_sym.equal?(:dynamic).inspect

puts "2. a symbol is not a string"
row ":a == \"a\"", (:a == "a").inspect
row ":a.class", :a.class.inspect
row ":a.to_s", :a.to_s.inspect
row "\"a\".to_sym", "a".to_sym.inspect
row "[:a, \"a\"].uniq", [:a, "a"].uniq.inspect

puts "3. symbols are frozen"
row ":a.frozen?", :a.frozen?.inspect
row ":a.name.frozen?  (one shared String)", :a.name.frozen?.inspect
row ":a.to_s.frozen?  (a fresh String)", :a.to_s.frozen?.inspect
begin
  :a.name << "b"
rescue FrozenError => e
  row ":a.name << \"b\"", e.class.to_s
end

puts "4. literal forms and hash keys"
row "%i[a b]", %i[a b].inspect
row ":\"hello world\"", :"hello world".inspect
row "{a: 1}", { a: 1 }.inspect
row "{a: 1}.keys.first.class", { a: 1 }.keys.first.class.inspect
row "{\"a\" => 1}.keys.first.class", { "a" => 1 }.keys.first.class.inspect
row "{a: 1}[\"a\"]", { a: 1 }["a"].inspect
h = {}
h[:k] = 1
h["k"] = 2
row "h[:k] = 1; h[\"k\"] = 2; h", h.inspect
row "h.size", h.size.inspect

puts "5. method names are symbols"
row "\"x\".send(:upcase)", "x".send(:upcase).inspect
row "def greet; end", (def greet; end).inspect
row "\"x\".method(:upcase).name", "x".method(:upcase).name.inspect
row "\"x\".methods.include?(:upcase)", "x".methods.include?(:upcase).inspect

puts "6. to_proc makes &:sym work"
row ":upcase.to_proc.call(\"x\")", :upcase.to_proc.call("x").inspect
row "%w[a b].map(&:upcase)", %w[a b].map(&:upcase).inspect
row "[1, 2].inject(:+)", [1, 2].inject(:+).inspect
