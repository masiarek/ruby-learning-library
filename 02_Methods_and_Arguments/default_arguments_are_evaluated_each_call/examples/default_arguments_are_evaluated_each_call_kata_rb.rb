# Kata: three calls, three separate arrays; the default is used only when
# the argument is omitted; and a default that hands out sequence numbers.
def append_log(msg, log = [])
  log << msg
end

first = append_log(:a)
second = append_log(:b)
puts "1. append_log(:a), append_log(:b) -> #{first.inspect}, #{second.inspect}"
puts "   first.equal?(second)           -> #{first.equal?(second)} (two arrays, not one shared default)"
shared = []
append_log(:a, shared)
append_log(:b, shared)
puts "2. the same array passed twice    -> #{shared.inspect} (the default is skipped, so it accumulates)"

$seq = 0
def next_id(id = ($seq += 1)) = id
puts "3. next_id, next_id               -> #{next_id}, #{next_id}"
puts "   next_id(99), next_id           -> #{next_id(99)}, #{next_id} (an explicit id leaves the counter alone)"
