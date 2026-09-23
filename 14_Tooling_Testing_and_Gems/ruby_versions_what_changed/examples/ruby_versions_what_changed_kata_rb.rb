# Kata: a feature probe. `feature?` compiles a snippet and says whether this
# Ruby accepts it -- including a snippet from a Ruby that does not exist.
def feature?(name, src)
  RubyVM::InstructionSequence.compile(src)
  puts format("%-28s accepted", name)
rescue SyntaxError
  puts format("%-28s rejected (SyntaxError)", name)
end

feature? "2.3 safe navigation",      "a&.b"
feature? "2.7 pattern matching",     "case 1\nin Integer then :int\nend"
feature? "3.1 hash shorthand",       "x = 1\n{x:}"
feature? "3.4 it parameter",         "[1].map { it }"
feature? "imaginary: pipe operator", "1 |> puts"
feature? "imaginary: def without end", "def f(x) x * 2"
