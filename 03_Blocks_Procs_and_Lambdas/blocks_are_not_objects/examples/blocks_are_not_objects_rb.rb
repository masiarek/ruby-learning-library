# A block is syntax that rides on one method call: it is not a value, it has
# no class, and it cannot be assigned. `yield` runs it, `block_given?` asks
# whether one came, and `&block` is the one door through which it becomes an
# object (a Proc). Each numbered row is one measured claim; the Python twin
# prints the same rows.

W = 46
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def apply
  yield 21                      # hands 21 to the block, evaluates to the block's value
end

def report
  "block_given? #{block_given?}"
end

def bare
  yield                         # no block came: LocalJumpError
end

def reify(&block)               # &block: the block arrives as a Proc object
  block
end

def inner
  yield 5
end

def outer(&blk)
  inner(&blk)                   # &blk passes the same block on to inner
end

def show(arg)
  "show received #{arg.inspect}, block_given? #{block_given?}"
end

def bracket
  puts "    before"
  value = yield
  puts "    after"
  value
end

def both(&b)
  b
end

row 1, "yield hands 21 to the block and takes its value:", apply { |x| x * 2 }
row 2, "block_given? without a block / with one:", "#{report} / #{report { }}"

begin
  bare
rescue LocalJumpError => e
  row 3, "yield with no block:", "#{e.class}: #{e.message}"
end

begin
  RubyVM::InstructionSequence.compile("x = { |a| a }")
  row 4, "a block on its own, x = { |a| a }:", "compiled (unexpected)"
rescue SyntaxError => e
  row 4, "a block on its own, x = { |a| a }:", "#{e.class} - a block is not an expression"
end

begin
  RubyVM::InstructionSequence.compile("both(&b) { }")
  row 5, "two blocks on one call, both(&b) { }:", "compiled (unexpected)"
rescue SyntaxError => e
  row 5, "two blocks on one call, both(&b) { }:", "#{e.class} - one block per call"
end

block = reify { |x| x + 1 }
row 6, "&block reifies it:", "#{block.class}, lambda? #{block.lambda?}, block.call(1) = #{block.call(1)}; no block: #{reify.inspect}"
row 7, "passing it on with &blk:", outer { |v| v * 10 }
with_do = show [1, 2].map do |x| x * 2 end     # do...end binds to show
with_braces = show [1, 2].map { |x| x * 2 }     # { } binds to map
row 8, "do...end binds to show, not to map:", with_do
row 9, "{ } binds to map:", with_braces

puts "10. a block wraps before/after around its body:"
value = bracket { puts "    inside"; :done }
puts "    bracket returned #{value.inspect}"
