# Which engine is running and which JITs it has. Children started with
# RbConfig.ruby show what a command-line flag changes; only booleans and
# names are printed, never timings.

require "open3"
require "rbconfig"

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value.inspect)
end

def child(*args)
  out, _err, status = Open3.capture3(RbConfig.ruby, *args)
  [out.strip, status.success?]
end

row 1, "RUBY_ENGINE", RUBY_ENGINE
row 2, "RUBY_VERSION.start_with?(\"4.\")", RUBY_VERSION.start_with?("4.")
row 3, "RubyVM::YJIT.enabled? in this process (no flag)", RubyVM::YJIT.enabled?
row 4, "child --yjit -e 'puts RubyVM::YJIT.enabled?'", child("--yjit", "-e", "puts RubyVM::YJIT.enabled?")
row 5, "child --version says +YJIT: without / with --yjit", [child("--version").first.include?("+YJIT"), child("--yjit", "--version").first.include?("+YJIT")]
row 6, "RubyVM::YJIT.enable at runtime; enabled?; stats class", [RubyVM::YJIT.enable, RubyVM::YJIT.enabled?, RubyVM::YJIT.runtime_stats.class]
row 7, "ZJIT: defined?, enabled? here, child --zjit", [defined?(RubyVM::ZJIT), RubyVM::ZJIT.enabled?, child("--zjit", "-e", "puts RubyVM::ZJIT.enabled?")]
row 8, "INSTRUCTION_NAMES has opt_plus, opt_new, leave", %w[opt_plus opt_new leave].map { |i| RubyVM::INSTRUCTION_NAMES.include?(i) }
row 9, "RubyVM.stat(:constant_cache_invalidations): key?, class", [RubyVM.stat.key?(:constant_cache_invalidations), RubyVM.stat(:constant_cache_invalidations).class]
row 10, "+PRISM here; child --parser=parse.y says +PRISM", [RUBY_DESCRIPTION.include?("+PRISM"), child("--parser=parse.y", "-e", "puts RUBY_DESCRIPTION.include?('+PRISM')")]
row 11, "Process.respond_to?(:warmup) (3.3: tidy up before fork)", Process.respond_to?(:warmup)
row 12, "defined?(Ruby::Box) (4.0: an isolated namespace)", defined?(Ruby::Box)
