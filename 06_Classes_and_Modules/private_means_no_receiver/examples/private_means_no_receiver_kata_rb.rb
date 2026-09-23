# Exercise 1: a Vault whose `open` is public, whose `combination` is protected
# (so two vaults can compare themselves) and whose `audit_log` is private.

class Vault
  def initialize(combination)
    @combination = combination
  end

  def inspect = "#<Vault>"

  def open(code) = code == combination ? "open" : "locked"

  def ==(other) = other.is_a?(Vault) && combination == other.combination

  protected

  def combination = @combination

  private

  def audit_log = "audit: opened by #{combination}"
end

def attempt
  yield
rescue NoMethodError => e
  "#{e.class}: #{e.message}"
end

v = Vault.new(1234)
puts "v.open(1234):              #{v.open(1234)}"
puts "v.open(1):                 #{v.open(1)}"
puts "v == Vault.new(1234):      #{v == Vault.new(1234)}"
puts "v == Vault.new(9):         #{v == Vault.new(9)}"
puts "v.combination:             #{attempt { v.combination }}"
puts "v.audit_log:               #{attempt { v.audit_log }}"
puts "v.send(:audit_log):        #{v.send(:audit_log)}"
puts "v.public_send(:audit_log): #{attempt { v.public_send(:audit_log) }}"
