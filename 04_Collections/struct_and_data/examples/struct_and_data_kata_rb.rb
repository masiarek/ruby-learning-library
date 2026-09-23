# Kata: an immutable Money value with Data.define -- a normalising initialize,
# a parser, an operator that returns a new object, `with` for a change, and
# use as a Hash key.

Money = Data.define(:cents, :currency) do
  def self.parse(text)                       # "12.50 eur" -> Money
    amount, currency = text.split
    new(cents: (Float(amount) * 100).round, currency: currency)
  end

  def initialize(cents:, currency: "EUR") = super(cents: Integer(cents), currency: currency.upcase)

  def +(other)
    raise ArgumentError, "#{currency} + #{other.currency}" unless currency == other.currency
    with(cents: cents + other.cents)
  end

  def to_s = format("%.2f %s", cents / 100.0, currency)
end

a = Money.parse("12.50 eur")
b = Money.new(cents: "250")
puts "a = #{a}, b = #{b}"
puts "a + b = #{a + b}; a is still #{a}"
puts "a == Money.new(1250)? #{a == Money.new(1250)}  (positional, currency defaulted)"
puts "as a Hash key: #{{a => :paid}[Money.new(cents: 1250, currency: 'eur')].inspect}"
begin
  a + Money.new(cents: 100, currency: "usd")
rescue ArgumentError => e
  puts "mixed currencies: #{e.class}: #{e.message}"
end
begin
  a.cents = 0
rescue NoMethodError => e
  puts "a.cents = 0: #{e.class}"
end
puts "inspect: #{a.inspect}"
