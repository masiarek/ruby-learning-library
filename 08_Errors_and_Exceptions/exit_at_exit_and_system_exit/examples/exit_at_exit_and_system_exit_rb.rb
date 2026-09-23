# exit_at_exit_and_system_exit_rb.rb -- exit raises SystemExit; exit codes; at_exit
# handlers run in reverse; exit! skips them; abort; an uncaught exception's status;
# Interrupt is a SignalException. Every row starts a child Ruby with RbConfig.ruby
# and prints the child's stdout, stderr and exit status.

require "open3"
require "rbconfig"

at_exit { puts "9. this program's own at_exit handler prints last" }

def child(label, code, mask_frames: false)
  out, err, status = Open3.capture3(RbConfig.ruby, "--disable-gems", "-e", code)
  puts "   #{label}"
  out.each_line { |line| puts "      stdout: #{line.chomp}" }
  err.each_line do |line|
    line = line.chomp
    line = line.sub(/in '[^']+'/, "in '...'") if mask_frames
    puts "      stderr: #{line}"
  end
  how = status.signaled? ? "killed by signal #{status.termsig}" : "exit status #{status.exitstatus}"
  puts "      #{how}"
end

puts "1. exit raises SystemExit, which a handler can rescue"
child('begin; exit; rescue SystemExit => e; ...; end; puts "still running"',
      'begin; exit; rescue SystemExit => e; puts "rescued #{e.class}: status #{e.status}, success? #{e.success?}"; end; puts "still running"')

puts "2. a bare rescue does not see it"
child('begin; exit 3; rescue => e; puts "caught"; end; puts "after"',
      'begin; exit 3; rescue => e; puts "caught"; end; puts "after"')

puts "3. the exit status: an Integer, or true for 0 and false for 1"
child("exit 3", "exit 3")
child("exit true", "exit true")
child("exit false", "exit false")

puts "4. at_exit handlers run in reverse order of registration"
child('three at_exit blocks, then puts "main done"',
      'at_exit { puts "first registered" }; at_exit { puts "second registered" }; at_exit { puts "third registered" }; puts "main done"')

puts "5. exit! skips them"
child('at_exit { puts "at_exit ran" }; exit! 4', 'at_exit { puts "at_exit ran" }; exit! 4')

puts "6. abort writes its message to stderr, runs at_exit, and exits 1"
child('at_exit { puts "at_exit ran" }; abort("fatal: giving up")', 'at_exit { puts "at_exit ran" }; abort("fatal: giving up")')

puts "7. an uncaught exception reports on stderr and exits 1; at_exit still runs, and sees it in $!"
child('at_exit { puts "at_exit sees $!: ..." }; puts "before"; raise "boom"',
      'at_exit { puts "at_exit sees $!: #{$!.class}" }; puts "before"; raise "boom"; puts "never"')

puts "8. Interrupt is a SignalException; an unrescued one ends the process by the signal"
child("raise Interrupt, rescued as SignalException",
      'begin; raise Interrupt; rescue SignalException => e; puts "#{e.class} < #{e.class.superclass}, signo #{e.signo}"; end')
child('a real SIGINT, not rescued: Process.kill("INT", Process.pid); sleep 5',
      'Process.kill("INT", Process.pid); sleep 5; puts "never"', mask_frames: true)
child("a real SIGINT, rescued as Interrupt",
      'begin; Process.kill("INT", Process.pid); sleep 5; rescue Interrupt => e; puts "rescued #{e.class}"; end')
