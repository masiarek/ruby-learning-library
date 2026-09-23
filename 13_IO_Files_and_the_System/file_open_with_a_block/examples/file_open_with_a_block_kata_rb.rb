# Kata: a small `wc` -- lines, words and bytes of a file -- written with
# File.foreach so the file is never held in memory whole. The file is created in
# a temporary directory and only its relative name is printed.
require "tmpdir"

def wc(name)
  lines = words = 0
  File.foreach(name) do |line|
    lines += 1
    words += line.split.size
  end
  [lines, words, File.size(name)]
end

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("poem.txt", "the quick brown fox\njumps over\nthe lazy dog\n")
    lines, words, bytes = wc("poem.txt")
    puts format("%4d %4d %4d %s", lines, words, bytes, "poem.txt")
    File.write("empty.txt", "")
    puts format("%4d %4d %4d %s", *wc("empty.txt"), "empty.txt")
    File.write("nonl.txt", "no newline at the end")
    puts format("%4d %4d %4d %s", *wc("nonl.txt"), "nonl.txt")
  end
end
