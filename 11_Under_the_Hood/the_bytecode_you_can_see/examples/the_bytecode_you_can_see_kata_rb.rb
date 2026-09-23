# Kata: opcodes(src) returns the instruction names of a source string and of
# every child instruction sequence -- a block or a method body is compiled as
# its own sequence, reachable through each_child. A parent's disasm lists its
# children after a blank line, so the listing is cut at the first blank line.

def names_of(iseq)
  iseq.disasm.lines.take_while { |line| line.strip != "" }.grep(/\A\d{4} /).map { |line| line.split[1] }
end

def opcodes(src)
  iseq = RubyVM::InstructionSequence.compile(src)
  children = []
  iseq.each_child { |child| children << [child.label, names_of(child)] }
  [names_of(iseq), children]
end

["x = 5", "x = 5; x + 1", "[1, 2].map { |x| x * 2 }", "def m(a) = a * 2"].each do |src|
  main, children = opcodes(src)
  puts "#{src.ljust(26)} -> #{main.join(' ')}"
  children.each { |label, names| puts "#{' ' * 26}    #{label}: #{names.join(' ')}" }
end
