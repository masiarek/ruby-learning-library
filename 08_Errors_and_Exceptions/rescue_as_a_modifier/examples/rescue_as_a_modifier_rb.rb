# rescue_as_a_modifier_rb.rb -- `expr rescue fallback`: what it catches, how it binds,
# where it is a syntax error, the rescue clause inside do/end versus {} blocks,
# Integer() versus to_i, and the bug the modifier hides.

def compiles?(source)
  RubyVM::InstructionSequence.compile(source)
  "compiles"
rescue SyntaxError
  "SyntaxError"
end

puts "1. expr rescue fallback"
x = Integer("abc") rescue 0
puts "   Integer(\"abc\") rescue 0  -> #{x.inspect}"
y = Integer("42") rescue 0
puts "   Integer(\"42\") rescue 0   -> #{y.inspect}"

puts "2. it catches StandardError only"
begin
  z = (raise NotImplementedError, "abstract") rescue 0
  puts "   never printed #{z}"
rescue NotImplementedError => e
  puts "   (raise NotImplementedError) rescue 0 -> propagated #{e.class}"
end

puts "3. how it binds"
value = raise("boom") rescue "fallback"
puts "   value = raise(\"boom\") rescue \"fallback\"  -> value is #{value.inspect}"
puts "   as a bare argument, p(expr rescue 0):   #{compiles?('p(Integer("x") rescue 0)')}"
puts "   with its own parentheses, p((expr rescue 0)): #{compiles?('p((Integer("x") rescue 0))')}"

puts "4. a rescue clause in a def needs no begin"
def parse(text)
  Integer(text)
rescue ArgumentError
  "method-level rescue"
end
puts "   parse(\"q\") -> #{parse("q").inspect}"

puts "5. a rescue clause inside do...end works; inside { } it is a syntax error"
puts "   do |x| ... rescue => e ... end   #{compiles?("[1].each do |x|\n raise 'a'\nrescue => e\n puts e\nend")}"
puts "   { |x| ... rescue => e ... }      #{compiles?("[1].each { |x|\n raise 'a'\nrescue => e\n puts e\n}")}"
[1].each do |n|
  raise "inside a do block (#{n})"
rescue => e
  puts "   rescued inside do...end: #{e.message.inspect}"
end

puts "6. the modifier form is fine inside { }"
[1].each { |n| v = (raise "in braces") rescue "modifier inside braces (#{n})"; puts "   #{v}" }

puts "7. Integer() raises where to_i does not"
puts "   \"abc\".to_i                    -> #{"abc".to_i.inspect}"
puts "   \"12abc\".to_i                  -> #{"12abc".to_i.inspect}"
begin
  Integer("abc")
rescue ArgumentError => e
  puts "   Integer(\"abc\")                -> #{e.class}: #{e.message}"
end
puts "   Integer(\"abc\", exception: false) -> #{Integer("abc", exception: false).inspect}"

puts "8. the trap: the modifier hides every StandardError, including a typo"
name = nil.upcse rescue "default"
puts "   nil.upcse rescue \"default\" -> #{name.inspect} (the NoMethodError from the typo is gone)"
