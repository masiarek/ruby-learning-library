# A Fiber is a coroutine you resume by hand.
#
# Nothing here runs concurrently: a fiber runs only while somebody resumes it,
# on the thread that resumed it, so every row is fixed by the program text.
def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1-5. Values travel both ways: in through resume, out through Fiber.yield
f = Fiber.new do |x|
  y = Fiber.yield x * 2
  z = Fiber.yield y + 1
  "done #{z}"
end
row 1, "resume(1): the block starts, yields x * 2", f.resume(1).inspect
row 2, "alive? while suspended at a yield", f.alive?
row 3, "resume(10): Fiber.yield returned 10, yields y + 1", f.resume(10).inspect
row 4, "resume(100): the block ends; its last value", f.resume(100).inspect
row 5, "alive? after the block ended", f.alive?

# 6-7. The two FiberErrors a beginner meets
begin
  f.resume
rescue FiberError => e
  row 6, "resume a finished fiber", "#{e.class}: #{e.message}"
end
begin
  Fiber.yield
rescue FiberError => e
  row 7, "Fiber.yield outside any fiber", "#{e.class}: #{e.message}"
end

# 8. Fiber#raise: the exception appears at the fiber's yield
g = Fiber.new do
  Fiber.yield 1
rescue => e
  "rescued #{e.class}: #{e.message}"
end
g.resume
row 8, "fiber.raise delivers an exception at the yield", "#{g.raise(RuntimeError, "stop").inspect}, alive? #{g.alive?}"

# 9-10. Fiber.current, and the thread a fiber runs on
root = Fiber.current
row 9, "Fiber.current: the root fiber's class / inside is root?", "#{root.class} / #{Fiber.new { Fiber.current.equal?(root) }.resume}"
row 10, "a fiber runs on the thread that resumed it", Fiber.new { Thread.current.equal?(Thread.main) }.resume

# 11. A generator: an endless loop that yields
fib = Fiber.new do
  a, b = 0, 1
  loop do
    Fiber.yield a
    a, b = b, a + b
  end
end
row 11, "a generator: 8 resumes of a Fibonacci fiber", Array.new(8) { fib.resume }.inspect

# 12. No preemption: control moves only at resume and yield
log = []
outer = Fiber.new do
  log << "outer 1"
  inner = Fiber.new do
    log << "inner 1"
    Fiber.yield
    log << "inner 2"
  end
  inner.resume
  log << "outer 2"
  inner.resume
  log << "outer 3"
end
outer.resume
row 12, "no preemption: control moves only at resume/yield", log.inspect

# 13. Fiber#kill (3.3+) unwinds the fiber; ensure runs
log2 = []
k = Fiber.new do
  Fiber.yield 1
ensure
  log2 << "ensure ran"
end
k.resume
k.kill
row 13, "Fiber#kill unwinds the fiber; ensure runs", "alive? #{k.alive?}, #{log2.inspect}"

# 14. Several values at once
pair = Fiber.new { |a, b| [a, b] }.resume(1, 2)
yielded = Fiber.new { Fiber.yield 1, 2 }.resume
row 14, "several values: resume(1, 2) / Fiber.yield 1, 2", "#{pair.inspect} / #{yielded.inspect}"

# 15. The hook for non-blocking fibers is empty unless a scheduler is installed
row 15, "Fiber.scheduler (hook for non-blocking fibers)", Fiber.scheduler.inspect
