# Kata: a slow job under Timeout.timeout, twice -- once with a limit it
# cannot meet, once with one it can. The rescue prints the error, the ensure
# proves the cleanup ran both times, and the value comes back the second time.
require "timeout"

def slow_job(seconds)
  sleep seconds
  "finished a #{seconds} s job"
end

[[0.2, 5], [2, 0.1]].each do |limit, work|
  result = Timeout.timeout(limit) { slow_job(work) }
  puts "limit #{limit} s, job #{work} s: #{result}"
rescue Timeout::Error => e
  puts "limit #{limit} s, job #{work} s: #{e.class} (#{e.message})"
ensure
  puts "  cleanup ran"
end
