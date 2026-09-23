# A seeded Random repeats its sequence: the same seed gives the same
# Integers, Floats, shuffles and samples on every run and every machine.
# The unseeded sources — Random.new_seed and SecureRandom — are printed only
# by class or size, because their values change every time.
require "securerandom"

def row(n, expr, value, note = "")
  puts format("%2d. %-44s -> %-30s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue ArgumentError, NameError => e
  "#{e.class}: #{e.message}"
end

r = Random.new(42)
ints = Array.new(5) { r.rand(100) }
r = Random.new(42)
floats = Array.new(3) { r.rand }
r = Random.new(42)
dice = Array.new(10) { r.rand(1..6) }

srand(42)
first = [rand(10), rand(10)]
previous = srand(42)
second = [rand(10), rand(10)]

row 1,  "Random.new(42).rand(100)",                   Random.new(42).rand(100).inspect,       "an Integer in 0...100 from a seeded generator"
row 2,  "Random.new(42), then 5 x rand(100)",         ints.inspect,                           "the same seed always starts the same stream"
row 3,  "Random.new(42), then 3 x rand",              floats.inspect,                         "rand with no argument is a Float in [0, 1)"
row 4,  "Random.new(42), then 10 x rand(1..6)",       dice.inspect,                           "a Range is inclusive: dice"
row 5,  "srand(42); [rand(10), rand(10)]",            first.inspect,                          "srand seeds the process-wide generator behind Kernel#rand"
row 6,  "srand(42) again; [rand(10), rand(10)]",      second.inspect,                         "reseeding restarts the stream; that srand returned the previous seed, #{previous}"
row 7,  "[1, 2, 3, 4, 5].shuffle(random: Random.new(1))", [1, 2, 3, 4, 5].shuffle(random: Random.new(1)).inspect, "shuffle and sample take their generator as a keyword"
row 8,  "[1, 2, 3, 4, 5].sample(2, random: Random.new(1))", [1, 2, 3, 4, 5].sample(2, random: Random.new(1)).inspect, "sample never repeats an element"
row 9,  "Random.new(42) == Random.new(42)",           (Random.new(42) == Random.new(42)).inspect, "same seed, same position: equal; Random.new(42).seed is #{Random.new(42).seed}"
row 10, "Random.new(42).rand(2 ** 70)",               Random.new(42).rand(2 ** 70).inspect,   "any size of Integer"
row 11, "Random.new(42).rand(0)",                     caught { Random.new(42).rand(0) },      "an empty range raises; Kernel#rand(0) is the exception, a #{rand(0).class}"
row 12, "Random::DEFAULT",                            caught { Random::DEFAULT },             "gone; Random.rand and Kernel#rand use the process-wide generator"
row 13, "Random.new_seed.class",                      Random.new_seed.class.inspect,          "a fresh seed from the OS on each call: new_seed != new_seed is #{Random.new_seed != Random.new_seed}"
row 14, "SecureRandom.hex(8).size",                   SecureRandom.hex(8).size.inspect,       "unpredictable and unseedable, so only its shape is printed; uuid.size is #{SecureRandom.uuid.size}"
row 15, "Random.new(2 ** 70).rand(2 ** 32), and .rand", "#{Random.new(2 ** 70).rand(2 ** 32)}, #{Random.new(2 ** 70).rand}", "a seed wider than 32 bits loads MT19937 the same way in both languages: Python prints these two numbers too"
