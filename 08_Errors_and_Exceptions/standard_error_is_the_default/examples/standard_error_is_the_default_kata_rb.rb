# Exercise 1: safe_call runs a block and turns a StandardError into a value, while
# letting exit (SystemExit) pass straight through to the top level.

def safe_call
  [:ok, yield]
rescue StandardError => e
  [:error, e.class]
end

puts "1. a value comes back tagged :ok"
p safe_call { 21 * 2 }

puts "2. a StandardError comes back tagged :error"
p safe_call { Integer("abc") }
p safe_call { {}.fetch(:missing) }

puts "3. exit is not a StandardError, so it passes through safe_call"
begin
  safe_call { exit 2 }
  puts "   never printed"
rescue SystemExit => e
  puts "   SystemExit reached the top level with status #{e.status}"
end
