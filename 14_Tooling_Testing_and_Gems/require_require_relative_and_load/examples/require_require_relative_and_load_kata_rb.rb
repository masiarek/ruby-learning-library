# Kata: a require of your own. `once_load(path)` returns true the first time a
# file is run through it and false afterwards, like `require`; `load` ignores
# that memory, so it runs the file every time.
require "tmpdir"

ONCE = []

def once_load(path)
  path = File.expand_path(path)
  return false if ONCE.include?(path)
  ONCE << path
  load path
  true
end

Dir.mktmpdir do |dir|
  file = File.join(dir, "counter.rb")
  File.write(file, "$runs = ($runs || 0) + 1\nputs \"    counter.rb ran (run \#{$runs})\"\n")

  puts "1. once_load first time:"
  puts "   -> #{once_load(file)}"
  puts "2. once_load second time:"
  puts "   -> #{once_load(file)}"
  puts "3. load, twice, ignores the once-list:"
  load file
  load file
  puts "4. runs in total: #{$runs}   remembered by once_load: #{ONCE.size} file(s)"
  puts "5. real require agrees on a real feature: #{require "json"} then #{require "json"}"
end
