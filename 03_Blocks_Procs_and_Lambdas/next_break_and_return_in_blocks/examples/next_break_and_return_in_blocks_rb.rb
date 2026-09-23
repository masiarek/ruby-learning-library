# Three exits at three distances: `next v` ends this run of the block and
# makes v its value; `break v` ends the method the block was given to and
# makes v that call's value; `return` ends the method the block was written
# in. `redo` runs the same iteration again. The Python twin prints the same
# rows with continue, break, return and a hand-made retry.

W = 50
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def first_even(xs)
  xs.each { |x| return x if x.even? }   # return leaves first_even, not just the block
  :none
end

def two_levels
  [1, 2].each do |a|
    [10, 20].each do |b|
      return [a, b] if a * b == 20     # one return leaves both loops
    end
  end
  nil
end

def run_block
  yield                                # a break in the block ends run_block
end

def call_proc(&b)
  b.call                               # the same block, called as a proc
end

def with_ensure
  yield
ensure
  puts "    ensure ran"
end

row 1, "next v is this run's value; bare next is nil:", "#{[1, 2, 3].map { |x| next 0 if x.even?; x }}, #{[1].map { next }}"
row 2, "break v ends each and is the call's value:", "#{[1, 2, 3].each { |x| break 42 if x == 2 }}; no break: each returns #{[1, 2, 3].each { |x| }}"
row 3, "break inside map discards the array:", "#{[1, 2, 3].map { |x| break x * 100 if x == 2; x }}; bare break: #{[1].map { break }.inspect}"
row 4, "break leaves an endless loop with a value:", "#{(1..Float::INFINITY).each { |i| break i if i * i > 50 }}, loop { break :done } = #{loop { break :done }.inspect}"
row 5, "return leaves the method the block is in:", "#{first_even([1, 4, 6])}, #{first_even([1, 3]).inspect}, two levels: #{two_levels}"

tries = 0
seen = []
[1, 2].each { |x| tries += 1; seen << x; redo if tries == 1 }
row 6, "redo runs the same iteration again:", "tries #{tries}, seen #{seen}"

pr = proc { |x| next x * 2; :unreached }
lm = ->(x) { next x * 2; :unreached }
row 7, "next in a proc or lambda ends it with a value:", "proc #{pr.call(3)}, lambda #{lm.call(3)}"

in_proc = begin
  proc { break 5 }.call
rescue LocalJumpError => e
  "#{e.class}: #{e.message}"
end
row 8, "break in a lambda; in a proc via call; via yield:", "#{-> { break 5; :unreached }.call}; #{in_proc}; #{run_block { break 8 }}, #{call_proc { break 9 }}"

puts " 9. ensure still runs on the way out:"
puts "    with_ensure { break :out } = #{with_ensure { break :out }.inspect}"

x = while true do break 3 end
row 10, "while breaks with a value too:", "x = while true do break 3 end -> #{x}"
