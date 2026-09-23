# throw_and_catch_rb.rb -- catch/throw is a non-local jump, not an exception: the value
# comes back from catch, nested loops are escaped, rescue never sees a matched throw,
# ensure still runs, an unmatched throw IS an exception, and tags match by identity.

puts "1. catch returns the value thrown to it, or the block's value"
found = catch(:found) do
  [1, 2, 3].each { |n| throw :found, n * 10 if n == 2 }
  "block finished without a throw"
end
puts "   with a throw:    #{found.inspect}"
puts "   without a throw: #{catch(:found) { "block finished without a throw" }.inspect}"

puts "2. escaping nested loops"
cell = catch(:done) do
  (1..3).each do |i|
    (1..3).each do |j|
      puts "   visiting #{i},#{j}"
      throw :done, [i, j] if i * j == 4
    end
  end
  nil
end
puts "   first cell whose product is 4: #{cell.inspect}"

puts "3. a throw with no matching catch is an exception, and a StandardError"
begin
  throw :nope, 1
rescue => e
  puts "   #{e.class}: #{e.message.inspect}; tag #{e.tag.inspect}, value #{e.value.inspect}"
  puts "   e.is_a?(ArgumentError) #{e.is_a?(ArgumentError)}"
end

puts "4. a matched throw is not seen by a rescue in between, but ensure runs"
result = catch(:out) do
  begin
    throw :out, "thrown past the rescue"
  rescue => e
    puts "   rescue ran (it should not)"
  ensure
    puts "   ensure ran on the way out"
  end
  "block finished"
end
puts "   catch returned #{result.inspect}"

puts "5. catch with no tag makes one and hands it to the block"
puts "   catch { |tag| throw tag, 7 }   -> #{catch { |tag| throw tag, 7 }.inspect}"
puts "   the tag is a plain #{catch { |tag| tag.class }}"

puts "6. throw with no value throws nil"
puts "   catch(:t) { throw :t }         -> #{catch(:t) { throw :t }.inspect}"

puts "7. tags match by identity, which is why symbols are used"
begin
  catch("s") { throw "s".dup, 1 }
rescue UncaughtThrowError => e
  puts "   catch(\"s\") { throw \"s\".dup, 1 } -> #{e.class}: #{e.message.inspect}"
end
tag = "s"
puts "   the same String object       -> #{catch(tag) { throw tag, 1 }.inspect}"
puts "   :s.equal?(:s)                #{:s.equal?(:s)}"

puts "8. throw unwinds through method calls"
def descend(n) = n.zero? ? throw(:bottom, "reached the bottom") : descend(n - 1)
puts "   catch(:bottom) { descend(5) } -> #{catch(:bottom) { descend(5) }.inspect}"
