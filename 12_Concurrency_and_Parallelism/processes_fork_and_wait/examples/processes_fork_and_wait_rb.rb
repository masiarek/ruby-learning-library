# fork copies the process; wait collects its status.
#
# Every child is waited for before the next row prints, so the rows come out
# in program order; a child that prints does so once, because Ruby flushes
# $stdout before forking. No pid is printed -- only whether one was returned.
def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1. fork with a block: the child runs the block and exits
pid = fork { exit 3 }
Process.wait(pid)
row 1, "fork { exit 3 }; Process.wait; exitstatus / success?", "#{$?.exitstatus} / #{$?.success?}"

# 2-3. fork without a block returns twice: nil in the child, the pid in the parent
child = fork
if child.nil?
  row 2, "fork returned nil: this row is printed by the child", "child"
  exit 0
end
Process.wait(child)
row 3, "fork returned an Integer: printed by the parent", "parent (pid > 0: #{child.positive?})"

# 4. The child gets a copy of every object; it reports through a pipe
counter = 0
reader, writer = IO.pipe
kid = fork do
  reader.close
  counter += 1
  writer.puts counter
  writer.close
end
writer.close
report = reader.read.chomp
reader.close
Process.wait(kid)
row 4, "child did counter += 1 and wrote it / parent's counter", "#{report} / #{counter}"

# 5. Process.wait2 returns the pid and the status together
_pid, status = Process.wait2(fork { exit 7 })
row 5, "Process.wait2(fork { exit 7 }) -> [pid, status]", "#{status.class}, exitstatus #{status.exitstatus}"

# 6. spawn starts another program; wait collects it the same way
Process.wait(spawn(RbConfig.ruby, "-e", "exit 5"))
row 6, "spawn(ruby, \"-e\", \"exit 5\") + Process.wait", "$?.exitstatus #{$?.exitstatus}"

# 7. system returns true, false or nil
ok = system(RbConfig.ruby, "-e", "exit 0")
failed = system(RbConfig.ruby, "-e", "exit 2")
missing = system("no_such_command_xyz_123")
row 7, "system: exit 0 / exit 2 / a missing command", "#{ok.inspect} / #{failed.inspect} / #{missing.inspect} ($?.exitstatus #{$?.exitstatus})"

# 8. Backticks capture the child's stdout
out = `#{RbConfig.ruby} -e 'print 40 + 2'`
row 8, "backticks capture the child's stdout; $?.success?", "#{out.inspect} / #{$?.success?}"

# 9. A child killed by a signal has no exit status
sleeper = fork { sleep 5 }
Process.kill("TERM", sleeper)
Process.wait(sleeper)
row 9, "killed by TERM: exitstatus / signaled? / termsig", "#{$?.exitstatus.inspect} / #{$?.signaled?} / #{Signal.signame($?.termsig)}"

# 10. Nothing left to wait for
begin
  Process.wait
rescue Errno::ECHILD => e
  row 10, "Process.wait with no children left", e.class
end
