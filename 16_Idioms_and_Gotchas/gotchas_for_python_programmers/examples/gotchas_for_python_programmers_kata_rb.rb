# Kata: Python's truthiness, implemented in Ruby, beside Ruby's own.
# Python treats None, False, zero of any numeric type and every empty
# container or string as false; Ruby treats only nil and false as false.

def py_truthy?(value)
  case value
  when nil, false then false
  when Numeric then !value.zero?
  when String, Array, Hash then !value.empty?
  else true
  end
end

values = [nil, false, 0, 0.0, "", " ", [], {}, :a, [0]]

puts format("%-8s %-12s %s", "value", "Ruby !!v", "py_truthy?(v)")
values.each do |v|
  mark = !!v == py_truthy?(v) ? "" : "  <- differ"
  puts format("%-8s %-12s %s%s", v.inspect, !!v, py_truthy?(v), mark)
end
