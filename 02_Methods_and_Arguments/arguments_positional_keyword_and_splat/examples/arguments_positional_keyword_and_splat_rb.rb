# The kinds of parameter a Ruby method can declare, `...` and anonymous
# forwarding, the three ArgumentError messages, and Ruby 3's rule that a
# Hash argument never becomes keywords by itself.

def f(a, b = 2, *rest, z)
  [a, b, rest, z]
end

def g(a, k:, d: 4, **opts)
  [a, k, d, opts]
end

def h(&blk) = blk.call(3)

def target(*args, **opts, &blk) = [args, opts, blk&.call]
def fwd(...) = target(...)
def anon(*, **, &) = target(*, **, &)

def kw(k:, d: 4) = [k, d]
def two(a, b) = [a, b]
def pos(a) = a

def attempt
  yield.inspect
rescue ArgumentError => e
  "#{e.class}: #{e.message}"
end

puts "1. required, optional, *rest, post-required:  def f(a, b = 2, *rest, z)"
puts "   f(1, 9)                    -> #{f(1, 9).inspect}"
puts "   f(1, 2, 3, 4, 5)           -> #{f(1, 2, 3, 4, 5).inspect}"
puts "2. introspected:              method(:f).parameters -> #{method(:f).parameters.inspect}"
puts "3. keywords:                  def g(a, k:, d: 4, **opts)"
puts "   g(1, k: 2)                 -> #{g(1, k: 2).inspect}"
puts "   g(1, k: 2, d: 5, x: 6)     -> #{g(1, k: 2, d: 5, x: 6).inspect}"
puts "4. a block parameter:         h { |x| x * 2 }       -> #{h { |x| x * 2 }}"
puts "5. ... forwards everything:   fwd(1, 2, k: 3) { :b } -> #{fwd(1, 2, k: 3) { :b }.inspect}"
puts "6. anonymous *, ** and &:     anon(1, k: 2) { :b }  -> #{anon(1, k: 2) { :b }.inspect}"
puts "   its parameters             -> #{method(:anon).parameters.inspect}"
puts "7. too few positionals:       f(1)                  -> #{attempt { f(1) }}"
puts "8. a missing keyword:         kw()                  -> #{attempt { kw() }}"
puts "9. an unknown keyword:        kw(k: 1, z: 2)        -> #{attempt { kw(k: 1, z: 2) }}"
puts "10. a Hash is not keywords:   kw({k: 1})            -> #{attempt { kw({k: 1}) }}"
puts "    but ** splats it:         kw(**{k: 1})          -> #{attempt { kw(**{k: 1}) }}"
puts "11. positionals have no names: two(b: 2, a: 1)      -> #{attempt { two(b: 2, a: 1) }}"
puts "    the Hash lands in one slot: pos(a: 1)           -> #{attempt { pos(a: 1) }} (a #{pos(a: 1).class})"
puts "12. arity:                    f #{method(:f).arity}, g #{method(:g).arity}, kw #{method(:kw).arity}, two #{method(:two).arity}, anon #{method(:anon).arity}"
