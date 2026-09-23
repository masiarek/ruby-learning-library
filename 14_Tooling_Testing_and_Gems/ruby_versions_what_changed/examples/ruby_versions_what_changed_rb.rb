# Which of the features the timeline names does *this* Ruby have? Each row
# compiles a snippet or asks a class, so the page's history is checked against
# the interpreter that ran it.
def compiles?(src)
  RubyVM::InstructionSequence.compile(src)
  true
rescue SyntaxError
  false
end

def row(n, release, feature, evidence)
  puts format("%2d. %-4s %-40s %s", n, release, feature, evidence)
end

row 1, "now", "RUBY_VERSION >= \"4.0\"", "#{RUBY_VERSION >= "4.0"}   (major #{RUBY_VERSION.split(".").first})"
row 2, "2.0", "keyword arguments, Module#prepend",
    "def f(a:, b: 2) compiles: #{compiles?("def f(a:, b: 2) = a + b")}   prepend: #{Module.private_method_defined?(:prepend) || Module.method_defined?(:prepend)}"
row 3, "2.1", "refinements", "Refinement class: #{defined?(Refinement) == "constant"}"
row 4, "2.3", "&. safe navigation, Hash#dig",
    "nil&.length compiles: #{compiles?("nil&.length")}   dig: #{{}.respond_to?(:dig)}"
row 5, "2.4", "one Integer class",
    "Fixnum defined: #{!defined?(Fixnum).nil?}   1.class: #{1.class}   (2**100).class: #{(2**100).class}"
row 6, "2.5", "rescue inside do...end blocks", "compiles: #{compiles?("[1].each do\nrescue => e\nend")}"
row 7, "2.6", "endless range, then, proc >>",
    "(1..) compiles: #{compiles?("(1..)")}   then: #{1.respond_to?(:then)}   >>: #{proc {}.respond_to?(:>>)}"
row 8, "2.7", "pattern matching, ... forwarding, _1",
    "case/in: #{compiles?("case [1]\nin [x] then x\nend")}   (...): #{compiles?("def f(...) = g(...)")}   _1: #{compiles?("[1].map { _1 }")}"
kw = ->(**opts) { opts }
separated = begin
  kw.call({ a: 1 })
  false
rescue ArgumentError
  true
end
row 9, "3.0", "keyword separation, Ractor, endless def",
    "f({a: 1}) no longer fills **opts: #{separated}   Ractor: #{defined?(Ractor) == "constant"}   def f = 1: #{compiles?("def f = 1")}"
row 10, "3.1", "{x:} shorthand, Class#subclasses",
    "compiles: #{compiles?("x = 1; {x:}")}   subclasses: #{Class.method_defined?(:subclasses)}"
row 11, "3.2", "Data, anonymous * ** &, linear_time?",
    "Data.define: #{Data.respond_to?(:define)}   def f(*, **, &) = g(*, **, &): #{compiles?("def f(*, **, &) = g(*, **, &)")}   Regexp.linear_time?: #{Regexp.respond_to?(:linear_time?)}"
require "prism"
row 12, "3.3", "Prism parser ships with Ruby", "require \"prism\" then Prism defined: #{defined?(Prism) == "constant"}"
message = begin
  nil.foo
rescue NoMethodError => e
  e.message
end
row 13, "3.4", "it, chilled literals, 'name' quoting",
    "[1].map { it }: #{compiles?("[1].map { it }")}   \"a\".frozen?: #{"a".frozen?} (chilled, not frozen)   message: #{message.inspect}"
row 14, "4.0", "core Set, Ractor::Port, ZJIT, Ruby::Box",
    "Set needs no require and is C code: #{Set.instance_method(:add).source_location.nil?}   Ractor::Port: #{defined?(Ractor::Port) == "constant"}   RubyVM::ZJIT: #{defined?(RubyVM::ZJIT) == "constant"}   Ruby::Box: #{defined?(Ruby::Box) == "constant"}"
row 15, "4.0", "Warning.categories", Warning.categories.inspect
