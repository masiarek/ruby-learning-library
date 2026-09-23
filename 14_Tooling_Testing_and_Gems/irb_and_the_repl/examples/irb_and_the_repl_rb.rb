# irb reads a line, evaluates it, and prints the value -- including the values
# a script would throw away. A child irb is driven through a pipe, with the
# flags that make its output nothing but those values.
require "open3"

FLAGS = %w[-f --noprompt --nocolorize --noverbose --no-pager].freeze

def irb_session(input, *extra)
  Open3.capture3(RbConfig.ruby, "-e", 'require "irb"; IRB.start', "--", *FLAGS, *extra, stdin_data: input)
end

def transcript(n, title, input, *extra)
  out, err, status = irb_session(input, *extra)
  puts "#{n}. #{title}"
  input.each_line { |line| puts "   in:  #{line}" }
  out.each_line { |line| puts "   out: #{line}" }
  puts "   stderr empty: #{err.empty?}   exit: #{status.exitstatus}"
end

transcript 1, "every expression's value is echoed, one per line:",
           "1 + 1\nx = 2\nx * 3\n_\n[1, 2].map { it * 2 }\nputs \"side effect\"\nnil\ndef f(x) = x * 2\nf(21)\n"
transcript 2, "an error is printed and the session goes on:",
           "1 / 0\n\"after\"\n"
transcript 3, "--noecho keeps only what the code prints itself:",
           "1 + 1\nputs \"side effect\"\n", "--noecho"
transcript 4, "exit ends the session; later lines are never read:",
           "puts \"before\"\nexit\nputs \"never\"\n"
