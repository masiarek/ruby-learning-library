# An instance variable is reachable only through a method of its object.
# Each numbered row below is printed by the Python twin too, in the same order.

def row(n, label, value)
  puts format("%2d. %-50s %s", n, label, value)
end

def failing
  yield
rescue NoMethodError => e
  "#{e.class}: #{e.message}"
end

class Account
  def initialize(owner)
    @owner = owner          # no reader, no writer: only methods of Account can see it
  end

  def inspect = "#<Account owner=#{@owner.inspect}>"

  def nickname = @nickname  # @nickname was never assigned: it reads as nil, no error
end

acct = Account.new("ann")

row 1, "acct.owner with no reader defined", failing { acct.owner }

class Account
  attr_reader :owner        # defines def owner; @owner; end
end
row 2, "after attr_reader :owner, acct.owner", acct.owner.inspect

class Account
  attr_accessor :balance    # defines balance and balance=
end
acct.balance = 10
row 3, "after attr_accessor :balance, acct.balance = 10", acct.balance.inspect

row 4, "acct.owner = \"bob\" with no writer", failing { acct.owner = "bob" }

row 5, "the back door: instance_variable_get(:@owner)", acct.instance_variable_get(:@owner).inspect

row 6, "acct.instance_variables", acct.instance_variables.inspect

row 7, "unset @nickname read inside a method",
    "#{acct.nickname.inspect} (instance_variable_defined? #{acct.instance_variable_defined?(:@nickname)})"

class Account
  def hide = @__secret = 42          # a double underscore is just part of the name
end
acct.hide
row 8, "@__secret is stored under its own name", acct.instance_variables.last.inspect

acct.instance_variable_set(:@extra, 1) # any object accepts a new ivar at any time
row 9, "a new ivar added after the fact", "#{acct.instance_variables.include?(:@extra)} (no way to forbid it)"

other = Account.new("bob")
row 10, "two instances, two sets of ivars", "#{acct.owner} / #{other.owner} (balance of other: #{other.balance.inspect})"
