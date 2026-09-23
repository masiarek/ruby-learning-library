# A default argument is an expression evaluated each time the method is
# called without that argument: a `[]` default is a fresh array on every
# call, a default may use an earlier parameter, and it may even count calls.

def add_item(item, list = [])
  list << item
end

def add_item_sentinel(item, list = nil)
  list ||= []
  list << item
end

def rect(w, h = w * 2) = [w, h]
def chain(a, b = a + 1, c = b + 1) = [a, b, c]
def later(a = b, b = 1) = [a, b]

$calls = 0
def tick(n = ($calls += 1)) = n

def side(a = (print "(default evaluated now) "; 1)) = a

puts "1. def add_item(item, list = [])"
puts "   add_item(:a), add_item(:b), add_item(:c) -> #{add_item(:a).inspect}, #{add_item(:b).inspect}, #{add_item(:c).inspect}"
puts "2. where the default lives:       method(:add_item).parameters -> #{method(:add_item).parameters.inspect}"
puts "                                  (an expression in the method body, not a stored object)"
puts "3. the nil-sentinel idiom:        add_item_sentinel(:a), (:b)  -> #{add_item_sentinel(:a).inspect}, #{add_item_sentinel(:b).inspect} (works, unnecessary)"
puts "4. a default may use an earlier parameter:"
puts "   rect(3), rect(3, 4)            -> #{rect(3).inspect}, #{rect(3, 4).inspect}"
puts "   chain(1), chain(1, 5)          -> #{chain(1).inspect}, #{chain(1, 5).inspect}"
begin
  later
rescue NameError => e
  puts "5. but not a later one:           later (a = b, b = 1)   -> #{e.class} at call time: #{e.message}"
end
puts "6. a default that counts calls:   tick, tick, tick       -> #{tick}, #{tick}, #{tick}"
puts "   tick(10), tick                 -> #{tick(10)}, #{tick} (an explicit argument skips the default)"
print "7. when the default runs:         side     -> "
puts "then #{side}"
print "                                  side(2)  -> "
puts "then #{side(2)}"
print "                                  side     -> "
puts "then #{side}"
