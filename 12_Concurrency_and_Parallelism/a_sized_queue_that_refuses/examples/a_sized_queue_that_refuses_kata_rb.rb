# Kata: how many processes does the 40-requests-a-second run of section 2 need
# before nothing is refused? The same simulation, run once per pool size, and
# the smallest pool with no 503 at all is the answer.
CAP = 100
SERVICE = 200      # ms per request
SECONDS = 60
GAP = 25           # ms between arrivals: 40 a second

def simulate(pool)
  queue = []
  busy = []
  refused = 0
  peak = 0
  longest = 0
  t = 0
  loop do
    busy.reject! { |free_at| free_at <= t }
    if t < SECONDS * 1000 && (t % GAP).zero?
      if queue.size >= CAP then refused += 1 else queue << t end
    end
    while busy.size < pool && !queue.empty?
      waited = t - queue.shift
      longest = waited if waited > longest
      busy << t + SERVICE
    end
    peak = queue.size if queue.size > peak
    t += 1
    break if t >= SECONDS * 1000 && queue.empty? && busy.empty?
  end
  [peak, longest, refused]
end

puts format("%-6s %-12s %-14s %s", "pool", "peak queue", "longest wait", "refused")
answer = nil
(6..10).each do |pool|
  peak, longest, refused = simulate(pool)
  puts format("%-6d %-12d %-14s %d", pool, peak, "#{longest} ms", refused)
  answer ||= pool if refused.zero?
end
puts
puts "The pool clears #{1000 / SERVICE} requests a second per process, so 40 a second"
puts "needs #{40 * SERVICE / 1000} processes: the smallest pool that refuses nobody is #{answer}."
