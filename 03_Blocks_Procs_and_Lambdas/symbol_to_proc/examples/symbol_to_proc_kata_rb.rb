# Exercise 1: a class whose to_proc lets & accept it, and a hand-written
# Symbol#to_proc -- a lambda that calls the named method on its first
# argument and passes the rest along, which is all the real one does.

class Multiplier
  def initialize(factor) = @factor = factor
  def to_proc = ->(x) { x * @factor }
end

def sym_proc(name)
  ->(receiver, *args) { receiver.public_send(name, *args) }
end

p [1, 2].map(&Multiplier.new(3))
p %w[a b].map(&sym_proc(:upcase))
p [1, 2, 3].inject(&sym_proc(:+))
p %w[bb a ccc].max_by(&sym_proc(:size))

# public_send is what makes it behave like &:sym on a private method:
begin
  [1].map(&sym_proc(:puts))
rescue NoMethodError => e
  puts "#{e.class}: #{e.message}"
end
