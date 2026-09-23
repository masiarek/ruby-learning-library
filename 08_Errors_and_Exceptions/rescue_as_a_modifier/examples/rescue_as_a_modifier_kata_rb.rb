# Exercise 1: to_number tries Integer(), then Float(), then gives up with nil, using
# the modifier form for each step.

def to_number(text)
  Integer(text) rescue (Float(text) rescue nil)
end

["42", "4.2", "abc", "0x1f", "1e3", ""].each do |text|
  puts "   #{text.inspect.ljust(7)} -> #{to_number(text).inspect}"
end
