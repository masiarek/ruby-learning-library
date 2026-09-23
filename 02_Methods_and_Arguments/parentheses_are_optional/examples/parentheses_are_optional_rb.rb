# Parentheses are optional on a call and on a def. A bare name is a method
# call unless a local variable of that name has been assigned earlier, and
# the space before a `(` decides whether the parentheses belong to the call
# or to the expression. Rows 9, 11 and 14 start a child Ruby with -w to show
# which of these spellings the parser warns about.
require "open3"

def greeting = "the method"

def f a, b
  a + b
end

def rest *args
  args
end

def child(source)
  out, err, = Open3.capture3(RbConfig.ruby, "-w", "-e", source)
  [out.chomp, err.chomp]
end

print "1. a call without parentheses:    puts \"x\"        -> prints "
puts "x"
puts "2. a def without parentheses:     def f a, b       -> f 1, 2 = #{f 1, 2}"
puts "3. a bare name, no local exists:  greeting         -> #{greeting.inspect}"
greeting = "the local"
puts "4. after greeting = \"the local\": greeting       -> #{greeting.inspect}"
puts "5. parentheses force the method:  greeting()       -> #{greeting().inspect}"
puts "6. a receiver forces it too:      self.greeting    -> #{self.greeting.inspect}"

print "7. one space before the paren:    puts (1+2)*3     -> prints "
puts (1+2)*3
print "8. no space before the paren:     puts(1+2)*3      -> prints "
begin
  puts(1+2)*3
rescue NoMethodError => e
  puts "   then #{e.class}: #{e.message}"
end
out, err = child("puts (1+2)*3")
puts "9. ruby -w on row 7:              stdout #{out.inspect}, stderr #{err.inspect} (no warning in 4.0)"

print "10. minus, one space:             p -1             -> prints "
p -1
out, err = child("p -1")
puts "11. ruby -w on row 10:            #{err}"
begin
  p - 1
rescue NoMethodError => e
  puts "12. minus, two spaces:            p - 1            -> #{e.class}: #{e.message}"
end

print "13. star, one space:              rest *[1, 2]     -> "
p rest *[1, 2]
out, err = child("def rest(*a) = a; p rest *[1, 2]")
puts "14. ruby -w on row 13:            #{err}"
