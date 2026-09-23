# A module is a namespace: it holds classes, constants and methods, and it can
# never be instantiated. Each row is printed by the Python twin too.

def row(n, label, value)
  puts format("%2d. %-62s %s", n, label, value)
end

def failing
  yield
rescue NoMethodError => e
  "#{e.class}: #{e.message}"
end

class Item                                 # a top-level Item...
  def inspect = "#<Item (top level)>"
end

module Shop
  VERSION = "1.0"

  def self.version = "Shop #{VERSION}"     # 4. a module method

  class Cart                               # 1. a class inside the namespace
    def inspect = "#<Shop::Cart>"
  end

  class Item                               # 2. ...and Shop's own Item: a different class
    def inspect = "#<Shop::Item>"
  end

  def self.both_items = [Item, ::Item]     # 7. the near one, and the top-level one
end

module Warehouse
  class Item
    def inspect = "#<Warehouse::Item>"
  end
end

module Util
  module_function                          # 3. every def below: a module method AND a private instance method

  def slug(text) = text.downcase.tr(" ", "-")
end

class Post
  include Util
  def path = "/" + slug("Hello World")     # the private instance method, receiverless
end

row 1, "module Shop; class Cart -- Shop::Cart.name / .new", "#{Shop::Cart.name} / #{Shop::Cart.new.inspect}"
row 2, "Shop::Item, Warehouse::Item, ::Item -- the same class?",
    "#{Shop::Item.equal?(Warehouse::Item)} / #{Shop::Item.equal?(::Item)} (#{Shop::Item.new.inspect}, #{Warehouse::Item.new.inspect})"
row 3, "module_function: Util.slug / Post.new.path / Post.new.slug",
    "#{Util.slug("Hello World").inspect} / #{Post.new.path.inspect} / #{failing { Post.new.slug("x") }}"
row 4, "def self.version -- Shop.version / singleton_methods.sort",
    "#{Shop.version.inspect} / #{Shop.singleton_methods.sort.inspect}"
row 5, "Math::PI.round(2) / Math.sqrt(16) / Math::sqrt(16)",
    "#{Math::PI.round(2)} / #{Math.sqrt(16)} / #{Math::sqrt(16)}"
row 6, ":: for a constant, . for a method -- Shop.Cart", failing { Shop.Cart }
row 7, "inside Shop: [Item, ::Item]", Shop.both_items.inspect
row 8, "a module cannot be instantiated -- Shop.new", failing { Shop.new }
row 9, "Shop.constants.sort / Shop.const_get(:Cart)",
    "#{Shop.constants.sort.inspect} / #{Shop.const_get(:Cart)}"
row 10, "Shop.class / Class.superclass (a class is a module + new)",
    "#{Shop.class} / #{Class.superclass}"
