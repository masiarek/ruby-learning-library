# send_and_public_send_kata_rb.rb — dispatch(obj, name, *args): ask before sending.

class Calc
  def add(a, b) = a + b
end

class Vault
  private
  def secret = "the code"
end

def dispatch(obj, name, *args)
  return :unknown unless obj.respond_to?(name)   # private methods answer false here
  obj.public_send(name, *args)
end

puts "1. dispatch(Calc.new, :add, 2, 3)      -> #{dispatch(Calc.new, :add, 2, 3).inspect}"
puts "2. dispatch(Vault.new, :secret)        -> #{dispatch(Vault.new, :secret).inspect}"
puts "3. dispatch(Calc.new, :addd, 2, 3)    -> #{dispatch(Calc.new, :addd, 2, 3).inspect}"
op = "add"
puts "4. dispatch(Calc.new, format(\"%s\", op), 5, 6) -> #{dispatch(Calc.new, format("%s", op), 5, 6).inspect}"
