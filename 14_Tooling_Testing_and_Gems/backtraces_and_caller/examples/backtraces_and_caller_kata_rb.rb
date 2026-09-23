# Kata: `who_called_me` answers with the label of whatever called it -- a
# method, a block inside a method, or the main program.
def who_called_me
  caller_locations(1, 1).first.label
end

class Report
  def build = who_called_me
  def each_line = [1, 2].map { who_called_me }
end

puts "1. from a method:     #{Report.new.build}"
puts "2. from a block:      #{Report.new.each_line.inspect}"
puts "3. from the top:      #{who_called_me}"
