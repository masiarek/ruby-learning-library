# Ruby comments: `#` to the end of the line, `=begin`/`=end` blocks at column 0,
# magic comments the parser reads, and `__END__`, after which the file is data
# that the program reads back through DATA. The Python twin asks the same nine.
require "open3"
require "rbconfig"
require "tmpdir"

def row(n, label, value)
  puts format("%2d. %-46s %s", n, label, value)
end

def run_child(*args)
  out, err, status = Open3.capture3(RbConfig.ruby, *args)
  [out.chomp, err.chomp, status.exitstatus]
end

x = 1 # a trailing comment; the assignment before it ran
row 1, "x = 1 # trailing comment", "x = #{x}"

=begin
x = 2
puts "this line is inside =begin/=end and never runs"
=end
row 2, "=begin ... =end around x = 2", "x = #{x}  (still 1: the block did not run)"

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("indented.rb", "x = 1\n  =begin\n  x = 2\n  =end\nputs x\n")
    _out, err, status = run_child("indented.rb")
    first = err.lines.grep(/SyntaxError|syntax error/).first.to_s.strip.sub(/\A.*?:\d+: /, "")
    row 3, "an indented =begin (not at column 0)", "exit #{status}, #{first.empty? ? 'no error' : first}"

    File.write("frozen.rb", "# frozen_string_literal: true\nputs 'lit'.frozen?\n")
    File.write("plain.rb", "puts 'lit'.frozen?\n")
    row 4, "# frozen_string_literal: true / no comment", "#{run_child("frozen.rb")[0]} / #{run_child("plain.rb")[0]}"

    # The literal holds the single byte 0xE9, which is one character in ISO-8859-1.
    File.binwrite("latin.rb", "# encoding: iso-8859-1\ns = 'caf\xE9'\nputs __ENCODING__, s.length, s.bytesize\n".b)
    row 5, "# encoding: iso-8859-1, then 'caf' + byte E9", run_child("latin.rb")[0].split("\n").join(" / ") + "  (__ENCODING__ / length / bytesize)"

    File.write("shebang.rb", "#!/usr/bin/env ruby\nputs 'the shebang line is a comment'\n")
    $shebang_row = run_child("shebang.rb")[0]
  end
end

row 6, "__END__ then DATA.read", DATA.read.inspect
row 7, "#!/usr/bin/env ruby as line 1", $shebang_row

def documented(a) = a
# The comment above is where Ruby keeps its documentation: RDoc and YARD read
# it from the source; the running program cannot ask the method for it.
row 8, "method(:documented).respond_to?(:__doc__)", method(:documented).respond_to?(:__doc__).to_s

# @param value [Integer] the value to double   <- YARD syntax, still a comment
def double(value) = value * 2
row 9, "# @param line above def double; double(4)", "#{double(4)}  (a YARD tag is an ordinary comment)"

__END__
line one
line two
