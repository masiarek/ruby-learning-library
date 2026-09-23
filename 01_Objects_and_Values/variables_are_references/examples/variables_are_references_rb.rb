# A variable is a reference to an object, not a box holding it. Mutating the
# object (<<, upcase!) is seen through every name; rebinding a name (=, +=) is
# seen through none. The Python twin (variables_are_references_py.py) prints
# the same rows.

def row(label, shown)
  puts "   #{label.ljust(48)} #{shown}"
end

puts "1. two names, one object"
a = [1]
b = a
b << 2
row "a = [1]; b = a; b << 2; a", a.inspect
row "b", b.inspect
row "a.equal?(b)", a.equal?(b).inspect

puts "2. + makes a new object; = rebinds the name"
b = b + [3]
row "b = b + [3]; a", a.inspect
row "b", b.inspect
row "a.equal?(b)", a.equal?(b).inspect

puts "3. += is always a rebinding in Ruby"
b = a
b += [4]
row "b = a; b += [4]; a", a.inspect
row "b", b.inspect
row "a.equal?(b)", a.equal?(b).inspect

puts "4. the same with a string"
s = "x"
t = s
t << "y"
row "s = \"x\"; t = s; t << \"y\"; s", s.inspect
t += "z"
row "t += \"z\"; s", s.inspect
row "t", t.inspect
row "s.equal?(t)", s.equal?(t).inspect

puts "5. a method receives the reference"
def push_four(list)
  list << 4
end

def reassign(list)
  list = [9]
  list
end

def shout(text)
  text.upcase!
end

orig = [1]
push_four(orig)
row "push_four(orig); orig", orig.inspect
returned = reassign(orig)
row "reassign(orig) returns", returned.inspect
row "orig after reassign", orig.inspect
word = "hi"
shout(word)
row "shout(word); word  (upcase! in place)", word.inspect

puts "6. dup breaks the sharing, one level deep"
base = [1, 2]
c = base.dup
row "base = [1, 2]; c = base.dup; c.equal?(base)", c.equal?(base).inspect
c << 9
row "c << 9; base", base.inspect
row "c", c.inspect
nested = [[1]]
shallow = nested.dup
shallow[0] << 2
row "nested = [[1]]; nested.dup[0] << 2; nested", nested.inspect
deep = Marshal.load(Marshal.dump(nested))
deep[0] << 3
row "Marshal round trip, then [0] << 3; nested", nested.inspect

puts "7. the shared-default trap"
shared = Array.new(3, "x")
shared[0] << "!"
row "Array.new(3, \"x\"), then [0] << \"!\"", shared.inspect
fresh = Array.new(3) { "x" }
fresh[0] << "!"
row "Array.new(3) { \"x\" }, then [0] << \"!\"", fresh.inspect
