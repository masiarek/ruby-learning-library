# Kata: three style problems, reported by `ruby -w`, then fixed and re-run.
require "open3"
require "rbconfig"
require "tmpdir"

BAD = <<~RUBY
  def greetUser(name)
    unused = 1
    if name
      puts "hello, \#{name}"
      end
  end
  greetUser("ann")
RUBY

GOOD = <<~RUBY
  def greet_user(name)
    return unless name
    puts "hello, \#{name}"
  end
  greet_user("ann")
RUBY

def report(label, source)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      File.write("#{label}.rb", source)
      out, err, _status = Open3.capture3(RbConfig.ruby, "-w", "#{label}.rb")
      puts "#{label}.rb under ruby -w:"
      puts "  stdout: #{out.chomp.inspect}"
      warnings = err.lines.map(&:chomp)
      puts warnings.empty? ? "  no warnings" : warnings.map { |w| "  #{w}" }
    end
  end
end

report("before", BAD)
puts "  (greetUser is legal Ruby: the camelCase method name draws no warning; only a style tool would object)"
report("after", GOOD)
