# Exercise 1: classify(callable) prints lambda?, arity, and what call(1)
# does when the callable was written with two parameters.

def classify(name, callable)
  result = begin
    callable.call(1).inspect
  rescue ArgumentError => e
    "#{e.class}: #{e.message}"
  end
  puts "#{name.ljust(20)} lambda? #{callable.lambda?.to_s.ljust(5)} arity #{callable.arity.to_s.rjust(2)}  call(1) -> #{result}"
end

classify "proc { |a, b| }", proc { |a, b| [a, b] }
classify "->(a, b) { }", ->(a, b) { [a, b] }
classify "proc { |a, *b| }", proc { |a, *b| [a, b] }
classify "->(a, *b) { }", ->(a, *b) { [a, b] }
classify "proc { |a, b = 9| }", proc { |a, b = 9| [a, b] }
classify "->(a, b = 9) { }", ->(a, b = 9) { [a, b] }
