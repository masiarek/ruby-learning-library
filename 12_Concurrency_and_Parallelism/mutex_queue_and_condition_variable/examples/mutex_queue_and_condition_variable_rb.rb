# Mutex guards, Queue hands over, ConditionVariable waits.
#
# Every thread is joined before its result is printed; the only order that
# reaches the page is one the synchronisation itself fixes.
require "monitor"

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1. A Mutex makes `count += 1` exact
m = Mutex.new
count = 0
10.times.map { Thread.new { 1000.times { m.synchronize { count += 1 } } } }.each(&:join)
row 1, "10 threads x 1000 synchronize { count += 1 }", count

# 2. locked? and owned?
outside = [m.locked?, m.owned?]
inside = m.synchronize { [m.locked?, m.owned?] }
row 2, "locked?/owned? outside -> inside synchronize", "#{outside.inspect} -> #{inside.inspect}"

# 3. try_lock never blocks
held = m.synchronize { m.try_lock }
free = m.try_lock
m.unlock
row 3, "try_lock while I hold it / while it is free", "#{held} / #{free}"

# 4. Unlocking a mutex nobody holds
begin
  m.unlock
rescue ThreadError => e
  row 4, "unlock when not locked", "#{e.class}: #{e.message}"
end

# 5-6. A Mutex is not re-entrant; a Monitor is
begin
  m.synchronize { m.synchronize {} }
rescue ThreadError => e
  row 5, "synchronize inside synchronize (Mutex)", "#{e.class}: #{e.message}"
end
mon = Monitor.new
row 6, "the same on a Monitor (re-entrant)", mon.synchronize { mon.synchronize { :ok } }.inspect

# 7. synchronize is an expression
row 7, "synchronize returns", m.synchronize { :the_blocks_value }.inspect

# 8. Queue: pop blocks; close makes pop return nil once the queue is drained
q = Queue.new
consumer = Thread.new do
  got = []
  while (item = q.pop)
    got << item
  end
  got
end
q << 1
q << 2
q.push(3)
q.close
row 8, "pop until close makes it return nil", "#{consumer.value.inspect}, closed? #{q.closed?}"

# 9. Pushing after close
begin
  q << 4
rescue ClosedQueueError => e
  row 9, "push after close", "#{e.class}: #{e.message}"
end

# 10. pop with a timeout, and the non-blocking pop
empty = Queue.new
timed = empty.pop(timeout: 0.2)
begin
  empty.pop(true)
rescue ThreadError => e
  row 10, "pop(timeout: 0.2) / pop(true) on an empty queue", "#{timed.inspect} / #{e.class}: #{e.message}"
end

# 11. SizedQueue: the producer blocks when the queue is full
sq = SizedQueue.new(2)
producer = Thread.new do
  5.times { |i| sq << i }
  sq.close
end
taken = []
while (item = sq.pop)
  taken << item
end
producer.join
row 11, "SizedQueue.new(2): max, 5 items through it", "#{sq.max}, #{taken.inspect}"

# 12. ConditionVariable: wait releases the mutex and sleeps; signal wakes one waiter
lock = Mutex.new
cv = ConditionVariable.new
ready = false
log = Queue.new
waiter = Thread.new do
  lock.synchronize do
    log << "waiter: entering wait"
    cv.wait(lock) until ready
    log << "waiter: woke, ready is #{ready}"
  end
end
sleep 0.01 until waiter.status == "sleep"
lock.synchronize do
  ready = true
  log << "signaller: set ready, signalling"
  cv.signal
end
waiter.join
row 12, "ConditionVariable wait/signal, in order", Array.new(log.size) { log.pop }.inspect

# 13. Ruby's Queue has no task_done/join: join the workers instead
row 13, "Queue#task_done / Queue#join exist?", "#{Queue.method_defined?(:task_done)} / #{Queue.method_defined?(:join)}"
