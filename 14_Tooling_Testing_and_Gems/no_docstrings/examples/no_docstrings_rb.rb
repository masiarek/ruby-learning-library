# Ruby has no docstring. A method knows where it was defined (source_location),
# and the comment above the `def` is the documentation by convention -- RDoc,
# YARD and `ri` all read it from the file, and so does the reader below.

# Adds two numbers.
# Both must be numeric.
def add(a, b) = a + b

class Calc
  # the multiply helper
  def mul(a, b) = a * b

  def undocumented = nil
end

# Read the comment lines directly above a method's `def` from its source file.
def doc_for(meth)
  file, line = meth.source_location
  return nil if file.nil?
  lines = File.readlines(file, chomp: true)
  found = []
  i = line - 2
  while i >= 0 && lines[i].strip.start_with?("#")
    found.unshift(lines[i].strip.sub(/\A#\s?/, ""))
    i -= 1
  end
  found
end

file, line = method(:add).source_location
puts " 1. Method#source_location:     [#{File.basename(file)}, #{line}] -- a #{file.class} and an #{line.class}"
puts " 2. a C-implemented method:     1.method(:+).source_location is #{1.method(:+).source_location.inspect}, method(:puts) too: #{method(:puts).source_location.inspect}"
puts " 3. comment above def add:      #{doc_for(method(:add)).inspect}"
puts " 4. comment above Calc#mul:     #{doc_for(Calc.instance_method(:mul)).inspect}"
puts " 5. no comment:                 #{doc_for(Calc.instance_method(:undocumented)).inspect}"
puts " 6. no Method#doc at all:       Method.instance_methods.grep(/doc/) = #{Method.instance_methods.grep(/doc/).inspect}"
puts " 7. a comment is not an object: the string \"# Adds two numbers.\" exists only in the file; nothing at run time holds it"
require "rdoc"
doc = RDoc::Markup.parse("Adds two numbers.\n\nBoth must be numeric.")
parts = doc.parts.map { it.class.name.split("::").last }
puts " 8. RDoc parses that comment:   a #{doc.class.name.split("::").last} with #{parts.count("Paragraph")} paragraphs (parts: #{parts.join(", ")})"
