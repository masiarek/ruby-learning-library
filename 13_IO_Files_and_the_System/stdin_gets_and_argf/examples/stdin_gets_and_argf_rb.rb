# gets, $stdin and ARGF, measured through child Rubies whose standard input is
# fed by Open3.capture3(stdin_data:). Two small files in a temporary directory
# stand in for the names a user would put on the command line.
require "rbconfig"
require "open3"
require "tmpdir"

RUBY = RbConfig.ruby

def row(n, text, value = "")
  puts format("%2d. %-56s %s", n, text, value)
end

def child(code, *args, stdin: "")
  out, _err, _status = Open3.capture3(RUBY, "-e", code, *args, stdin_data: stdin)
  out.chomp
end

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("a.txt", "a1\na2\n")
    File.write("b.txt", "b1\n")

    row 1, "gets returns the next line, newline included", child("p gets", stdin: "first\nsecond\n")
    row 2, "gets three times on two lines: nil at EOF", child("p [gets, gets, gets]", stdin: "first\nsecond\n")
    row 3, "so gets.chomp on an empty input raises", child('begin; gets.chomp; rescue NoMethodError => e; puts "#{e.class}: #{e.message}"; end')
    row 4, "  gets&.chomp and gets.to_s.chomp are the safe spellings", child("p [gets&.chomp, gets.to_s.chomp]")
    row 5, "while (line = gets) is the read loop", child("while (line = gets); print line.upcase; end", stdin: "x\ny\n").inspect
    row 6, "$stdin.each_line { |l| } is the same loop", child('$stdin.each_line { |l| print l.chomp.reverse, "\n" }', stdin: "abc\ndef\n").inspect
    row 7, "readlines keeps newlines; readlines(chomp: true) strips", "#{child("p readlines", stdin: "x\ny\n")}; #{child("p readlines(chomp: true)", stdin: "x\ny\n")}"
    row 8, "$stdin.read(3) takes three bytes; read slurps the rest", child("p [$stdin.read(3), $stdin.read]", stdin: "abcdef")
    row 9, "$stdin.readline at EOF raises instead of returning nil", child("begin; $stdin.readline; rescue EOFError => e; puts e.class; end")
    row 10, 'gets("") reads a paragraph; gets(nil) slurps (Perl)', child('p [gets(""), gets(nil)]', stdin: "p1\nl2\n\n\np2\nrest")

    row 11, "the trap: ruby -e 'p gets' a.txt reads the FILE", child("p gets", "a.txt", stdin: "from stdin\n")
    row 12, "  $stdin.gets ignores ARGV", child("p $stdin.gets", "a.txt", stdin: "from stdin\n")
    row 13, "  gets is ARGF.gets: ARGF.read joins ARGV's files", child("p ARGF.read", "a.txt", "b.txt", stdin: "from stdin\n")
    row 14, "  ARGV before and after: ARGF consumes the names", child("before = ARGV.dup; ARGF.read; p [before, ARGV]", "a.txt", "b.txt")
    row 15, "ARGF.filename, ARGF.lineno (total), ARGF.file.lineno (per file):"
    child('ARGF.each_line { |l| puts "#{ARGF.filename}:#{ARGF.lineno}:#{ARGF.file.lineno}: #{l}" }', "a.txt", "b.txt").each_line { |l| puts "      #{l}" }
    row 16, "with ARGV empty, ARGF reads stdin; filename is", child("p [ARGF.read, ARGF.filename]", stdin: "from stdin\n")
    row 17, 'a bare "-" in ARGV means stdin', child("p gets", "-", stdin: "dash means stdin\n")
    row 18, "a name in ARGV that does not exist", child("begin; ARGF.read; rescue SystemCallError => e; puts e.class; end", "nope.txt")
    row 19, "$stdin.tty? when fed by a pipe, as here", child("p $stdin.tty?")
    row 20, "$stdin.eof? before and after the only line", child("p [$stdin.eof?, gets, $stdin.eof?]", stdin: "only\n")
    row 21, "$< is ARGF; $stdin and STDIN are one IO", child("p [$<.equal?(ARGF), $stdin.equal?(STDIN), $stdin.class]")
  end
end
