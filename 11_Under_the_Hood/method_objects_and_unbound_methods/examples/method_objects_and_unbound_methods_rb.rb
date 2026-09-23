# A method is a value once you ask for it: `obj.method(:name)` hands back a
# Method bound to obj; `Klass.instance_method(:name)` hands back an
# UnboundMethod that can be bound to any instance of Klass later.

class Greeter
  def initialize(name)
    @name = name
  end

  def greet(greeting, punct = "!")
    "#{greeting}, #{@name}#{punct}"
  end

  alias_method :hello, :greet

  def inspect
    "#<Greeter #{@name}>"
  end
end

class Loud < Greeter
  def greet(greeting, punct = "!")
    super.upcase
  end
end

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value.inspect)
end

ada = Greeter.new("Ada")
m = ada.method(:greet)

row 1, "ada.method(:greet).class", m.class
row 2, "call it: m.call(\"Hi\"), m.(\"Hi\"), m[\"Hi\"]", [m.call("Hi"), m.("Hi"), m["Hi"]]
row 3, "m.name, m.owner", [m.name, m.owner]
row 4, "m.receiver, m.receiver.equal?(ada)", [m.receiver, m.receiver.equal?(ada)]
row 5, "m.arity, m.parameters", [m.arity, m.parameters]

u = m.unbind
row 6, "m.unbind.class, == Greeter.instance_method(:greet)", [u.class, u == Greeter.instance_method(:greet)]
bob = Greeter.new("Bob")
row 7, "u.bind(bob).call(\"Yo\"), u.bind_call(bob, \"Yo\")", [u.bind(bob).call("Yo"), u.bind_call(bob, "Yo")]
row 8, "u.bind(\"a string\") raises", (u.bind("a string") rescue $!.class)
eve = Loud.new("Eve")
row 9, "Greeter's greet bound to a Loud (a subclass) instance", u.bind_call(eve, "Hi")

lm = eve.method(:greet)
row 10, "eve.method(:greet).owner, .super_method.owner", [lm.owner, lm.super_method.owner]
row 11, "eve.method(:greet).super_method.call(\"Hi\")", lm.super_method.call("Hi")
row 12, "...super_method.super_method (nothing above)", lm.super_method.super_method

row 13, "m.to_proc.class, m.to_proc.lambda?", [m.to_proc.class, m.to_proc.lambda?]
row 14, "%w[Hi Yo].map(&ada.method(:greet))", %w[Hi Yo].map(&ada.method(:greet))
row 15, "ada.method(:hello).name, .original_name", [ada.method(:hello).name, ada.method(:hello).original_name]
row 16, "m == ada.method(:greet), m.equal?(ada.method(:greet))", [m == ada.method(:greet), m.equal?(ada.method(:greet))]
row 17, "method(:puts).owner, method(:puts).receiver", [method(:puts).owner, method(:puts).receiver]
row 18, "1.method(:+).owner, 1.method(:+).call(2)", [1.method(:+).owner, 1.method(:+).call(2)]
row 19, "[1, 2, 3].map(&1.method(:+))", [1, 2, 3].map(&1.method(:+))
