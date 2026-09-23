# Kata: a price table — names left-aligned, amounts right-aligned with
# thousands separators and two decimals — from format and one gsub.

def money(x) = format("%.2f", x).gsub(/\B(?=(\d{3})+\.)/, ",")

items = { "laptop" => 1299.99, "mouse" => 24.5, "desk" => 1234567.891, "refund" => -1234.5 }
items.each { |name, price| puts format("%-8s %14s", name, money(price)) }
puts format("%-8s %14s", "total", money(items.values.sum))
