# Object defines no methods of its own: everything an object can do comes
# from Kernel (mixed in) or BasicObject (the root). The Python twin,
# basic_object_and_kernel_py.py, prints the same numbered rows.

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-46s %s", label, value))

PRIVATE = %i[puts p print require raise lambda proc loop rand format Integer exit]
PUBLIC = %i[inspect to_s respond_to? is_a? class nil? send freeze dup instance_variable_get]

section 1, "three things at the top"
row "Object.ancestors", Object.ancestors.inspect
row "Object.superclass", Object.superclass
row "BasicObject.superclass", BasicObject.superclass.inspect
row "Kernel.class", Kernel.class
row "Object.instance_methods(false)", Object.instance_methods(false).inspect
row "Object.private_instance_methods(false).sort", Object.private_instance_methods(false).sort.inspect

section 2, "BasicObject: the smallest object there is"
row "BasicObject.instance_methods.sort", BasicObject.instance_methods.sort.inspect
row "BasicObject.private_instance_methods.sort", BasicObject.private_instance_methods.sort.inspect

section 3, "Kernel: the methods every object has"
row "private, called without a receiver:", PRIVATE.join(" ")
row "  all in Kernel.private_instance_methods", PRIVATE.all? { |m| Kernel.private_instance_methods.include?(m) }
row "public:", PUBLIC.join(" ")
row "  all in Kernel.instance_methods", PUBLIC.all? { |m| Kernel.instance_methods.include?(m) }
row "method(:puts).owner", method(:puts).owner
row "5.method(:puts).owner", 5.method(:puts).owner
row "Kernel.singleton_methods.include?(:puts)", Kernel.singleton_methods.include?(:puts)
row "self.to_s / self.class  (top level)", "#{self} / #{self.class}"

section 4, "a BasicObject subclass has none of it"

class Bare < BasicObject
  def try_puts = puts("inside")
  def try_raise = raise("inside")
  def try_string = String
  def via_kernel = ::Kernel.puts("   (::Kernel.puts works from inside Bare)")
  def via_root = ::String.name
end

bare = Bare.new
begin
  bare.try_puts
rescue NoMethodError => e
  row "puts inside Bare", "#{e.class}: #{e.message}"
end
begin
  bare.try_raise
rescue NoMethodError => e
  row "raise inside Bare", "#{e.class}: #{e.message}"
end
begin
  bare.try_string
rescue NameError => e
  row "String inside Bare", "#{e.class}: #{e.message}"
end
bare.via_kernel
row "::String.name inside Bare", bare.via_root
begin
  bare.inspect
rescue NoMethodError => e
  row "bare.inspect", "#{e.class}: #{e.message}"
end
begin
  bare.class
rescue NoMethodError => e
  row "bare.class", e.class
end
begin
  p bare
rescue NoMethodError => e
  row "p bare  (p calls inspect)", e.class
end
row "bare == Bare.new", bare == Bare.new
row "bare.equal?(bare)", bare.equal?(bare)
row "!bare", !bare
row "bare.instance_eval { @x = 1; @x }", bare.instance_eval { @x = 1; @x }
row "BasicObject === bare / Object === bare", "#{BasicObject === bare} / #{Object === bare}"

section 5, "a proxy: method_missing forwards everything, even class"

class Proxy < BasicObject
  def initialize(target) = @target = target

  def method_missing(name, *args, &blk)
    ::Kernel.puts "   (forwarding #{name})"
    @target.__send__(name, *args, &blk)
  end
end

pr = Proxy.new([3, 1, 2])
row "pr.sort", pr.sort.inspect
row "pr.size", pr.size
row "pr.class", pr.class
row "pr.inspect", pr.inspect
row "pr.respond_to?(:sort)", pr.respond_to?(:sort)
row "Proxy.instance_methods(false)", Proxy.instance_methods(false).inspect
row "Proxy.ancestors", Proxy.ancestors.inspect
