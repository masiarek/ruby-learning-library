# Six ways to run another program, and what each gives back. Child Rubies are
# started through RbConfig.ruby; `echo` is the one shell command used, because
# it exists everywhere and its output is fixed.
require "rbconfig"
require "open3"
require "tmpdir"

RUBY = RbConfig.ruby

def row(n, text, value = "")
  puts format("%2d. %-54s %s", n, text, value)
end

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("a.txt", "")
    File.write("b.txt", "")

    ok = system(RUBY, "-e", "exit 0")
    row 1, "system(ruby, \"-e\", \"exit 0\") returns; $?.exitstatus", "#{ok.inspect}; #{$?.exitstatus}"
    ok = system(RUBY, "-e", "exit 2")
    row 2, "system(ruby, \"-e\", \"exit 2\") returns; $?.exitstatus", "#{ok.inspect}; #{$?.exitstatus}"
    ok = system("definitely_not_a_command_xyz")
    row 3, "system(\"definitely_not_a_command_xyz\"); $?.exitstatus", "#{ok.inspect}; #{$?.exitstatus}"

    out = `echo hello`
    row 4, "`echo hello` returns stdout; $?.success?", "#{out.inspect}; #{$?.success?}"
    row 5, "%x(echo hi there) is the same thing", %x(echo hi there).inspect
    row 6, "one String goes through /bin/sh: `echo *` expands", `echo *`.inspect
    out, = Open3.capture2("echo", "*")
    row 7, "an argv form skips the shell: capture2(\"echo\", \"*\")", out.inspect

    pid = spawn(RUBY, "-e", "exit 4")
    Process.wait(pid)
    row 8, "spawn returns a pid; after Process.wait, $?.exitstatus", "#{pid.class}; #{$?.exitstatus}"
    pid, status = Process.wait2(spawn(RUBY, "-e", "exit 5"))
    row 9, "Process.wait2 returns [pid, status]", "pid matches: #{pid == status.pid}; #{status.exitstatus}"

    o, e, st = Open3.capture3(RUBY, "-e", "puts 'out'; warn 'err'; exit 3")
    row 10, "Open3.capture3: stdout, stderr, status.exitstatus", "#{o.inspect}, #{e.inspect}, #{st.exitstatus}"
    oe, = Open3.capture2e(RUBY, "-e", "puts 'out'; warn 'err'")
    row 11, "capture2e merges; a piped stdout is buffered, so", oe.inspect
    oe, = Open3.capture2e(RUBY, "-e", "$stdout.sync = true; puts 'out'; warn 'err'")
    row 12, "  with $stdout.sync = true in the child", oe.inspect

    lines = IO.popen([RUBY, "-e", "puts 1; puts 2"]) { |io| io.readlines }
    row 13, "IO.popen([argv]) { |io| io.readlines }", lines.inspect
    up = IO.popen([RUBY, "-e", "puts $stdin.read.upcase"], "r+") { |io| io.write("abc"); io.close_write; io.read }
    row 14, "IO.popen(argv, \"r+\"): write, close_write, read", up.inspect
    out, = Open3.capture2(RUBY, "-e", "p $stdin.read", stdin_data: "fed")
    row 15, "capture2 with stdin_data: feeds the child", out.inspect
    out, = Open3.capture2({"GREETING" => "hi"}, RUBY, "-e", "puts ENV['GREETING']")
    row 16, "a leading Hash adds to the child's environment", out.inspect

    out, = Open3.capture2(RUBY, "-e", "exec('echo', 'replaced'); puts 'never'")
    row 17, "exec replaces the process: nothing after it runs", out.inspect
    begin
      system(RUBY, "-e", "exit 2", exception: true)
    rescue RuntimeError => e
      row 18, "system(..., exception: true) raises on failure", e.class
    end
    row 19, "$? is Process.last_status; its class", "#{Process.last_status.equal?($?)}; #{$?.class}"
  end
end
