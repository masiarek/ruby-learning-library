# Ruby's indentation is a convention: mis-indented code runs, and `ruby -w`
# warns about a mismatched `end`. Names carry meaning only where the parser
# insists (a class name must be a constant). The Python twin asks the same nine.
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

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("mismatch.rb", "def greet(name)\n  if name\n    puts name\n    end\nend\ngreet('ran anyway')\n")
    out, err, status = run_child("-w", "mismatch.rb")
    row 1, "ruby -w mismatch.rb (end under the wrong column)", "stdout #{out.inspect}, exit #{status}"
    puts "       stderr: #{err}"

    File.write("unused.rb", "unused = 1\nputs 'ok'\n")
    out, err, status = run_child("-w", "unused.rb")
    row 2, "ruby -w unused.rb (assigned, never read)", "stdout #{out.inspect}, exit #{status}"
    puts "       stderr: #{err}"

    File.write("tabs.rb", "def f\n\tif true\n        1\n\tend\nend\nputs f\n")
    out, err, status = run_child("-w", "tabs.rb")
    row 3, "ruby -w tabs.rb (a tab line, a space line)", "stdout #{out.inspect}, stderr #{err.inspect}, exit #{status}"

    out, err, status = run_child("-c", "unused.rb")
    row 4, "ruby -c unused.rb (syntax check only)", "stdout #{out.inspect}, exit #{status}"

    File.write("frozen.rb", "# frozen_string_literal: true\nputs 'lit'.frozen?\n")
    File.write("plain.rb", "puts 'lit'.frozen?\n")
    $frozen_row = "#{run_child("frozen.rb")[0]} / #{run_child("plain.rb")[0]}"
  end
end

begin
  RubyVM::InstructionSequence.compile("class parseError; end")
  named = "compiled"
rescue SyntaxError => e
  named = "#{e.class} (a class name must be a constant)"
end
row 5, "class parseError; end", named

def empty_bag? = true
def save! = :saved
row 6, "def empty_bag? / def save!  (predicate and bang names)", "#{empty_bag?} / #{save!.inspect}"

MAX_RETRIES = 3
max_retries = 4
row 7, "defined?(MAX_RETRIES) / defined?(max_retries)", "#{defined?(MAX_RETRIES)} / #{defined?(max_retries)}"

curly = [1, 2, 3].map { |v| v * 2 }
long = [1, 2, 3].map do |v|
  v * 2
end
row 8, "{ } on one line / do...end over lines", "#{curly.inspect} / #{long.inspect}  (same result)"
row 9, "# frozen_string_literal: true / without it", $frozen_row

def describe(name)
  return "nobody" unless name
  return "too long" if name.length > 5
  "hello, #{name}"
end
puts "10. guard clauses: describe(nil) / describe(\"ann\") / describe(\"jonathan\")"
puts "       #{describe(nil).inspect} / #{describe("ann").inspect} / #{describe("jonathan").inspect}"
puts "11. mis-indented code still runs: eval of a def with every line at column 0 -> " \
     "#{eval("def flat(x)\nif x\n1\nelse\n2\nend\nend\nflat(true)")}"
