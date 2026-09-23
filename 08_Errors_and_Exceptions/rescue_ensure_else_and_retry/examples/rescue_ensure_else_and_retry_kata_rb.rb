# Exercise 1: a with_retries helper that re-runs its block up to `times` times,
# reports every failed attempt, and re-raises the last failure to the caller.

def with_retries(times)
  attempts = 0
  begin
    attempts += 1
    yield attempts
  rescue StandardError => e
    puts "   attempt #{attempts} failed with #{e.class}: #{e.message}"
    retry if attempts < times
    raise
  end
end

puts "1. succeeds on the third try"
result = with_retries(5) do |n|
  raise ArgumentError, "not yet" if n < 3
  "done after #{n} attempts"
end
puts "   #{result}"

puts "2. gives up after the limit and re-raises"
begin
  with_retries(2) { |n| raise IOError, "still failing (attempt #{n})" }
rescue IOError => e
  puts "   caller saw #{e.class}: #{e.message}"
end
