# Kata: a fiber that keeps a running total of the numbers it is resumed with.
# The first resume hands the block its parameter; every later resume becomes
# the value of Fiber.yield inside the loop.
total = Fiber.new do |n|
  sum = 0
  loop do
    sum += n
    n = Fiber.yield sum
  end
end

(1..5).each { |i| puts "resume(#{i}) -> running total #{total.resume(i)}" }
puts "alive? #{total.alive?} (the loop never ends; the fiber is only suspended)"
