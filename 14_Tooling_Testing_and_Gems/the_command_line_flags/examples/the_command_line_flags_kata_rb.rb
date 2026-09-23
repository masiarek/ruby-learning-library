# Kata: four one-liners over the same two lines of input, each run as a child
# Ruby, each printing the command and what it produced.
require "open3"

INPUT = "alice 30\nbob 25\n"

def one_liner(flags, code)
  out, = Open3.capture3(RbConfig.ruby, *flags, "-e", code, stdin_data: INPUT)
  puts "ruby #{flags.join(" ")} -e '#{code}'"
  out.each_line { |line| puts "    #{line}" }
end

one_liner %w[-a -n], "puts $F[1]"
one_liner %w[-p],    "$_.upcase!"
one_liner %w[-l -n], 'puts $_ + "!"'
one_liner %w[-a -n], "BEGIN { $sum = 0 }; $sum += $F[1].to_i; END { puts $sum }"
