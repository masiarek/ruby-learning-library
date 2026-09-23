# send_and_public_send_rb.rb — call a method by a name decided at run time.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

class Calc
  def add(a, b) = a + b
end

class Report
  def to_csv = "a,b"
  def to_text = "a b"
end

class Vault
  attr_reader :code
  def initialize = @code = 42
  private
  def secret = "the code is #{@code}"
end

class Mailer
  def send(message) = "mailing #{message.inspect}"   # shadows Kernel#send
  def deliver = "delivered"
end

calc = Calc.new
row 1, "calc.send(:add, 2, 3)", calc.send(:add, 2, 3)
row 2, 'calc.send("add", 2, 3) -- a String works too', calc.send("add", 2, 3)
fmt = "csv"
row 3, 'Report.new.send(:"to_#{fmt}"), fmt = "csv"', Report.new.send(:"to_#{fmt}").inspect
row 4, "1.send(:+, 2) -- operators are methods", 1.send(:+, 2)
row 5, "[1, 2, 3].send(:map) { it * 2 } -- block passes", [1, 2, 3].send(:map) { it * 2 }.inspect

vault = Vault.new
row 6, "vault.send(:code) -- a reader is a method call", vault.send(:code)
row 7, "vault.send(:secret) -- private, still called", vault.send(:secret).inspect
begin
  vault.public_send(:secret)
rescue NoMethodError => e
  row 8, "vault.public_send(:secret)", "#{e.class}: #{e.message}"
end
row 9, "respond_to?(:secret) / respond_to?(:secret, true)",
    "#{vault.respond_to?(:secret)} / #{vault.respond_to?(:secret, true)}"
begin
  vault.send(:nope)
rescue NoMethodError => e
  row 10, "vault.send(:nope) -> e.class, e.name", "#{e.class}, #{e.name.inspect}"
end

mailer = Mailer.new
row 11, "mailer.send(:deliver) -- send is overridden", mailer.send(:deliver).inspect
row "", "mailer.__send__(:deliver)", mailer.__send__(:deliver).inspect
row "", "mailer.public_send(:deliver)", mailer.public_send(:deliver).inspect
row 12, "owner of send / __send__ / public_send",
    [Object.instance_method(:send).owner,
     BasicObject.instance_method(:__send__).owner,
     Object.instance_method(:public_send).owner].join(" / ")
begin
  calc.send(:add, 1)
rescue ArgumentError => e
  row 13, "calc.send(:add, 1) -- arity is still checked", "#{e.class}: #{e.message}"
end
