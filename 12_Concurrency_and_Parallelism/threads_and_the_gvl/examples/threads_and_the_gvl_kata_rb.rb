# Kata: five threads cube their index and report through a Queue; the results
# are printed in index order, then a failing thread shows what join re-raises
# and how its status differs from a finished thread's.
Thread.report_on_exception = false

q = Queue.new
threads = 5.times.map { |i| Thread.new(i) { |n| q << [n, n**3] } }
threads.each(&:join)

Array.new(q.size) { q.pop }.sort.each do |n, cube|
  puts "thread #{n}: #{n}**3 = #{cube}"
end
puts "statuses after join: #{threads.map(&:status).inspect}"

failing = Thread.new { raise "thread 5 failed" }
begin
  failing.join
rescue => e
  puts "join raised #{e.class}: #{e.message}"
end
puts "status of the failed thread: #{failing.status.inspect}"
puts "value of the failed thread: " + (failing.value rescue "raises #{$!.class} again")
