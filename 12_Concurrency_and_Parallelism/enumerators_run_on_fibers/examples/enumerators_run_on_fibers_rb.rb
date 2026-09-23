# Enumerator#next runs the block on its own Fiber.
#
# The same Enumerator block is driven two ways: internally (each, to_a, map,
# first), where it runs on the fiber that called it, and externally (next,
# peek), where Ruby runs it on a private fiber and resumes it one value at a
# time. The block reports which fiber it is on.
def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

root = Fiber.current
main_thread = Thread.current
e = Enumerator.new do |y|
  y << Fiber.current.equal?(root)
  y << Fiber.current.equal?(root)
  :finished
end

# 1. Internal iteration: the block runs right here, on the root fiber
row 1, "to_a (internal): the block runs on the root fiber?", e.to_a.inspect

# 2-3. External iteration: next runs the block on a private fiber
row 2, "next (external): on the root fiber?", e.next.inspect
row 3, "next again: the same private fiber, resumed", e.next.inspect

# 4-6. The end of the block
begin
  e.next
rescue StopIteration => ex
  row 4, "next past the end", "#{ex.class}: #{ex.message}"
  row 5, "StopIteration#result is the block's return value", ex.result.inspect
end
row 6, "next once more", (e.next rescue $!.class).inspect

# 7. rewind throws the private fiber away
e.rewind
row 7, "rewind, then next starts the block over", e.next.inspect

# 8-9. peek, and what loop does with StopIteration
ext = [10, 20].each
row 8, "peek / next / next on [10, 20].each", "#{ext.peek} / #{ext.next} / #{ext.next}"
row 9, "loop rescues StopIteration and returns its result", loop { ext.next }.inspect

# 10. What Yielder#yield returns to the block: each's block value, else nil
en = Enumerator.new do |y|
  got = y.yield(1)
  y << "yield returned #{got.inspect}"
end
seen = []
en.each { |v| seen << v; v.is_a?(Integer) ? v * 10 : v }
mapped = en.map { |v| v.is_a?(Integer) ? v * 10 : v }
row 10, "Yielder#yield returns: under each / map / next", "#{seen.inspect} / #{mapped.inspect} / #{[en.next, en.next].inspect}"

# 11. first, take and lazy stay internal
fresh = -> { Enumerator.new { |y| y << Fiber.current.equal?(root) } }
row 11, "first / take(1) / lazy.first(1): on the root fiber?", "#{fresh.call.first} / #{fresh.call.take(1).inspect} / #{fresh.call.lazy.first(1).inspect}"

# 12. size is nil unless the enumerator was told
row 12, "size: Enumerator.new { } / Enumerator.new(3) { }", "#{Enumerator.new { |y| y << 1 }.size.inspect} / #{Enumerator.new(3) { |y| y << 1 }.size}"

# 13. The private fiber runs on the calling thread
row 13, "under next, the block is on the calling thread", Enumerator.new { |y| y << Thread.current.equal?(main_thread) }.next

# 14. The Yielder's own API
row 14, "Enumerator::Yielder's own methods", Enumerator::Yielder.instance_methods(false).sort.inspect
