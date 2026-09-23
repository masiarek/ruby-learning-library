# Kata: for every (a, b) in [7, -7] x [2, -2], print the floored pair
# (/ and %) and the truncated pair (fdiv.truncate and remainder), and check
# the identity each pair satisfies: a == q * b + r.

puts format("%-3s %-3s | %-6s %-6s | %-6s %-9s | %s",
            "a", "b", "a / b", "a % b", "trunc", "remainder", "both identities hold?")
[7, -7].product([2, -2]).each do |a, b|
  floored   = a / b
  modulo    = a % b
  truncated = a.fdiv(b).truncate
  remainder = a.remainder(b)
  floor_ok  = (a == floored * b + modulo)
  trunc_ok  = (a == truncated * b + remainder)
  puts format("%-3d %-3d | %-6d %-6d | %-6d %-9d | %s",
              a, b, floored, modulo, truncated, remainder, floor_ok && trunc_ok)
end
