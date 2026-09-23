# require loads a feature once; load runs a file every time; require_relative
# resolves against the calling file; autoload defers the load to first use.
require "tmpdir"

def row(n, label, value = nil)
  puts format("%2d. %-42s %s", n, label, value)
end

before = $LOADED_FEATURES.size
first  = require "json"
second = require "json"
row 1, 'require "json" twice', "first: #{first}   second: #{second}"
row 2, "$LOADED_FEATURES (the once-list)",
    "grew: #{$LOADED_FEATURES.size > before}   holds json.rb: " \
    "#{$LOADED_FEATURES.any? { |f| f.end_with?("/json.rb") }}"

Dir.mktmpdir do |dir|
  lib = File.join(dir, "lib")
  Dir.mkdir(lib)
  File.write(File.join(lib, "helper.rb"), <<~'RUBY')
    puts "    (helper body ran, from #{File.basename(__dir__)})"
    module Helper
      def self.hi = "hi"
    end
  RUBY
  File.write(File.join(dir, "main_part.rb"), <<~'RUBY')
    require_relative "lib/helper"
    puts "    main_part sees Helper.hi = #{Helper.hi}"
  RUBY
  File.write(File.join(lib, "helper2.rb"), "puts '    (helper2 body ran)'\n")
  File.write(File.join(lib, "greeter.rb"), "puts '    (greeter body ran)'\nclass Greeter; end\n")

  main = File.join(dir, "main_part.rb")
  row 3, "load main_part.rb, which require_relatives", "lib/helper against its own folder:"
  load main
  row 4, "load main_part.rb again", "main_part runs; helper is remembered:"
  load main
  row 5, "load lib/helper.rb twice", "load runs the file every time:"
  load File.join(lib, "helper.rb")
  load File.join(lib, "helper.rb")

  $LOAD_PATH.unshift(lib)
  row 6, "$LOAD_PATH is #{$LOAD_PATH.class}; after unshift(lib)", 'require "helper2" (no extension):'
  found = require "helper2"
  row 6, "", "found helper2.rb: #{found}   again: #{require "helper2"}"

  begin
    require "nope"
  rescue LoadError => e
    row 7, 'require "nope"', "#{e.class}: #{e.message}   (e.path: #{e.path.inspect})"
  end

  autoload :Greeter, File.join(lib, "greeter.rb")
  row 8, "autoload :Greeter, path", "registered: #{!Object.autoload?(:Greeter).nil?}   " \
      "const_defined?: #{Object.const_defined?(:Greeter)}   body ran yet: no"
  row 8, "", "first reference to Greeter loads it:"
  klass = Greeter
  row 8, "", "Greeter is #{klass.class} #{klass.name}   autoload? now nil: " \
      "#{Object.autoload?(:Greeter).nil?}"
end
