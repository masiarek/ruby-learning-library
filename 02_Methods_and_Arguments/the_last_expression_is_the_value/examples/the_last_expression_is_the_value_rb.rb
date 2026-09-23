# A method's value is the value of the last expression it evaluated. `return`
# leaves early; `def` is itself an expression whose value is the method's
# name; an `if` with no branch taken is nil; and `puts` returns nil, so a
# method that ends in `puts` returns nil.

def add(a, b)
  a + b
end

def early(n)
  return "early" if n < 0
  "late"
end

def negative_or_nothing(n)
  "negative" if n < 0
end

def ends_with_puts
  puts "   (printing from inside)"
end

def pair
  return 1, 2
end

def assigns
  y = 5
end

def empty_body
end

def ensured
  "the body"
ensure
  "the ensure clause"
end

puts "1. implicit return:           add(1, 2)               -> #{add(1, 2).inspect}"
puts "2. early return:              early(-1), early(1)     -> #{early(-1).inspect}, #{early(1).inspect}"
puts "3. if with no branch taken:   negative_or_nothing(5)  -> #{negative_or_nothing(5).inspect}"
r = def named; end
puts "4. def is an expression:      r = def named; end      -> #{r.inspect} (a #{r.class})"
puts "   so private can take a def:  private def helper; end -> private received #{(private def helper; end).inspect}"
puts "5. a method ending in puts:   ends_with_puts          -> prints:"
v = ends_with_puts
puts "   then returns #{v.inspect}"
print "6. puts itself:               v = (puts \"hi\")         -> prints "
v = (puts "hi")
puts "   and v is #{v.inspect}"
puts "7. return with two values:    pair                    -> #{pair.inspect} (an #{pair.class})"
puts "8. assignment as last line:   assigns                 -> #{assigns.inspect}"
puts "9. an empty body:             empty_body              -> #{empty_body.inspect}"
puts "10. ensure does not replace:  ensured                 -> #{ensured.inspect}"
