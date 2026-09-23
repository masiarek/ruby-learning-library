# `@@count` is one variable for a class and every subclass; a class-level
# `@count` is one per class. Each row is printed by the Python twin too.

def row(n, label, value)
  puts format("%2d. %-58s %s", n, label, value)
end

def failing
  yield
rescue NameError, RuntimeError => e
  "#{e.class}: #{e.message}"
end

class Base
  @@count = 0                              # one slot, owned by Base, seen by every subclass
  @@items = []
  @count = 0                               # a class-level instance variable: Base's own

  class << self
    attr_accessor :count_ivar
  end
  self.count_ivar = 0

  def self.count = @@count
  def self.items = @@items
  def instance_reads = @@count             # instance methods see the same @@count
  def instance_writes = @@count = 7
end

class Sub < Base
  def self.bump = @@count += 1             # Sub assigns: it is Base's slot that changes
  def self.assign(v) = @@count = v
  def self.push(v) = @@items << v
end

row 1, "@@count set in Base, read through Sub", Sub.count.to_s
Sub.bump
row 2, "Sub.bump does @@count += 1 -- Base.count / Sub.count", "#{Base.count} / #{Sub.count}"
Sub.assign(100)
row 3, "Sub assigns @@count = 100 -- Base.count / Sub's own?",
    "#{Base.count} / #{Sub.class_variables(false).include?(:@@count)} (class_variables(false))"
row 4, "an instance method reads @@count", Base.new.instance_reads.to_s
Base.new.instance_writes
row 5, "an instance method assigns @@count = 7 -- Base.count", Base.count.to_s
row 6, "class-level @count_ivar -- Base's / Sub's",
    "#{Base.count_ivar.inspect} / #{Sub.count_ivar.inspect}"
Sub.push(1)
row 7, "@@items = []; Sub.push(1) -- Base.items", Base.items.inspect
row 8, "class_variable_get / class_variables / defined?(:@@nope)",
    "#{Base.class_variable_get(:@@count)} / #{Base.class_variables.sort.inspect} / #{Base.class_variable_defined?(:@@nope)}"
row 9, "Base.class_variable_get(:@@nope)", failing { Base.class_variable_get(:@@nope) }

class Early < Base
  @@fresh = 1                              # 10. the subclass defines it first...
  def self.fresh = @@fresh
end
class Base
  @@fresh = 2                              # ...then the superclass does: Early's is overtaken
end
row 10, "@@fresh set in Early, then in Base -- Early.fresh", failing { Early.fresh }

row 11, "@@count read at the top level, outside any class",
    failing { eval("@@count", TOPLEVEL_BINDING) }
