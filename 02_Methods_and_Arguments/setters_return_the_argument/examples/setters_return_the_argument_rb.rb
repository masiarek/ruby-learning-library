# `obj.x = 5` is a call to the method `x=` -- but as an expression it
# evaluates to 5, whatever the method body returns. Only `send(:x=, 5)`
# shows the body's value. The same holds for `[]=`, `+=` and `||=`.

class Box
  attr_reader :x
  attr_writer :w

  def x=(value)
    @x = value
    :ignored
  end

  def []=(key, value)
    (@h ||= {})[key] = value
    :ignored_too
  end

  def [](key) = (@h ||= {})[key]

  def set_wrong(value)
    x = value
    x
  end

  def set_right(value)
    self.x = value
  end
end

class Bag
  def method_missing(name, *args)
    return super unless name.end_with?("=")

    (@stored ||= {})[name.to_s.chomp("=").to_sym] = args.first
    :ignored_three
  end

  def respond_to_missing?(name, include_private = false) = name.end_with?("=") || super
  attr_reader :stored
end

def attempt
  yield.inspect
rescue NoMethodError => e
  "#{e.class}: #{e.message}"
end

b = Box.new
r = (b.x = 5)
puts "1. assignment is an expression:   r = (b.x = 5)         -> r is #{r.inspect}, b.x is #{b.x.inspect} (the body's :ignored is discarded)"
puts "2. the body's value via send:     b.send(:x=, 6)        -> #{b.send(:x=, 6).inspect}; b.method(:x=).call(7) -> #{b.method(:x=).call(7).inspect}"
puts "3. attr_writer:                   (b.w = 3)             -> #{(b.w = 3).inspect}; b.w -> #{attempt { b.w }}"
b.x = 1, 2
puts "4. two values on the right:       b.x = 1, 2; b.x       -> #{b.x.inspect} (an #{b.x.class})"
puts "5. inside the class, self is required: b.set_wrong(50)  -> #{b.set_wrong(50)}, b.x still #{b.x.inspect}; b.set_right(60) -> #{b.set_right(60)}, b.x now #{b.x.inspect}"
a = b.x = 9
puts "6. chained assignment:            a = b.x = 9           -> a is #{a}, b.x is #{b.x}"
puts "7. []= too:                       (b[:k] = \"v\")         -> #{(b[:k] = "v").inspect}; b.send(:[]=, :k2, \"v2\") -> #{b.send(:[]=, :k2, "v2").inspect}"
puts "8. += and ||= go through the pair: (b.x += 1)           -> #{(b.x += 1)}, b.x is #{b.x}; (Box.new.x ||= 100) -> #{(Box.new.x ||= 100)}"
bag = Bag.new
puts "9. no universal hook:             bag.color = \"red\"     -> #{(bag.color = "red").inspect} via method_missing; bag.stored -> #{bag.stored.inspect}; bag.send(:color=, \"blue\") -> #{bag.send(:color=, "blue").inspect}"
