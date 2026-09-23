# Thread.current[:x] is fiber-local, not thread-local.
#
# Three stores, one thread: Thread.current[] (per fiber), thread_variable_get/
# set (per thread) and Fiber[] (inherited by child fibers and new threads).
# Every fiber and thread here is resumed or joined before its answer prints.
def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1-3. Thread.current[] is scoped to the fiber that set it
Thread.current[:x] = 1
row 1, "Thread.current[:x] = 1; read back in the root fiber", Thread.current[:x].inspect
row 2, "Thread.current[:x] inside a new Fiber", Fiber.new { Thread.current[:x] }.resume.inspect
Fiber.new { Thread.current[:x] = 9 }.resume
row 3, "a fiber set [:x] = 9; the root fiber still sees", Thread.current[:x].inspect

# 4-5. thread_variable_get/set is scoped to the thread
Thread.current.thread_variable_set(:y, 2)
row 4, "thread_variable_get(:y) inside a new Fiber", Fiber.new { Thread.current.thread_variable_get(:y) }.resume.inspect
Fiber.new { Thread.current.thread_variable_set(:y, 3) }.resume
row 5, "a fiber set :y = 3; the thread now sees", Thread.current.thread_variable_get(:y).inspect

# 6. A new thread starts with neither
in_thread = Thread.new { [Thread.current[:x], Thread.current.thread_variable_get(:y)] }.value
row 6, "a new Thread sees [:x] / thread_variable :y", in_thread.map(&:inspect).join(" / ")

# 7. The practical trap: Enumerator#next runs the block on its own fiber
en = Enumerator.new do |y|
  y << Thread.current[:x]
  y << Thread.current.thread_variable_get(:y)
end
row 7, "in an Enumerator: to_a (root fiber) / next (own fiber)", "#{en.to_a.inspect} / #{[en.next, en.next].inspect}"

# 8-11. Fiber storage (Ruby 3.2): inherited by child fibers and by new threads
Fiber[:req] = "abc"
row 8, "Fiber[:req] = \"abc\"; inside a child Fiber", Fiber.new { Fiber[:req] }.resume.inspect
child = Fiber.new { Fiber[:req] = "child"; Fiber[:req] }.resume
row 9, "a child set Fiber[:req] = \"child\": child / root", "#{child.inspect} / #{Fiber[:req].inspect}"
row 10, "Fiber[:req] in a new Thread / in Enumerator#next", "#{Thread.new { Fiber[:req] }.value.inspect} / #{Enumerator.new { |y| y << Fiber[:req] }.next.inspect}"
row 11, "Fiber.new(storage: nil) starts with nothing", Fiber.new(storage: nil) { Fiber[:req] }.resume.inspect

# 12-13. Looking at the three stores, and at a missing key
row 12, "keys / thread_variables / Fiber.current.storage", "#{Thread.current.keys.inspect} / #{Thread.current.thread_variables.inspect} / #{Fiber.current.storage.inspect}"
row 13, "a missing key: [:nope] / fetch(:nope)", "#{Thread.current[:nope].inspect} / #{(Thread.current.fetch(:nope) rescue $!.class)}"
