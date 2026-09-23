# warnings_and_dash_w_rb.rb -- warn goes to stderr; uplevel:; Warning[:deprecated] and
# -W:deprecated; $VERBOSE under -w and -W0; Warning.categories; what -w reports on a
# sloppy file; capturing warnings in-process; the chilled-literal warning.
# Children start with RbConfig.ruby; file paths in their stderr are cut to the base name.

require "open3"
require "rbconfig"
require "tmpdir"

def child(label, *flags, code: nil, file: nil)
  argv = [RbConfig.ruby, "--disable-gems", *flags]
  argv += code ? ["-e", code] : [file]
  out, err, status = Open3.capture3(*argv)
  puts "   #{label}"
  out.each_line { |line| puts "      stdout: #{line.chomp}" }
  err.each_line { |line| puts "      stderr: #{line.chomp.sub(%r{\A\S*/}, '')}" }
  puts "      exit status: #{status.exitstatus}"
end

puts "1. warn writes to stderr, not stdout"
child('warn "careful"; puts "out"', code: 'warn "careful"; puts "out"')

puts "2. uplevel: adds the file, the line and the word warning"
child('warn "old api", uplevel: 0', code: 'warn "old api", uplevel: 0')

puts "3. Warning[:deprecated] is off by default; -W:deprecated turns it on"
code = 'warn "old", category: :deprecated; puts "Warning[:deprecated] = #{Warning[:deprecated]}"'
child("ruby -e '...'", code: code)
child("ruby -W:deprecated -e '...'", "-W:deprecated", code: code)

puts "4. $VERBOSE is false by default, true under -w, nil under -W0 (which silences warn)"
child("ruby -e 'p $VERBOSE; warn \"shown?\"'", code: 'p $VERBOSE; warn "shown?"')
child("ruby -w -e '...'", "-w", code: 'p $VERBOSE; warn "shown?"')
child("ruby -W0 -e '...'", "-W0", code: 'p $VERBOSE; warn "shown?"')

puts "5. the warning categories and their defaults"
puts "   Warning.categories #{Warning.categories.inspect}"
Warning.categories.each { |c| puts "   #{"Warning[:#{c}]".ljust(32)} #{Warning[c]}" }

puts "6. what -w reports on a sloppy file, and -c, the syntax check"
SLOPPY = <<~RUBY
  def greet
    unused = 1
    puts "hi"
  end

  def greet
    puts "hi again"
  end

  if 1
    puts "literal condition"
  end

  def indented
    x = 1
      end

  greet
  indented
RUBY
Dir.mktmpdir do |dir|
  path = File.join(dir, "sloppy.rb")
  File.write(path, SLOPPY)
  child("ruby sloppy.rb", file: path)
  child("ruby -w sloppy.rb", "-w", file: path)
  child("ruby -c sloppy.rb", "-c", file: path)
end

puts "7. capturing warnings in-process by prepending to Warning"
captured = []
Warning.singleton_class.prepend(Module.new do
  define_method(:warn) { |message, category: nil, **| captured << [message.chomp, category] }
end)
warn "captured one"
warn "captured two", category: :deprecated
Warning[:deprecated] = true
warn "captured three", category: :deprecated
puts "   captured #{captured.inspect}"
puts "   (the second never reached Warning.warn: its category was off at the time)"

puts "8. mutating a string literal warns only under -W:deprecated (literals are chilled)"
child("ruby -e 's = \"lit\"; s << \"x\"; puts s'", code: 's = "lit"; s << "x"; puts s')
child("ruby -W:deprecated -e '...'", "-W:deprecated", code: 's = "lit"; s << "x"; puts s')
