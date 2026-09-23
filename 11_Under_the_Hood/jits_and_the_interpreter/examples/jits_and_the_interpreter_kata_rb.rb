# Kata: one table, four children. Each child of RbConfig.ruby reports whether
# YJIT and ZJIT are enabled and whether it was parsed by Prism; the flag is
# the only thing that changes between the rows.

require "open3"
require "rbconfig"

REPORT = "print [RubyVM::YJIT.enabled?, RubyVM::ZJIT.enabled?, RUBY_DESCRIPTION.include?('+PRISM')].join(' ')"

puts format("%-18s %-6s %-6s %s", "flag", "YJIT", "ZJIT", "PRISM")
[[], ["--yjit"], ["--zjit"], ["--parser=parse.y"]].each do |flags|
  out, _err, _status = Open3.capture3(RbConfig.ruby, *flags, "-e", REPORT)
  yjit, zjit, prism = out.split
  puts format("%-18s %-6s %-6s %s", flags.first || "(none)", yjit, zjit, prism)
end
