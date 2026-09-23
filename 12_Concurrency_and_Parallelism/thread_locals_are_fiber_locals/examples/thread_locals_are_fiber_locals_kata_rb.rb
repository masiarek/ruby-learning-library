# Kata: a request id that must follow the work. Thread.current[] does not
# cross a fiber boundary, Fiber[] does, and a new thread inherits Fiber[]
# but starts with an empty Thread.current[].
Thread.current[:request_id] = "req-42"
Fiber[:request_id] = "req-42"

def ids
  "Thread.current[:request_id]=#{Thread.current[:request_id].inspect}  Fiber[:request_id]=#{Fiber[:request_id].inspect}"
end

puts "root fiber:        #{ids}"
puts "a new Fiber:       #{Fiber.new { ids }.resume}"
puts "Enumerator#next:   #{Enumerator.new { |y| y << ids }.next}"
puts "a new Thread:      #{Thread.new { ids }.value}"
