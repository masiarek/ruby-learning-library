# Timeout.timeout interrupts a thread from outside.
#
# Every limit here is 0.2 s against a 5 s sleep, so a slow machine cannot
# change a row; every thread is killed or joined before the next row; and
# no time is printed, only what happened.
require "timeout"

Thread.report_on_exception = false

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1-3. Timeout.timeout, and the watcher thread it starts
row 1, "threads before any Timeout.timeout call (names)", Thread.list.map(&:name).inspect
begin
  Timeout.timeout(0.2) { sleep 5 }
rescue Timeout::Error => e
  row 2, "Timeout.timeout(0.2) { sleep 5 }", "#{e.class}: #{e.message}"
end
row 3, "after: the watcher thread exists (names)", Thread.list.map(&:name).inspect

# 4-6. In time, no limit, your own error
row 4, "a block that finishes in time returns its value", Timeout.timeout(1) { :fast }.inspect
row 5, "timeout(nil) / timeout(0) mean no limit", "#{Timeout.timeout(nil) { :a }.inspect} / #{Timeout.timeout(0) { :b }.inspect}"
begin
  Timeout.timeout(0.2, ArgumentError, "too slow") { sleep 5 }
rescue ArgumentError => e
  row 6, "your own class and message", "#{e.class}: #{e.message}"
end

# 7. What the interrupted block sees, and what the caller sees
seen = []
begin
  Timeout.timeout(0.2) do
    sleep 5
  rescue Exception => e
    seen << "inside rescued #{e.class}"
    raise
  ensure
    seen << "inside ensure ran"
  end
rescue Timeout::Error => e
  seen << "outside rescued #{e.class}"
end
row 7, "what the block sees / what the caller sees", seen.inspect

# 8-9. Timeout::Error is a RuntimeError; a busy loop is interrupted too
row 8, "Timeout::Error's ancestors", Timeout::Error.ancestors.take(3).inspect
begin
  Timeout.timeout(0.2) do
    n = 0
    loop { n += 1 }
  end
rescue Timeout::Error => e
  row 9, "a busy loop (no sleep) is interrupted too", e.class
end

# 10. Thread#kill: the thread's ensure blocks still run
log = Queue.new
t = Thread.new do
  sleep 5
ensure
  log << "ensure ran"
end
sleep 0.01 until t.status == "sleep"
t.kill
t.join
row 10, "Thread#kill: ensure runs; status / alive?", "#{log.pop.inspect}; #{t.status.inspect} / #{t.alive?}"

# 11. join with a limit
t2 = Thread.new { sleep 5 }
row 11, "join(0.2) on a 5 s thread / alive?", "#{t2.join(0.2).inspect} / #{t2.alive?}"
t2.kill
t2.join

# 12-13. wakeup and run end a sleep early
t3 = Thread.new { sleep; :woke }
sleep 0.01 until t3.status == "sleep"
t3.wakeup
row 12, "Thread#wakeup ends a sleep with no limit", t3.value.inspect
t4 = Thread.new { sleep 5; :sleep_cut_short }
sleep 0.01 until t4.status == "sleep"
t4.run
row 13, "Thread#run ends a timed sleep early", t4.value.inspect

# 14. Thread#raise: what Timeout uses
t5 = Thread.new do
  sleep 5
rescue => e
  "rescued #{e.class}: #{e.message}"
end
sleep 0.01 until t5.status == "sleep"
t5.raise(RuntimeError, "wake up")
row 14, "Thread#raise delivers an exception into a thread", t5.value.inspect

# 15. The safe kind of timeout: one built into the wait
row 15, "Queue#pop(timeout: 0.2) on an empty queue", Queue.new.pop(timeout: 0.2).inspect
