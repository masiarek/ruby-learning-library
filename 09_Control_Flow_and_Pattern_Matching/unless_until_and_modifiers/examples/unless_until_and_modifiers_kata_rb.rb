# Exercise 1: drain a queue three ways -- until, a while modifier, and a
# begin ... end until body that runs once even when the queue starts empty.

queue = [3, 1, 2]
until queue.empty?
  puts "until loop took #{queue.shift}"
end

queue = [3, 1, 2]
puts "modifier took #{queue.shift}" while queue.any?

queue = []
tries = 0
begin
  tries += 1
  puts "begin...end until: pass #{tries}, queue empty? #{queue.empty?}"
end until queue.empty?
puts "the body ran #{tries} time(s) although the queue was empty from the start"
