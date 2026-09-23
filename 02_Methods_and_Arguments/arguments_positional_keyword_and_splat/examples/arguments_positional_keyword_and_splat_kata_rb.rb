# Kata: one method with a required, an optional, a splat, a required keyword
# and a defaulted keyword -- called four good ways and three bad ones.
def order(item, qty = 1, *extras, priority:, note: "")
  [item, qty, extras, priority, note]
end

def attempt
  yield.inspect
rescue ArgumentError => e
  "#{e.class}: #{e.message}"
end

puts "1. order(:tea, priority: :low)                     -> #{attempt { order(:tea, priority: :low) }}"
puts "2. order(:tea, 2, priority: :low)                  -> #{attempt { order(:tea, 2, priority: :low) }}"
puts "3. order(:tea, 2, :milk, :sugar, priority: :high)  -> #{attempt { order(:tea, 2, :milk, :sugar, priority: :high) }}"
puts "4. order(:tea, priority: :low, note: \"decaf\")      -> #{attempt { order(:tea, priority: :low, note: "decaf") }}"
puts "5. order(:tea)                                     -> #{attempt { order(:tea) }}"
puts "6. order(:tea, priority: :low, size: :large)       -> #{attempt { order(:tea, priority: :low, size: :large) }}"
puts "7. order(priority: :low)                           -> #{attempt { order(priority: :low) }}"
