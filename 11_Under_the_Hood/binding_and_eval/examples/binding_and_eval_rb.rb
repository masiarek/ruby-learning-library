# A Binding captures a scope -- its local variables, its self and the method it
# was made in -- as an object you can carry around and evaluate code inside later.

require "erb"

def two_locals
  a = 1
  b = 2
  binding
end

def counter_binding
  count = 0
  binding
end

def set_through_a_throwaway_binding
  binding.local_variable_set(:c, 3)
  [defined?(c), binding.local_variable_defined?(:c)]
end

def make_multiplier
  z = 5
  ->(q) { q * z }
end

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value.inspect)
end

b = two_locals
row 1, "b = two_locals; b.class, b.local_variables", [b.class, b.local_variables]
row 2, "b.local_variable_get(:a)", b.local_variable_get(:a)
row 3, "eval(\"a + b\", b)", eval("a + b", b)
b.local_variable_set(:a, 10)
row 4, "after b.local_variable_set(:a, 10): eval(\"a * b\", b)", eval("a * b", b)
b.local_variable_set(:c, 3)
row 5, "local_variable_set(:c, 3) adds c to the binding", [b.local_variable_defined?(:c), b.local_variables.sort]
row 6, "in a method, set through a throwaway binding", set_through_a_throwaway_binding
eval("w = 7", b)
row 7, "eval(\"w = 7\", b); b.local_variable_get(:w)", b.local_variable_get(:w)
cb = counter_binding
3.times { cb.eval("count += 1") }
row 8, "3.times { cb.eval(\"count += 1\") }; count", cb.local_variable_get(:count)
row 9, "eval(\"__method__\", b), b.receiver", [eval("__method__", b), b.receiver]
z = 5
row 10, "TOPLEVEL_BINDING.receiver, .local_variable_get(:z)", [TOPLEVEL_BINDING.receiver, TOPLEVEL_BINDING.local_variable_get(:z)]
triple = make_multiplier
row 11, "a lambda's binding: .local_variables, z", [triple.binding.local_variables, triple.binding.local_variable_get(:z)]
row 12, "ERB.new(\"a is <%= a %>, b is <%= b %>\").result(b)", ERB.new("a is <%= a %>, b is <%= b %>").result(b)
row 13, "eval(\"nope\", b) raises", (eval("nope", b) rescue $!.class)
