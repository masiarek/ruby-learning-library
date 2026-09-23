# Exercise 1: write a sloppy file, run it under ruby -w and without, and print what
# each run said on stderr with the temp-dir path cut to the base name.

require "open3"
require "rbconfig"
require "tmpdir"

SLOPPY = <<~RUBY
  def total(items)
    count = items.size
    items.sum
  end

  def total(items)
    items.sum
  end

  puts total([1, 2, 3])
RUBY

Dir.mktmpdir do |dir|
  path = File.join(dir, "sloppy.rb")
  File.write(path, SLOPPY)
  [["without -w"], ["with -w", "-w"]].each do |label, *flags|
    out, err, status = Open3.capture3(RbConfig.ruby, *flags, path)
    puts "#{label}: stdout #{out.chomp.inspect}, status #{status.exitstatus}"
    if err.empty?
      puts "   stderr: (empty)"
    else
      err.each_line { |line| puts "   stderr: #{line.chomp.sub(%r{\A\S*/}, '')}" }
    end
  end
end
