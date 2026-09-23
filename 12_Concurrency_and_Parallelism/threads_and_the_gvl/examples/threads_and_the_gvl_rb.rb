# Threads are OS threads that take turns under the GVL.
#
# Every thread here is joined, every result comes back through `value`, a
# local or a Queue, and rows that could interleave are sorted -- so the output
# is the same on every run. Two claims about exit and stderr are measured in
# child Rubies, whose output is captured and printed on stdout.
require "open3"

Thread.report_on_exception = false

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1-3. Thread.new, join, value, alive?, status
t = Thread.new { 1 + 1 }
row 1, "join returns the thread itself", t.join.equal?(t)
row 2, "value is the block's last expression", t.value.inspect
row 3, "after it ends: alive? / status", "#{t.alive?} / #{t.status.inspect}"

# 4. Thread.current and Thread.main
inside = Thread.new { Thread.current.equal?(Thread.main) }.value
row 4, "Thread.current is Thread.main: outside / inside", "#{Thread.current.equal?(Thread.main)} / #{inside}"

# 5. Each Ruby thread is an OS thread of its own
other = Thread.new { Thread.current.native_thread_id }.value
row 5, "a new thread has its own native_thread_id", other != Thread.main.native_thread_id

# 6. Threads share every object; a block closes over the outer locals
x = 10
Thread.new { x += 1 }.join
row 6, "a thread did x += 1 on the outer local; x is now", x

# 7. Arguments are handed in through Thread.new
row 7, "Thread.new(1, 2) { |a, b| a + b }.value", Thread.new(1, 2) { |a, b| a + b }.value

# 8-9. An exception ends the thread; join (and value) re-raise it
bad = Thread.new { raise ArgumentError, "boom" }
begin
  bad.join
rescue ArgumentError => e
  row 8, "join re-raises the thread's exception", "#{e.class}: #{e.message}"
end
row 9, "status after an exception (nil, not false)", bad.status.inspect

# 10. status while sleeping, and of the running thread
sleeper = Thread.new { sleep }
sleep 0.01 until sleeper.status == "sleep"
row 10, "status: a sleeping thread / the current thread", "#{sleeper.status.inspect} / #{Thread.current.status.inspect}"
sleeper.kill
sleeper.join

# 11. Thread.pass is a hint to the scheduler, not an instruction
row 11, "Thread.pass returns", Thread.pass.inspect

# 12. Results from several threads: a Queue, then sort after joining
q = Queue.new
workers = 3.times.map { |i| Thread.new(i) { |n| q << [n, n * n] } }
workers.each(&:join)
row 12, "results through a Queue, sorted after join", Array.new(q.size) { q.pop }.sort.inspect

# 13. When the main thread ends, the other threads are killed (a child Ruby)
out, = Open3.capture3(RbConfig.ruby, "-e", 'Thread.new { sleep 1; puts "worker done" }; puts "main done"')
row 13, "main ends -> other threads are killed (child stdout)", out.inspect

# 14. With report_on_exception (the default), a dying thread also writes to stderr
_, err, = Open3.capture3(RbConfig.ruby, "-e", 'Thread.new { raise ArgumentError, "boom" }.join rescue nil')
row 14, "report_on_exception (default) -> child's stderr, line 1", err.lines.first.sub(/0x[0-9a-f]+/, "0x...").chomp.inspect
