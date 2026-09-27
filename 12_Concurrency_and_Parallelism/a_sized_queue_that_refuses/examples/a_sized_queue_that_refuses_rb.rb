# A SizedQueue that refuses is the 503 behind "queue full".
#
# Passenger keeps a fixed pool of application processes in front of a request
# queue with a cap, and a load balancer such as HAProxy in front of Passenger
# gives up on a request that takes too long. Sections 1 to 7 simulate that
# arrangement with the defaults Passenger ships -- a pool of 6, a queue of
# 100 -- and a 30-second gateway timeout, on a virtual clock that ticks once a
# millisecond, so every number is the same on every machine and nothing here
# sleeps. Sections 8 to 10 show the same refusal in Ruby's own SizedQueue, the
# class a request queue would be written with.

POOL = 6              # passenger_max_pool_size, the default
CAP = 100             # passenger_max_request_queue_size, the default
GATEWAY_TIMEOUT = 30_000   # HAProxy's `timeout server`, in ms: after this it answers 504 itself
CHECKPOINTS = [5, 20, 40, 60].freeze   # the seconds whose peak queue is reported

Run = Struct.new(:offered, :served, :refused, :timed_out, :full_at, :longest_wait, :last_arrival, :cleared, :snapshots)

# Requests arrive on a timetable: `timetable` is called with each millisecond
# and returns how many requests arrive then. Every process answers one request
# at a time and takes `service` ms over it. A request whose wait plus service
# passes the gateway timeout is a 504: the browser got HAProxy's answer while
# Passenger was still working. The clock runs on past the last arrival until
# the queue is empty and every process is idle.
def simulate(pool:, cap:, service:, seconds:, timetable:)
  queue = []    # arrival time of each request waiting for a process
  busy = []     # the moment each busy process becomes free
  run = Run.new(0, 0, 0, 0, nil, 0, 0, 0, [])
  peak = 0      # the most in the queue at any moment of the current second
  t = 0
  loop do
    busy.reject! { |free_at| free_at <= t }
    timetable.call(t).times do
      run.offered += 1
      run.last_arrival = t
      if cap && queue.size >= cap
        run.refused += 1
        run.full_at ||= t
      else
        queue << t
      end
    end
    while busy.size < pool && !queue.empty?
      waited = t - queue.shift
      run.longest_wait = waited if waited > run.longest_wait
      run.timed_out += 1 if waited + service > GATEWAY_TIMEOUT
      busy << t + service
      run.served += 1
      run.cleared = t + service
    end
    peak = queue.size if queue.size > peak
    if ((t + 1) % 1000).zero?
      run.snapshots << peak if CHECKPOINTS.include?((t + 1) / 1000)
      peak = 0
    end
    t += 1
    break if t >= seconds * 1000 && queue.empty? && busy.empty?
  end
  run
end

# `per_second` requests a second, evenly spaced, for `seconds` seconds.
def steady(per_second, seconds)
  gap = 1000 / per_second
  ->(t) { t < seconds * 1000 && (t % gap).zero? ? 1 : 0 }
end

# A registration window opening: 200 requests in the first second, then 20/s.
def burst(seconds)
  ->(t) do
    if t < 1000 then (t % 5).zero? ? 1 : 0
    elsif t < seconds * 1000 then (t % 50).zero? ? 1 : 0
    else 0
    end
  end
end

def tenths(ms) = "#{ms / 1000}.#{ms % 1000 / 100} s"

def line(label, value) = puts(format("   %-42s %s", label, value))

def report(number, title, run)
  puts format("%2d. %s", number, title)
  snapshots = run.snapshots.join(" / ")
  full = run.full_at ? "full from #{tenths(run.full_at)}" : "never full"
  line "peak queue in second #{CHECKPOINTS.join(' / ')}", "#{snapshots}    #{full}"
  line "longest wait in the queue", tenths(run.longest_wait)
  line "refused with 503 (Passenger: queue full)", "#{run.refused} of #{run.offered}"
  line "timed out with 504 (HAProxy: 30 s passed)", "#{run.timed_out} of #{run.offered}"
  line "queue empty again", "#{tenths(run.cleared - run.last_arrival)} after the last arrival"
  puts
end

puts "Passenger's defaults: a pool of #{POOL} processes, each answering one request"
puts "at a time, in front of a request queue of #{CAP}. When a request takes 200 ms,"
puts "the pool answers at most #{POOL * 1000 / 200} a second. HAProxy, in front, waits"
puts "#{GATEWAY_TIMEOUT / 1000} s for an answer and then sends a 504 itself."
puts "(A simulation on a millisecond clock, not Passenger or HAProxy themselves.)"
puts

report 1, "25 requests/s for 60 s: under the 30/s the pool clears",
       simulate(pool: POOL, cap: CAP, service: 200, seconds: 60, timetable: steady(25, 60))

report 2, "40 requests/s for 60 s: over 30/s, queue capped at #{CAP}",
       simulate(pool: POOL, cap: CAP, service: 200, seconds: 60, timetable: steady(40, 60))

report 3, "the same 40 requests/s, queue uncapped",
       simulate(pool: POOL, cap: nil, service: 200, seconds: 60, timetable: steady(40, 60))

report 4, "25 requests/s again, but a slow database: 2000 ms per request",
       simulate(pool: POOL, cap: CAP, service: 2000, seconds: 60, timetable: steady(25, 60))

report 5, "a registration window: 200 requests in the first second, then 20/s",
       simulate(pool: POOL, cap: CAP, service: 200, seconds: 60, timetable: burst(60))

report 6, "the same window, queue uncapped",
       simulate(pool: POOL, cap: nil, service: 200, seconds: 60, timetable: burst(60))

report 7, "the database locks up: 5 requests/s, 40 000 ms per request",
       simulate(pool: POOL, cap: CAP, service: 40_000, seconds: 60, timetable: steady(5, 60))

def row(n, label, value) = puts(format("%2d. %-52s %s", n, label, value))

# 8. The class itself: a SizedQueue's non-blocking push raises when it is full
sq = SizedQueue.new(CAP)
CAP.times { |i| sq.push(i) }
begin
  sq.push(:one_more, true)
rescue ThreadError => e
  row 8, "SizedQueue.new(#{CAP}): push #{CAP}, then push(job, true)", "#{e.class}: #{e.message}"
end

# 9. push with a timeout of 0 gives up at once, and says so with nil
row 9, "push(job, timeout: 0) on the full queue", sq.push(:one_more, timeout: 0).inspect

# 10. A plain Queue has no cap, so it never refuses
q = Queue.new
(CAP * 1000 + 1).times { |i| q.push(i) }
row 10, "Queue.new has no cap: push number #{CAP * 1000 + 1}", "size #{q.size}"
