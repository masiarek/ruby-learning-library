# Kata: three children, each exiting with its own index. The parent collects
# all three with Process.wait2 and prints the statuses sorted, because the
# order in which children finish is not something to record.
pids = (1..3).map { |i| fork { exit i } }
statuses = pids.map { Process.wait2[1] }

statuses.map(&:exitstatus).sort.each do |code|
  puts "a child exited with status #{code}"
end
puts "all three exited normally: #{statuses.all?(&:exited?)}"
puts "waiting again raises: #{(Process.wait rescue $!.class)}"
