# A trailing `!` marks the more dangerous of two versions of a method --
# usually the one that changes its receiver, and several of those return nil
# when nothing changed -- and a trailing `?` marks a predicate. Row 7 starts
# two child Rubies to show `exit!` skipping the at_exit handlers.
require "open3"

def child(source)
  out, _err, status = Open3.capture3(RbConfig.ruby, "-e", source)
  "stdout #{out.inspect}, status #{status.exitstatus}"
end

a = [3, 1, 2]
sorted = a.sort
puts "1. sort returns a new array:      a.sort                -> #{sorted.inspect}, a is still #{a.inspect}"
r = a.sort!
puts "2. sort! changes the receiver:    a.sort!               -> #{r.inspect}, a is now #{a.inspect}, r.equal?(a) is #{r.equal?(a)}"
puts "3. nil when nothing changed:      [1, 2].uniq!          -> #{[1, 2].uniq!.inspect}"
puts "                                  \"x\".strip!            -> #{"x".strip!.inspect}"
puts "                                  \"abc\".sub!(\"z\", \"y\")  -> #{"abc".sub!("z", "y").inspect}"
puts "                                  \"ABC\".upcase!         -> #{"ABC".upcase!.inspect}"
puts "                                  [1, 2].flatten!       -> #{[1, 2].flatten!.inspect}"
puts "                                  [1, 2].compact!       -> #{[1, 2].compact!.inspect}"
puts "   the new value when it did:     [1, 1].uniq!          -> #{[1, 1].uniq!.inspect}"
puts "                                  \" x \".strip!          -> #{" x ".strip!.inspect}"
begin
  "abc".strip!.upcase
rescue NoMethodError => e
  puts "4. so chaining a bang breaks:     \"abc\".strip!.upcase   -> #{e.class}: #{e.message}"
end
puts "   chain the non-bang versions:   \" abc \".strip.upcase  -> #{" abc ".strip.upcase.inspect}"
puts "5. ? methods answer a question:   [].empty? #{[].empty?}, 0.zero? #{0.zero?}, [1, 2].include?(2) #{[1, 2].include?(2)}, \"a\".frozen? #{"a".frozen?}, 1.even? #{1.even?}, nil.nil? #{nil.nil?}"
def ready? = true
def go! = "went"
puts "6. ? and ! are part of the name:  def ready? -> #{method(:ready?).name.inspect}, def go! -> #{method(:go!).name.inspect}, \"abc\".respond_to?(:strip!) #{"abc".respond_to?(:strip!)}"
puts "7. ! is not always mutation:      exit  -> #{child('at_exit { puts "at_exit ran" }; puts "exiting"; exit')}"
puts "                                  exit! -> #{child('at_exit { puts "at_exit ran" }; puts "exiting"; $stdout.flush; exit!')}"
b = [1, 2]
b << 3
b.push(4)
popped = b.pop
puts "8. mutation without a bang:       b << 3; b.push(4); b.pop -> #{popped}, b is #{b.inspect}"
puts "                                  (the bang marks the dangerous one of a pair; a method with no twin has no bang)"
