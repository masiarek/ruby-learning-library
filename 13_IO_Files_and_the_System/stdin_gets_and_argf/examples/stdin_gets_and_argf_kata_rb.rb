# Kata: a `cat -n` in one line -- number every input line with ARGF.each_line,
# so the same program works on the files named in ARGV and on standard input.
# The parent runs it both ways as a child Ruby.
require "rbconfig"
require "open3"
require "tmpdir"

NUMBER = 'ARGF.each_line { |line| printf("%6d\t%s", ARGF.lineno, line) }'

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("poem.txt", "roses are red\nviolets are blue\n")
    out, = Open3.capture2(RbConfig.ruby, "-e", NUMBER, "poem.txt")
    puts "from a file named in ARGV:"
    puts out
    out, = Open3.capture2(RbConfig.ruby, "-e", NUMBER, stdin_data: "one\ntwo\nthree\n")
    puts "from standard input:"
    puts out
  end
end
