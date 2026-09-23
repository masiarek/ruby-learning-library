# Kata: a greeting script with an OptionParser flag and a meaningful exit
# status, run three ways as a child Ruby; the parent prints each run's output
# and status.
require "rbconfig"
require "open3"
require "tmpdir"

SCRIPT = <<~'RB'
  require "optparse"
  greeting = "Hello"
  OptionParser.new { |o| o.on("-g", "--greeting WORD") { |w| greeting = w } }.parse!(ARGV)
  ARGV.each { |name| puts "#{greeting}, #{name}!" }
  exit(ARGV.empty? ? 2 : 0)
RB

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("greet.rb", SCRIPT)
    [
      ["greet.rb", "Ada", "Alan"],
      ["greet.rb", "--greeting", "Hi", "Grace"],
      ["greet.rb"],
    ].each do |args|
      out, status = Open3.capture2(RbConfig.ruby, *args)
      puts "ruby #{args.join(" ")}"
      out.each_line { |line| puts "  #{line}" }
      puts "  exit status: #{status.exitstatus}"
    end
  end
end
