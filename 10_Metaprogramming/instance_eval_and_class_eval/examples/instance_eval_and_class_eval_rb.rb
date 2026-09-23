# instance_eval_and_class_eval_rb.rb — two evals, two things they move: self and the default definee.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

def where(unbound) = unbound.source_location.then { |file, line| "#{File.basename(file)}:#{line}" }

class Safe
  def initialize = @secret = 42
end

safe = Safe.new
row 1, "safe.instance_eval { @secret }", safe.instance_eval { @secret }
row 2, "safe.instance_eval { self.class }", safe.instance_eval { self.class }

Safe.class_eval { def x = "instance x" }              # def goes to Safe
row 3, "Safe.class_eval { def x }: Safe.new.x", Safe.new.x.inspect
begin
  Safe.x
rescue NoMethodError => e
  row "", "Safe.x", "#{e.class}: #{e.message}"
end

Safe.instance_eval { def y = "class y" }              # def goes to Safe's singleton class
row 4, "Safe.instance_eval { def y }: Safe.y", Safe.y.inspect
begin
  Safe.new.y
rescue NoMethodError => e
  row "", "Safe.new.y", "#{e.class}: #{e.message}"
end

safe.instance_eval { def only_me = :me }              # def goes to safe's singleton class
row 5, "safe.instance_eval { def only_me }", "safe.singleton_methods = #{safe.singleton_methods.inspect}"
row "", "Safe.new.respond_to?(:only_me)", Safe.new.respond_to?(:only_me)

row 6, "safe.instance_exec(3) { |n| @secret + n }", safe.instance_exec(3) { |n| @secret + n }
row "", "instance_eval { |o| o.equal?(safe) }", safe.instance_eval { |o| o.equal?(safe) }
begin
  safe.instance_eval(&-> { 1 })
rescue ArgumentError => e
  row "", "instance_eval(&-> { 1 }) -- a strict lambda", "#{e.class}: #{e.message}"
end

Safe.class_eval("def z = 3", __FILE__, __LINE__ + 1)  # 7. the string form, with file and line
row 7, 'class_eval("def z = 3", __FILE__, __LINE__ + 1)', "source_location = #{where(Safe.instance_method(:z))}"
Safe.class_eval("def w = 4")
row "", 'class_eval("def w = 4") -- no file, no line', "source_location = #{where(Safe.instance_method(:w))}"

factor = 3
row 8, "class_eval { factor * 2 } -- a block closes", Safe.class_eval { factor * 2 }
begin
  Safe.class_eval("factor * 2")
rescue NameError => e
  row "", 'class_eval("factor * 2") -- a string does not', "#{e.class}: #{e.message}"
end

row 9, "class_eval { 1 + 1 } / instance_eval(\"1 + 1\")", "#{Safe.class_eval { 1 + 1 }} / #{safe.instance_eval('1 + 1')}"

blk = proc { self.class }
row 10, "blk = proc { self.class }; blk.call", blk.call
row "", "safe.instance_eval(&blk)", safe.instance_eval(&blk)

klass = Safe
begin
  RubyVM::InstructionSequence.compile("class klass; end")
rescue SyntaxError => e
  row 11, "class klass; end -- a variable, not a constant", e.class
end
klass.class_eval { def v = 5 }
row "", "klass.class_eval { def v = 5 }: klass.new.v", klass.new.v

x = 5
row 12, 'x = 5; eval("x + 1") -- the current scope', eval("x + 1")
row 13, "module_eval == class_eval (same method)",
    Module.instance_method(:module_eval) == Module.instance_method(:class_eval)
