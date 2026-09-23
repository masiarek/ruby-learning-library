# A refinement changes a class only for the code that says `using` -- from
# that line to the end of the file. The Python twin, refinements_py.py, prints
# the same numbered rows with unittest.mock.patch, which is not lexical.

require "tmpdir"

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-46s %s", label, value))

module Shout
  refine String do
    def shout = upcase + "!"
    def length = "refined length"
  end
end

# Written above the `using` line: this method never sees the refinement,
# however late it is called.
def before_using = "hi".shout

section 1, "a refinement is a Module holding Refinement objects"
row "Shout.class", Shout.class
row "Shout.refinements", Shout.refinements.inspect
row "Shout.refinements.first.class", Shout.refinements.first.class
row "Shout.refinements.first.target", Shout.refinements.first.target
row "Refinement.superclass", Refinement.superclass

section 2, "before using: String is untouched"
begin
  "hi".shout
rescue NoMethodError => e
  row "\"hi\".shout", e.class
end
row "\"hi\".respond_to?(:shout)", "hi".respond_to?(:shout)
row "String.method_defined?(:shout)", String.method_defined?(:shout)

using Shout

section 3, "after using: the rest of this file sees it"
row "\"hi\".shout", "hi".shout
row "\"hi\".length  (an existing method, replaced)", "hi".length
row "[\"a\", \"b\"].map(&:shout)", ["a", "b"].map(&:shout).inspect
def after_using = "hi".shout
row "after_using  (a method written below using)", after_using

section 4, "the scope is lexical: where code is written, not when it runs"
begin
  before_using
rescue NoMethodError => e
  row "before_using  (written above the using line)", e.class
end
Dir.mktmpdir do |dir|
  File.write(File.join(dir, "other_file.rb"), "def other_file_shout = \"hi\".shout\n")
  require File.join(dir, "other_file")
end
begin
  other_file_shout
rescue NoMethodError => e
  row "a method in a file required after using", e.class
end
row "eval('\"z\".shout')  (a string eval'd here)", eval('"z".shout')
begin
  def not_allowed = using(Shout)
  not_allowed
rescue RuntimeError => e
  row "using inside a method", "#{e.class}: #{e.message}"
end

section 5, "what reflection sees inside the scope"
row "\"hi\".respond_to?(:shout)", "hi".respond_to?(:shout)
row "\"hi\".send(:shout)", "hi".send(:shout)
row "\"hi\".public_send(:shout)", "hi".public_send(:shout)
row "\"hi\".method(:shout).owner", "hi".method(:shout).owner
row "String.instance_methods.include?(:shout)", String.instance_methods.include?(:shout)
row "String.method_defined?(:shout)", String.method_defined?(:shout)
row "Module.used_modules", Module.used_modules.inspect
row "Module.used_refinements", Module.used_refinements.inspect

section 6, "super reaches the original; a refinement sees only what was active where it was written"
module Politely
  refine String do
    def upcase = "politely " + super
  end
end
using Politely
row "\"hi\".upcase  (refined; calls super)", "hi".upcase
row "\"hi\".shout  (its upcase is still the original)", "hi".shout
row "Module.used_modules", Module.used_modules.inspect
