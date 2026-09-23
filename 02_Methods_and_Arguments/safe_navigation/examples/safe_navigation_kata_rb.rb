# Kata: each user's city or "(none)", three ways: &., dig, and || {} + fetch.
users = [
  { name: "ann", address: { city: "Oslo" } },
  { name: "bo" },
  { name: "cy", address: nil },
]

puts "1. with &.:"
users.each { |u| puts "   #{u[:name]}: #{(u[:address]&.fetch(:city, nil)).inspect}" }
puts "2. with dig:"
users.each { |u| puts "   #{u[:name]}: #{u.dig(:address, :city).inspect}" }
puts "3. with || {} and fetch's default:"
users.each { |u| puts "   #{u[:name]}: #{(u[:address] || {}).fetch(:city, "(none)")}" }
