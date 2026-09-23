# A constant is found by lexical scope first, then through ancestors, then in
# Object -- so the same name can mean different things in two places.
# Each numbered row below is printed by the Python twin too, in the same order.

require "open3"
require "rbconfig"

def row(n, label, value)
  puts format("%2d. %-58s %s", n, label, value)
end

def failing
  yield
rescue NameError => e
  "#{e.class}: #{e.message}"
end

TOP = "top-level"

module Outer
  LIMIT = 10

  class Inner                                 # 1. nested form: Outer is in the lexical scope
    def self.nesting = Module.nesting
    def self.limit = LIMIT
  end
end

class Outer::Compact                          # 2. compact form: only Outer::Compact is
  def self.nesting = Module.nesting
  def self.limit = LIMIT
end

row 1, "nested class: Module.nesting / LIMIT", "#{Outer::Inner.nesting.inspect} / #{Outer::Inner.limit}"
row 2, "compact class Outer::Compact: Module.nesting / LIMIT",
    "#{Outer::Compact.nesting.inspect} / #{failing { Outer::Compact.limit }}"

class Parent
  LIMIT = 20
end

class Child < Parent
  def self.limit = LIMIT                      # 3. not lexical: found through ancestors
  def self.top = TOP                          # 4. not lexical, not inherited: found in Object
end
row 3, "Child < Parent: LIMIT found through ancestors", Child.limit.to_s
row 4, "TOP from inside Child: top-level constants live in Object",
    "#{Child.top} / Object.const_defined?(:TOP): #{Object.const_defined?(:TOP)}"

child = "X = 1; X = 2; print X"
out, err, = Open3.capture3(RbConfig.ruby, "-e", child)      # no -w: this warning is on by default
warnings = err.lines.filter_map { |line| line[/warning: .*/] }
row 5, "X = 1; X = 2 in a child (no -w): it prints / warns",
    "#{out.inspect} / #{warnings.join("; ")}"

module Shop
  TAX = 0.2
  def self.tax = "method tax"
end
row 6, "Shop::TAX / Shop.tax / Shop::tax (lowercase = a call)",
    "#{Shop::TAX} / #{Shop.tax} / #{Shop::tax}"

row 7, "const_get(:TAX) / constants / const_defined?(:NOPE)",
    "#{Shop.const_get(:TAX)} / #{Shop.constants.sort.inspect} / #{Shop.const_defined?(:NOPE)}"

def Shop.const_missing(name) = "const_missing saw #{name}"   # 8. the hook, like method_missing
row 8, "Shop::NOPE with const_missing defined", Shop::NOPE.inspect

LIST = [1]
LIST << 2                                     # 9. the binding is constant; the object is not
row 9, "LIST = [1]; LIST << 2 -- LIST / LIST.frozen?", "#{LIST.inspect} / #{LIST.frozen?}"

module Greeter
  NAME = "greeter"
  def who = NAME                              # 10. lexical: Greeter's NAME, whoever includes it
  def whose = self.class::NAME                #     dynamic: the receiver's class's NAME
end

class Robot
  include Greeter
  NAME = "robot"
end
row 10, "module method: bare NAME / self.class::NAME, on a Robot",
    "#{Robot.new.who.inspect} / #{Robot.new.whose.inspect}"
