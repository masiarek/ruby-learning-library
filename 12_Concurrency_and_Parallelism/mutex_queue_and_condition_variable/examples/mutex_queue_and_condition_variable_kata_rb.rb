# Kata: two producers push 1..5 and 6..10 through a SizedQueue of capacity 3;
# two consumers pop until the queue is closed and add what they get into a
# total that a Mutex guards. The total and the count are the same on every
# run; which consumer took which item is not, so it is not printed.
sq = SizedQueue.new(3)
producers = [(1..5), (6..10)].map do |range|
  Thread.new { range.each { |i| sq << i } }
end

lock = Mutex.new
total = 0
count = 0
consumers = 2.times.map do
  Thread.new do
    while (item = sq.pop)
      lock.synchronize do
        total += item
        count += 1
      end
    end
  end
end

producers.each(&:join)
sq.close
consumers.each(&:join)

puts "capacity of the queue:  #{sq.max}"
puts "items consumed:         #{count}"
puts "sum of the items:       #{total}"
puts "closed and drained:     #{sq.closed? && sq.empty?}"
