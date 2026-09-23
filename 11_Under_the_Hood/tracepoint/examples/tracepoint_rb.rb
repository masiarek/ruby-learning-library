# TracePoint is the VM's event hook: enable one for :call and :return and every
# method the VM enters or leaves reports itself, with its name, its class, its
# return value and (for :raise) the exception -- no changes to the code traced.

class Calculator
  def add(a, b)
    a + b
  end

  def double(x)
    add(x, x)
  end

  def fail_hard
    raise ArgumentError, "bad input"
  end

  def self.create
    new
  end
end

def helper
  42
end

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value.inspect)
end

ours = [Calculator, Calculator.singleton_class]

# 1-4: call and return, filtered to our class, with the return value
events = []
tp = TracePoint.new(:call, :return) do |t|
  next unless ours.include?(t.defined_class)
  events << [t.event, t.method_id, t.event == :return ? t.return_value : nil]
end
tp.enable do
  Calculator.new.double(3)
  helper
end
events.each_with_index { |e, i| row i + 1, i.zero? ? "double(3) traced; helper is not ours" : "", e }

row 5, "tp.enabled? after the block form", tp.enabled?

# 6: every event for one call of add
seq = []
TracePoint.new(:call, :line, :return) { |t| seq << t.event if t.defined_class == Calculator }.enable { Calculator.new.add(1, 2) }
row 6, "events for one add(1, 2): call, line, return", seq

# 7: C methods fire :c_call / :c_return
cseq = []
TracePoint.new(:c_call, :c_return) { |t| cseq << [t.event, t.method_id, t.defined_class] if t.method_id == :size }.enable { [1, 2, 3].size }
row 7, "[1, 2, 3].size is a C method", cseq

# 8: :raise
raised = []
TracePoint.new(:raise) { |t| raised << [t.event, t.raised_exception.class, t.method_id] }.enable do
  begin
    Calculator.new.fail_hard
  rescue ArgumentError
    nil
  end
end
row 8, ":raise inside fail_hard", raised

# 9: enable(target:) narrows to one method
only = []
TracePoint.new(:call, :return) { |t| only << [t.event, t.method_id] }.enable(target: Calculator.instance_method(:add)) do
  Calculator.new.double(2)
end
row 9, "enable(target: add) while double(2) runs", only

# 10: return_value and parameters on :return
ret = []
TracePoint.new(:return) { |t| ret << [t.method_id, t.return_value, t.parameters] if t.defined_class == Calculator }.enable { Calculator.new.add(1, 2) }
row 10, ":return carries return_value and parameters", ret

# 11: a class method's defined_class is the singleton class
cls = []
TracePoint.new(:call) { |t| cls << [t.method_id, t.defined_class.singleton_class?, t.self] if t.defined_class == Calculator.singleton_class }.enable { Calculator.create }
row 11, "Calculator.create: method_id, singleton_class?, self", cls

# 12: tracing is off inside the hook, so a traced call there does not recurse
inside = []
TracePoint.new(:call) { |t| inside << t.method_id if t.defined_class == Calculator; Calculator.new.add(1, 1) if inside.size < 5 }.enable { Calculator.new.add(1, 2) }
row 12, "calls made inside the hook are not traced", inside

# 13: enable / disable return the previous state
row 13, "[tp.enable, tp.enabled?, tp.disable, tp.enabled?]", [tp.enable, tp.enabled?, tp.disable, tp.enabled?]
