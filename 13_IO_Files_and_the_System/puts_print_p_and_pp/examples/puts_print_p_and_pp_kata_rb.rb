# Kata: reimplement puts on top of $stdout.write -- flatten arrays, one item per
# line, nil becomes an empty line, and a string that already ends in a newline
# gets no second one -- then check it against the real puts on several inputs.
require "stringio"

def my_puts(*args)
  args = [""] if args.empty?
  args.flatten.each do |item|
    text = item.nil? ? "" : item.to_s
    text += "\n" unless text.end_with?("\n")
    $stdout.write(text)
  end
  nil
end

def capture
  saved, $stdout = $stdout, StringIO.new
  yield
  $stdout.string
ensure
  $stdout = saved
end

inputs = [["a"], ["a\n"], [1, 2], [[1, [2, 3]]], [nil], [[]], [], [:sym, 1.5]]
inputs.each do |args|
  mine = capture { my_puts(*args) }
  real = capture { puts(*args) }
  puts format("%-16s mine=%-16s real=%-16s same=%s", args.inspect, mine.inspect, real.inspect, mine == real)
end
