# ARGV, $0, ENV and the exit status, measured from the outside: this program
# writes three small scripts into a temporary directory and runs each one as a
# child Ruby (RbConfig.ruby), printing what the child printed and how it exited.
require "rbconfig"
require "open3"
require "tmpdir"

RUBY = RbConfig.ruby

def row(n, text, value = "")
  puts format("%2d. %-50s %s", n, text, value)
end

def run(*args, env: {}, stdin: "")
  out, err, status = Open3.capture3(env, RUBY, *args, stdin_data: stdin)
  [out.lines(chomp: true), err.lines(chomp: true), status]
end

CHILD = <<~'RB'
  def helper = "helper from child.rb"
  puts "__FILE__=#{File.basename(__FILE__)} $0=#{$0} $PROGRAM_NAME=#{$PROGRAM_NAME} main?=#{__FILE__ == $0}"
  if __FILE__ == $0
    puts "ARGV=#{ARGV.inspect} classes=#{ARGV.map(&:class).inspect}"
    puts "ENV[\"DEMO_X\"]=#{ENV["DEMO_X"].inspect} ENV[\"DEMO_MISSING\"]=#{ENV["DEMO_MISSING"].inspect}"
    puts "fetch with defaults: #{ENV.fetch("DEMO_X", "d").inspect} #{ENV.fetch("DEMO_MISSING", "d").inspect}"
    begin
      ENV.fetch("DEMO_MISSING")
    rescue KeyError => e
      puts "#{e.class}: #{e.message}"
    end
    begin
      ENV["N"] = 1
    rescue TypeError => e
      puts "#{e.class}: #{e.message}"
    end
    puts "ENV.class=#{ENV.class} is_a?(Hash)=#{ENV.is_a?(Hash)} to_h.class=#{ENV.to_h.class} each?=#{ENV.respond_to?(:each)}"
    exit 2
  end
RB

MAIN = <<~'RB'
  require_relative "child"
  puts helper
  puts "in main.rb: $0=#{$0}"
RB

OPTS = <<~'RB'
  require "optparse"
  options = {count: 1, verbose: false}
  parser = OptionParser.new do |o|
    o.banner = "Usage: opts.rb [options] FILE"
    o.on("-n", "--count N", Integer, "How many times") { |n| options[:count] = n }
    o.on("-v", "--verbose", "Say more") { options[:verbose] = true }
  end
  begin
    parser.parse!(ARGV)
  rescue OptionParser::ParseError => e
    puts "#{e.class}: #{e.message}"
    exit 1
  end
  puts "options=#{options.inspect} ARGV=#{ARGV.inspect}"
RB

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("child.rb", CHILD)
    File.write("main.rb", MAIN)
    File.write("opts.rb", OPTS)

    out, _, status = run("child.rb", "1", "two", env: {"DEMO_X" => "1"})
    row 1, "ruby child.rb 1 two -- ARGV holds Strings", out[1]
    row 2, "  $0 is the script as invoked; __FILE__ == $0", out[0]
    row 3, "  ENV[] gives a String or nil", out[2]
    row 4, "  ENV.fetch with a default", out[3]
    row 5, "  ENV.fetch without one", out[4]
    row 6, "  ENV values must be Strings", out[5]
    row 7, "  ENV is not a Hash, but it is Enumerable", out[6]
    row 8, "  the child ran exit 2: $?.exitstatus, success?", "#{status.exitstatus}, #{status.success?}"
    row 9, "  the status object's class", status.class

    out, _, status = run("main.rb")
    row 10, "ruby main.rb, which require_relatives child.rb", out[0]
    row 11, "  the helper is defined, the guarded part did not run", "#{out[1]}; #{out[2]}; exit=#{status.exitstatus}"

    _, _, status = run("-e", "exit")
    row 12, "exit with no argument", status.exitstatus
    _, _, status = run("-e", "exit true")
    row 13, "exit true", status.exitstatus
    _, _, status = run("-e", "exit false")
    row 14, "exit false", status.exitstatus
    _, err, status = run("-e", 'abort "bye"')
    row 15, "abort \"bye\": status, and stderr", "#{status.exitstatus}, #{err.inspect}"
    _, _, status = run("-e", "raise 'boom'")
    row 16, "an uncaught exception", status.exitstatus

    out, _, status = run("opts.rb", "-n", "3", "--verbose", "in.txt")
    row 17, "OptionParser: -n 3 --verbose in.txt", "#{out[0]} exit=#{status.exitstatus}"
    out, _, status = run("opts.rb", "--nope")
    row 18, "  an unknown option", "#{out[0]} exit=#{status.exitstatus}"
    out, _, status = run("opts.rb", "-n", "x")
    row 19, "  a non-Integer for -n", "#{out[0]} exit=#{status.exitstatus}"
    out, _, status = run("opts.rb", "-h")
    row 20, "  -h prints the generated help and exits", status.exitstatus
    out.each { |line| puts "      #{line}" }
  end
end
