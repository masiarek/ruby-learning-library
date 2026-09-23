# Kata: test a Stack with Minitest -- push, pop, empty?, and the error on an
# empty pop -- run with a fixed seed and the timing lines removed.
require "minitest"
require "stringio"

class Stack
  class Empty < StandardError; end

  def initialize = @items = []
  def push(x) = (@items.push(x); self)
  def pop = @items.empty? ? raise(Empty, "stack is empty") : @items.pop
  def empty? = @items.empty?
  def size = @items.size
end

class TestStack < Minitest::Test
  def setup
    @stack = Stack.new
  end

  def test_starts_empty
    assert_empty @stack.instance_variable_get(:@items)
    assert_predicate @stack, :empty?
  end

  def test_push_then_pop_is_lifo
    @stack.push(1).push(2)
    assert_equal 2, @stack.pop
    assert_equal 1, @stack.pop
    assert @stack.empty?
  end

  def test_pop_on_empty_raises
    error = assert_raises(Stack::Empty) { @stack.pop }
    assert_equal "stack is empty", error.message
  end
end

buffer = StringIO.new
$stdout = buffer
passed = Minitest.run(["--seed", "1"])
$stdout = STDOUT
buffer.string.each_line do |line|
  print line unless line.match?(/Finished in|runs\/s/)
end
puts "passed: #{passed}"
