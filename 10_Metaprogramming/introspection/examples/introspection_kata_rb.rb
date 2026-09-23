# introspection_kata_rb.rb — describe(obj): class, own methods with parameters, instance variables.

class Account
  include Comparable
  attr_reader :owner, :balance

  def initialize(owner, balance = 0) = (@owner, @balance = owner, balance)
  def deposit(amount, note: nil) = (@balance += amount; self)
  def withdraw(amount, *fees, **options) = (@balance -= amount + fees.sum; self)
  def <=>(other) = balance <=> other.balance
end

def describe(obj)
  klass = obj.class
  puts "class:     #{klass}"
  puts "ancestors: #{klass.ancestors.take_while { |a| a != Object }.inspect}"
  puts "ivars:     " + obj.instance_variables.map { |v| "#{v} = #{obj.instance_variable_get(v).inspect}" }.join(", ")
  puts "methods:"
  klass.instance_methods(false).sort.each do |name|
    params = klass.instance_method(name).parameters.map { |kind, pname| "#{pname}:#{kind}" }
    puts format("  %-10s (%s)", name, params.join(", "))
  end
end

describe(Account.new("Ada", 100).deposit(50, note: "gift"))
