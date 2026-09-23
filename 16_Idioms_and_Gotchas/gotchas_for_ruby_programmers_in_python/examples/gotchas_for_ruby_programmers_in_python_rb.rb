# Ruby's answer to each of the twenty-three rows, so the page reads the two
# programs side by side: the Python behaviour a Ruby programmer trips on, and
# what Ruby does in the same spot.

def row(n, label, value)
  puts format("%2d. %-44s %s", n, label, value)
end

def compiles?(source)
  RubyVM::InstructionSequence.compile(source)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

def raises
  yield.inspect
rescue StandardError => e
  e.class.to_s
end

def f(a = [])
  a << 1
  a
end

row 1, "def f(a = []); a << 1; end; f / f", "#{f.inspect} / #{f.inspect}  (a fresh array per call)"
row 2, "(1..3).map { |i| -> { i } }.map(&:call)", (1..3).map { |i| -> { i } }.map(&:call).inspect
row 3, '256.equal?(256) / "a".equal?("a") / "a" == "a"', "#{256.equal?(256)} / #{"a".equal?("a")} / #{"a" == "a"}"
row 4, "7 / 2 / 7.fdiv(2) / -7 / 2", "#{7 / 2} / #{7.fdiv(2)} / #{-7 / 2}"
row 5, "2.5.round / 3.5.round / 2.5.round(half: :even)", "#{2.5.round} / #{3.5.round} / #{2.5.round(half: :even)}"

class WithSelf
  def m = self.class.name
end
row 6, "def m = self.class.name; WithSelf.new.m", "#{WithSelf.new.m.inspect}  (self is implicit)"
row 7, "eval of a def with every line at column 0", eval("def flat\nif true\n1\nend\nend\nflat").to_s + "  (ran)"
row 8, 'puts "x" is a method call without parentheses', "#{compiles?('puts "x"')} / #{compiles?('puts("a", "b")')}"
row 9, "elsif / elif", "#{compiles?("if 1 then 1 elsif 2 then 2 end")} / #{compiles?("if 1 then 1 elif 2 then 2 end")}"
row 10, "no for-else: [1, 2].find { it == 9 } / each returns", "#{[1, 2].find { it == 9 }.inspect} / #{[1, 2].each { it }.inspect}"
a = [3, 1]
row 11, "a = [3, 1]; a.sort! / [1, 2].uniq!", "#{a.sort!.inspect} / #{[1, 2].uniq!.inspect}  (bang returns self, or nil for no change)"
s = "abc"
s[0] = "x"
row 12, 's = "abc"; s[0] = "x"; s', s.inspect
row 13, "def empty?; end / def save!; end", "#{compiles?("def empty?; end")} / #{compiles?("def save!; end")}"
row 14, "(1..3).to_a / (1...3).to_a", "#{(1..3).to_a.inspect} / #{(1...3).to_a.inspect}  (.. is closed, ... half-open)"
h = {}
row 15, "h = {}; h[:k] / h.fetch(:k)", "#{h[:k].inspect} / #{raises { h.fetch(:k) }}"
y = 5 if false
row 16, "y = 5 if false; y / defined?(y)", "#{y.inspect} / #{defined?(y).inspect}"

class Account
  def __init__
    @balance = 0
  end
end
row 17, "def __init__ is never called: @balance after new", Account.new.instance_variable_get(:@balance).inspect
count = 0
[1].each { count += 1 }
def peek = count
row 18, "a block assigns the outer local / a def sees it?", "#{count} / #{raises { peek }}  (no nonlocal; a def is a new scope)"
row 19, "->(v) { w = v * 2; w + 1 }.call(2)", "#{->(v) { w = v * 2; w + 1 }.call(2)}  (a lambda holds statements)"
empty = []
zero = 0
row 20, "[] and 0 in a condition", "#{empty ? "truthy" : "falsy"} / #{zero ? "truthy" : "falsy"}"
row 21, '"abc".length / length("abc")', "#{"abc".length} / #{raises { length("abc") }}"
row 22, "[1].class / (1).class / no tuple: [1].freeze.frozen?", "#{[1].class} / #{(1).class} / #{[1].freeze.frozen?}"
row 23, "1 < 2 < 3", "#{raises { 1 < 2 < 3 }}  (no chained comparison: (1 < 2) < 3 asks true < 3)"
