# Exercise 1: two child scripts that differ in one character, exit 2 versus exit! 2,
# and what each does to an at_exit handler, to a bare rescue, and to the status the
# parent sees.

require "open3"
require "rbconfig"

def run(code)
  out, err, status = Open3.capture3(RbConfig.ruby, "--disable-gems", "-e", code)
  puts "   stdout #{out.chomp.inspect}, stderr #{err.chomp.inspect}, status #{status.exitstatus}"
end

puts "1. exit 2 inside begin/rescue => e: the handler runs, the rescue is skipped, status 2"
run('at_exit { puts "cleanup" }; begin; exit 2; rescue => e; puts "rescued #{e.class}"; end; puts "after"')

puts "2. exit! 2: the handler is skipped too, and the status is still 2"
run('at_exit { puts "cleanup" }; begin; exit! 2; rescue => e; puts "rescued #{e.class}"; end; puts "after"')
