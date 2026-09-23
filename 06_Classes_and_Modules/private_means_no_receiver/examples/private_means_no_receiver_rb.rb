# `private` forbids an explicit receiver; `protected` allows one of the same class.
# Each numbered row below is printed by the Python twin too, in the same order.

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

def failing
  yield
rescue NoMethodError, NameError => e
  "#{e.class}: #{e.message}"
end

class Account
  def initialize(owner, balance)
    @owner = owner
    @balance = balance
  end

  def inspect = "#<Account #{@owner}>"

  def self.open(owner) = new(owner, 0)   # the factory, once new is private
  private_class_method :new

  def receiverless_call = audit           # 2. no receiver: allowed
  def self_dot_call = self.audit          # 3. self. receiver: allowed since 2.7
  def set_through_self = (self.total = 1) # 9. a private writer needs self. -- always allowed

  def ==(other) = other.is_a?(Account) && balance == other.balance   # 4. other.balance: protected lets it through

  protected

  def balance = @balance                  # 4. callable on another Account, from inside Account

  private                                 # 7a. everything below is private

  def audit = "audited #{@owner}"

  def total=(value)
    @total = value
  end

  public

  def helper1 = :h1
  private :helper1                        # 7b. mark one name after the fact

  private def helper2 = :h2               # 7c. def returns a Symbol; private takes it
end

acct = Account.open("ann")
other = Account.open("bob")

row 1, "acct.audit -- private, explicit receiver", failing { acct.audit }
row 2, "inside the class, plain audit", acct.receiverless_call.inspect
row 3, "inside the class, self.audit (since 2.7)", acct.self_dot_call.inspect
row 4, "protected balance: acct == other / acct.balance",
    "#{acct == other} / #{failing { acct.balance }}"
row 5, "private_class_method :new -- Account.new",
    "#{failing { Account.new("x", 0) }}; Account.open works: #{Account.open("x").inspect}"
row 6, "send(:audit) / public_send(:audit)",
    "#{acct.send(:audit).inspect} / #{failing { acct.public_send(:audit) }}"
row 7, "private_instance_methods(false).sort", Account.private_instance_methods(false).sort.inspect
row 8, "protected / public instance methods (false)",
    "#{Account.protected_instance_methods(false).inspect} / #{Account.public_instance_methods(false).sort.inspect}"
row 9, "a private writer called as self.total = 1", acct.set_through_self.inspect
row 10, "respond_to?(:audit) / respond_to?(:audit, true)",
    "#{acct.respond_to?(:audit)} / #{acct.respond_to?(:audit, true)}"
