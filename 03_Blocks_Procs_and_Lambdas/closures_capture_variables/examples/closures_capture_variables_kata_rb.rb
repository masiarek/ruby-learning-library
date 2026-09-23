# Exercise 1: make_account(balance) returns three lambdas that share one
# balance variable; two accounts do not interfere, because each call of
# make_account has its own balance.

def make_account(balance)
  deposit  = ->(amount) { balance += amount }
  withdraw = ->(amount) { amount <= balance ? (balance -= amount) : "refused: #{amount} > #{balance}" }
  read     = -> { balance }
  { deposit: deposit, withdraw: withdraw, balance: read }
end

a = make_account(100)
b = make_account(5)

puts "a deposit 50   -> #{a[:deposit].call(50)}"
puts "a withdraw 30  -> #{a[:withdraw].call(30)}"
puts "b withdraw 30  -> #{b[:withdraw].call(30)}"
puts "a balance      -> #{a[:balance].call}"
puts "b balance      -> #{b[:balance].call}"
puts "shared inside a: deposit and read see one variable: #{a[:deposit].call(0) == a[:balance].call}"
