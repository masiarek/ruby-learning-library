# File.open with a block closes the file for you. Everything happens inside a
# temporary directory that is removed at the end; only relative names are printed.
require "tmpdir"

def row(n, text, value = "")
  puts format("%2d. %-58s %s", n, text, value)
end

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    handle = nil
    result = File.open("notes.txt", "w") do |f|
      handle = f
      f.puts "one"
      :block_value
    end
    row 1, "File.open with a block: closed? afterwards", handle.closed?
    row 2, "  and the block's value is what File.open returns", result.inspect

    row 3, "File.write returns what it wrote, counted in bytes", File.write("a.txt", "x\ny\n")
    row 4, "File.read gives the whole file as one String", File.read("a.txt").inspect
    row 5, "File.readlines keeps each newline", File.readlines("a.txt").inspect
    row 6, "File.readlines(chomp: true) drops them", File.readlines("a.txt", chomp: true).inspect
    lines = []
    File.foreach("a.txt") { |line| lines << line }
    row 7, "File.foreach yields one line at a time", lines.map(&:inspect).join(" then ")
    row 8, "each_line(chomp: true) inside a block", File.open("a.txt") { |f| f.each_line(chomp: true).to_a }.inspect

    File.open("a.txt", "a") { |f| f.write "z\n" }
    row 9, "mode \"a\" appends", File.read("a.txt").inspect
    File.open("a.txt", "w") { |f| f.puts "fresh" }
    row 10, "mode \"w\" truncates first", File.read("a.txt").inspect
    row 11, "mode \"r+\" reads and writes in place", File.open("a.txt", "r+") { |f| f.write("F"); f.rewind; f.read }.inspect
    begin
      File.open("a.txt", "x") {}
    rescue ArgumentError => e
      row 12, "mode \"x\" (Python's exclusive create) does not exist", "#{e.class}: #{e.message}"
    end
    begin
      File.open("a.txt", File::WRONLY | File::CREAT | File::EXCL) {}
    rescue SystemCallError => e
      row 13, "  the flag form File::CREAT | File::EXCL is the same idea", e.class
    end

    row 14, "File.exist? for a file that is there / not there", [File.exist?("a.txt"), File.exist?("nope.txt")].inspect
    begin
      File.read("nope.txt")
    rescue SystemCallError => e
      row 15, "reading a missing file raises", "#{e.class}: #{e.message}"
    end

    f = File.open("a.txt")
    row 16, "without a block the file stays open: closed?", f.closed?
    first = f.gets
    f.close
    row 17, "  after gets and close: line, closed?", "#{first.inspect}, #{f.closed?}"
    begin
      f.gets
    rescue IOError => e
      row 18, "  reading a closed file", "#{e.class}: #{e.message}"
    end

    File.write("u.txt", "caf\u{e9}\n")
    text = File.read("u.txt")
    row 19, "default encoding under -E UTF-8: read gives", "#{text.inspect} #{text.encoding} length=#{text.length} bytesize=#{text.bytesize}"
    latin = File.read("u.txt", encoding: "ISO-8859-1")
    row 20, "encoding: \"ISO-8859-1\" relabels the same bytes", "#{latin.encoding} length=#{latin.length}"
    bin = File.open("u.txt", "rb") { |io| io.read }
    row 21, "mode \"rb\" gives binary (ASCII-8BIT)", "#{bin.encoding.name} length=#{bin.length}"
    row 22, "File.write counts bytes, so \"caf\\u{e9}\\n\" is", File.write("u2.txt", "caf\u{e9}\n")

    File.binwrite("crlf.txt", "a\r\nb\n")
    row 23, "CRLF file, File.read keeps the \\r (no translation)", File.read("crlf.txt").inspect
    row 24, "  readlines(chomp: true) strips \\r\\n and \\n alike", File.readlines("crlf.txt", chomp: true).inspect
  end
  row 25, "the temp directory still exists inside the block", File.exist?(dir)
  $dir = dir
end
row 26, "and is gone after it", File.exist?($dir)
