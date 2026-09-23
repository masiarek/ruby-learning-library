# `receiver&.method` returns nil without calling anything -- not even
# evaluating the arguments -- when the receiver is nil, and only nil.
# `dig` does the same across nested Hashes and Arrays; `fetch` is the
# strict opposite of `[]`.

def noisy
  print "(argument evaluated) "
  "!"
end

def attempt
  yield.inspect
rescue NoMethodError, KeyError, TypeError => e
  "#{e.class}: #{e.message}"
end

Address = Struct.new(:city)
User = Struct.new(:address)
u1 = User.new(Address.new("Oslo"))
u2 = User.new(nil)
h = { a: { b: { c: 1 } } }

name = nil
puts "1. a method on nil:               name.length          -> #{attempt { name.length }}"
puts "2. safe navigation:               name&.length         -> #{attempt { name&.length }}, \"abc\"&.length -> #{"abc"&.length}"
print "3. the arguments are skipped:     nil&.concat(noisy)   -> "
puts attempt { nil&.concat(noisy) }
print "   ...and evaluated otherwise:    \"x\"&.concat(noisy)   -> "
puts attempt { "x"&.concat(noisy) }
puts "4. only nil is skipped:           false&.to_s          -> #{attempt { false&.to_s }} (false is a real object with methods)"
puts "5. a chain of objects:            u1.address&.city     -> #{attempt { u1.address&.city }}, u2.address&.city -> #{attempt { u2.address&.city }}"
puts "                                  u2.address.city      -> #{attempt { u2.address.city }}"
puts "6. dig through nested Hashes:     h.dig(:a, :b, :c)    -> #{attempt { h.dig(:a, :b, :c) }}, h.dig(:a, :x, :c) -> #{attempt { h.dig(:a, :x, :c) }}"
puts "                                  h[:a][:x][:c]        -> #{attempt { h[:a][:x][:c] }}"
puts "7. [] is lenient, fetch is strict: h[:zz]              -> #{attempt { h[:zz] }}, h.fetch(:zz) -> #{attempt { h.fetch(:zz) }}"
puts "                                  h.fetch(:zz, \"default\") -> #{attempt { h.fetch(:zz, "default") }}"
puts "8. Array#dig and a dead end:      [[1, [2]]].dig(0, 1, 0) -> #{attempt { [[1, [2]]].dig(0, 1, 0) }}, [].dig(0, 1) -> #{attempt { [].dig(0, 1) }}"
puts "                                  h.dig(:a, :b, :c, :d) -> #{attempt { h.dig(:a, :b, :c, :d) }}"
puts "9. &. guards one call only:       nil&.length.zero?    -> #{attempt { nil&.length.zero? }}"
puts "                                  nil&.length&.zero?   -> #{attempt { nil&.length&.zero? }}"
