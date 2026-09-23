# YARV bytecode and the Prism syntax tree are both inspectable from Ruby itself.
# Only instruction names and node class names are printed: offsets, line numbers
# and paths are left out because they are not what the lesson is about.

require "prism"

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value.inspect)
end

def instruction_names(iseq)
  iseq.disasm.lines.take_while { |line| line.strip != "" }.grep(/\A\d{4} /).map { |line| line.split[1] }
end

def tree_lines(node, depth = 0, out = [])
  out << ("  " * depth) + node.class.name.delete_prefix("Prism::")
  node.compact_child_nodes.each { |child| tree_lines(child, depth + 1, out) }
  out
end

def foo(x)
  x + 1
end

iseq = RubyVM::InstructionSequence.compile("a = 1 + 2; a * 3")
row 1, "compile(\"a = 1 + 2; a * 3\"): instruction names", instruction_names(iseq)
row 2, "1 + 2 is not folded: opt_plus is in the sequence", instruction_names(iseq).include?("opt_plus")
row 3, "iseq.eval", iseq.eval
row 4, "to_a[0] (format magic), label, kind", [iseq.to_a[0], iseq.label, iseq.to_a[9]]

m = RubyVM::InstructionSequence.of(method(:foo))
row 5, "InstructionSequence.of(method(:foo)): label, kind, names", [m.label, m.to_a[9], instruction_names(m)]

plain = RubyVM::InstructionSequence.compile("1 + 2", specialized_instruction: false)
row 6, "specialized_instruction: false -> opt_plus becomes send", instruction_names(plain)
row 7, "to_binary.class, load_from_binary(...).eval", [iseq.to_binary.class, RubyVM::InstructionSequence.load_from_binary(iseq.to_binary).eval]

tree = Prism.parse("1 + 2")
row 8, "Prism.parse(\"1 + 2\"): success?, value.class, the nodes:", [tree.success?, tree.value.class]
puts tree_lines(tree.value).map { |line| "      " + line }
call = tree.value.statements.body.first
row 9, "the CallNode: name, receiver.value, argument values, slice", [call.name, call.receiver.value, call.arguments.arguments.map(&:value), call.slice]
row 10, "Prism.parse(\"a = 1 + 2; a * 3\") nodes:", Prism.parse("a = 1 + 2; a * 3").success?
puts tree_lines(Prism.parse("a = 1 + 2; a * 3").value).map { |line| "      " + line }
row 11, "RubyVM::AbstractSyntaxTree.parse(\"1 + 2\").type (older API)", RubyVM::AbstractSyntaxTree.parse("1 + 2").type
