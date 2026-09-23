# Kata: define `shout word` without parentheses, then shadow it with a local
# variable and show which spelling still reaches the method.
def shout word
  word.upcase + "!"
end

puts "1. shout \"hi\"             -> #{(shout "hi").inspect}"
puts "2. shout(\"hi\")            -> #{shout("hi").inspect}"
print "3. puts shout \"hi\"        -> prints "
puts shout "hi"
shout = "quiet"
puts "4. shout = \"quiet\"; shout  -> #{shout.inspect}  (the local wins)"
puts "5. shout(\"hi\")            -> #{shout("hi").inspect}  (parentheses reach the method)"
puts "6. shout \"hi\"             -> #{(shout "hi").inspect}  (a bare name with an argument is a call)"
puts "7. self.shout(\"hi\")       -> #{self.shout("hi").inspect}  (a receiver reaches the method)"
