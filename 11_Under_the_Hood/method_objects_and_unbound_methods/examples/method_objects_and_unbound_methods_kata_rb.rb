# Kata: describe any Method or UnboundMethod in one line -- its name, its
# owner, how many required and optional positional parameters it takes,
# and whether it is bound to a receiver.

class Greeter
  def initialize(name)
    @name = name
  end

  def greet(greeting, punct = "!")
    "#{greeting}, #{@name}#{punct}"
  end

  def inspect
    "#<Greeter #{@name}>"
  end
end

def describe(m)
  kinds = m.parameters.map(&:first)
  required = kinds.count(:req)
  optional = kinds.count(:opt)
  bound = m.respond_to?(:receiver) ? "bound to #{m.receiver.inspect}" : "unbound"
  format("%-6s from %-8s required=%d optional=%d  %s", m.name, m.owner, required, optional, bound)
end

puts describe(Greeter.new("Ada").method(:greet))
puts describe(Greeter.instance_method(:greet))
puts describe(1.method(:+))
puts describe(method(:puts))
puts describe(Array.instance_method(:push))
