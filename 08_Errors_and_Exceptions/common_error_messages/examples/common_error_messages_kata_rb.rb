# Exercise 1: explain runs a block and turns the three commonest errors into a
# one-line diagnosis, leaving everything else labelled as unhandled.

def explain(code)
  yield
  puts "   #{code.ljust(22)} ok"
rescue NoMethodError => e
  hint = e.receiver.nil? ? "a nil reached a method call; guard it or use &." : "no such method; check the spelling and the receiver's class"
  puts "   #{code.ljust(22)} #{e.class}: #{hint}"
rescue KeyError => e
  puts "   #{code.ljust(22)} #{e.class}: use fetch with a default, or [] (key #{e.key.inspect})"
rescue ArgumentError => e
  puts "   #{code.ljust(22)} #{e.class}: check the call's arguments (#{e.message})"
rescue StandardError => e
  puts "   #{code.ljust(22)} unhandled: #{e.class}"
end

explain("nil.length") { nil.length }
explain('"s".zzz') { "s".zzz }
explain("{a: 1}.fetch(:x)") { { a: 1 }.fetch(:x) }
explain('Integer("abc")') { Integer("abc") }
explain("1 / 0") { 1 / 0 }
explain("[1, 2].first") { [1, 2].first }
