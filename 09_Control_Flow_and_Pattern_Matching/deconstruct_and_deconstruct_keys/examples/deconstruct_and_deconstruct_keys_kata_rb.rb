# Exercise 1: a Money class that answers array and hash patterns, printing
# which keys each hash pattern asked for.

class Money
  attr_reader :amount, :currency

  def initialize(amount, currency) = (@amount, @currency = amount, currency)

  def deconstruct = [amount, currency]

  def deconstruct_keys(keys)
    puts "   deconstruct_keys asked for #{keys.inspect}"
    {amount: amount, currency: currency}
  end
end

price = Money.new(5, "EUR")

case price
in [a, c]
  puts "in [a, c]                    -> #{a} #{c}"
end

case price
in Money(currency: "EUR")
  puts "in Money(currency: \"EUR\")   -> matched a euro amount"
end

case price
in {amount:, **rest}
  puts "in {amount:, **rest}         -> amount #{amount}, rest #{rest.inspect}"
end
