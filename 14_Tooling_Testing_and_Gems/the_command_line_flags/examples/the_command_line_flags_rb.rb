# Every flag below is exercised by starting a child Ruby (RbConfig.ruby) and
# printing what it wrote and how it exited. Nothing here is typed by hand.
require "open3"
require "tmpdir"

RUBY = RbConfig.ruby

def quote(arg)
  return arg unless arg.match?(/[\s"'|$#{'{'}]/)
  arg.include?("'") ? "\"#{arg}\"" : "'#{arg}'"
end

def show(n, *args, stdin: nil, dir: nil, stderr: :all)
  out, err, status = Open3.capture3(RUBY, *args, stdin_data: stdin)
  shown = args.map { quote(it) }.join(" ")
  shown = shown.gsub(dir, "DIR") if dir
  puts format("%2d. ruby %s", n, shown)
  puts "    stdin:  #{stdin.inspect}" if stdin
  out = out.gsub(dir, "DIR") if dir
  err = err.gsub(dir, "DIR") if dir
  err = err.gsub(RUBY, "ruby")   # the child's own path prefixes some messages
  puts "    stdout: #{out.lines.map(&:chomp).join(" | ")}" unless out.empty?
  err = err.lines.first.chomp + "   (first line only)" if stderr == :first && !err.empty?
  puts "    stderr: #{err.lines.map(&:chomp).join(" | ")}" unless err.empty?
  puts "    exit:   #{status.exitstatus}"
  [out, err, status.exitstatus]
end

Dir.mktmpdir do |dir|
  ok     = File.join(dir, "ok.rb");     File.write(ok, "x = 1\nputs x\n")
  bad    = File.join(dir, "bad.rb");    File.write(bad, "def f(\n")
  unused = File.join(dir, "unused.rb"); File.write(unused, "def f\n  x = 1\n  2\nend\n")
  lib    = File.join(dir, "lib");       Dir.mkdir(lib)
  File.write(File.join(lib, "helper2.rb"), "puts 'helper2 here'\n")

  show 1, "-e", "puts 1 + 1"
  show 2, "-c", ok, dir: dir
  show 2, "-c", bad, dir: dir, stderr: :first
  show 3, "-w", unused, dir: dir
  show 4, "-W:deprecated", "-e", "p Warning[:deprecated]"
  show 4, "-W:no-deprecated", "-e", "p Warning[:deprecated]"
  show 4, "-W0", "-e", "p $VERBOSE"
  show 4, "-w", "-e", "p $VERBOSE"
  show 5, "-r", "json", "-e", 'puts JSON.generate([1, {a: 2}])'
  show 6, "-I", lib, "-e", 'require "helper2"', dir: dir
  show 7, "-n", "-e", "puts $_.upcase", stdin: "ab\ncd\n"
  show 7, "-p", "-e", "$_.upcase!", stdin: "ab\ncd\n"
  show 7, "-a", "-n", "-e", "puts $F[1]", stdin: "a b c\nd e f\n"
  show 7, "-n", "-e", "puts $_ + '!'", stdin: "ab\ncd\n"
  show 7, "-l", "-n", "-e", "puts $_ + '!'", stdin: "ab\ncd\n"
  show 8, "-E", "UTF-8", "-e", "p Encoding.default_external"
  show 8, "-E", "ASCII-8BIT", "-e", "p Encoding.default_external"
  show 9, "--yjit", "-e", "p RubyVM::YJIT.enabled?"
  show 9, "-e", "p RubyVM::YJIT.enabled?"
  show 10, "--disable-gems", "-e", "p defined?(Gem)"
  show 10, "-e", "p defined?(Gem)"
  show 11, "--enable=frozen-string-literal", "-e", "p 'a'.frozen?"
  show 11, "-e", "p 'a'.frozen?"
  out, = Open3.capture3(RUBY, "--dump=insns", "-e", "a = 1 + 2; puts a * 3")
  puts "12. ruby --dump=insns -e 'a = 1 + 2; puts a * 3'"
  puts "    instructions: #{out.scan(/^\d{4} (\w+)/).flatten.join(" ")}"
  out, = Open3.capture3(RUBY, "-v")
  puts "13. ruby -v   -> starts with 'ruby 4.': #{out.start_with?("ruby 4.")}"
  out, = Open3.capture3(RUBY, "-h")
  puts "13. ruby -h   -> first line starts with 'Usage:': #{out.lines.first.start_with?("Usage:")}"
  show 14, "-e", "p ARGV", "--", "-x", "y"
  show 15, "-s", "-e", "p $flag", "--", "-flag=5"
end
