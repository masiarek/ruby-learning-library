# Minitest is a bundled gem: plain classes, plain assertions, a spec DSL. The run
# happens in-process here with a fixed seed, and the timing lines are dropped.
require "minitest"
require "minitest/spec"
require "stringio"

class Calc
  def add(a, b) = a + b
  def div(a, b) = a / b
end

class TestCalc < Minitest::Test
  def setup
    @calc = Calc.new
  end

  def test_add
    assert_equal 4, @calc.add(2, 2)
    assert_in_delta 0.3, @calc.add(0.1, 0.2), 1e-9
  end

  def test_div_by_zero
    error = assert_raises(ZeroDivisionError) { @calc.div(1, 0) }
    assert_equal "divided by 0", error.message
  end

  def test_deliberate_failure
    assert_equal({ name: "a", n: 1 }, { name: "b", n: 1 })
  end

  def test_skipped
    skip "not today"
  end

  def test_double_by_hand
    fake = Object.new
    def fake.add(a, b) = 42
    assert_equal 42, fake.add(1, 2)
  end
end

describe Calc do
  it "adds, in spec style" do
    _(Calc.new.add(1, 1)).must_equal 2
  end
end

puts "1. the report of Minitest.run([\"--seed\", \"1\"]), timing lines removed:"
buffer = StringIO.new
real_stdout = $stdout
$stdout = buffer
passed = Minitest.run(["--seed", "1"])
$stdout = real_stdout
buffer.string.each_line do |line|
  next if line.match?(/Finished in|runs\/s/)
  line = line.gsub(/\[[^\]]*:\d+\]/, "[FILE:LINE]")
  print(line.strip.empty? ? "\n" : "   #{line}")
end
puts "2. Minitest.run returned #{passed} (false because one test failed)"

begin
  require "minitest/mock"
  puts "3. require \"minitest/mock\": loaded"
rescue LoadError => e
  puts "3. require \"minitest/mock\": #{e.class} -- not bundled with Minitest #{Minitest::VERSION.split(".").first}"
end
