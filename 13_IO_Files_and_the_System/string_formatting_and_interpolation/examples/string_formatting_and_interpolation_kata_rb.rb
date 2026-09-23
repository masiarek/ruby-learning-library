# Kata: an aligned table -- names left-justified, quantities right-justified,
# prices with two decimals and a thousands separator, and a total line.
def money(amount)
  whole, cents = format("%.2f", amount).split(".")
  "#{whole.gsub(/\B(?=(\d{3})+(?!\d))/, ",")}.#{cents}"
end

items = [["widget", 3, 4.5], ["gadget", 12, 1234.567], ["gizmo", 1, 0.5]]
puts format("%-10s %5s %12s", "item", "qty", "price")
puts "-" * 29
items.each do |name, qty, price|
  puts format("%-10s %5d %12s", name, qty, money(price))
end
puts "-" * 29
puts format("%-10s %5d %12s", "total", items.sum { |_, q, _| q }, money(items.sum { |_, q, p| q * p }))
