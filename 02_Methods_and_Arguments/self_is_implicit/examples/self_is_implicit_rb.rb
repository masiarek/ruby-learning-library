# Every call has a receiver; when none is written, it is `self`: main at the
# top level, the class inside `class ... end`, the instance inside a method.
# Reading a bare name reaches a method, but `name = v` makes a local, so a
# setter needs `self.name = v`.

puts "1. self at the top level:         #{self.inspect} (an instance of #{self.class})"

class Person
  puts "2. self in a class body:          #{self} (an instance of #{self.class})"
  attr_accessor :name

  def initialize(name) = @name = name
  def whoami = self
  def greet = "hi from #{name}"

  def rename_wrong(v)
    name = v
    name
  end

  def rename_right(v)
    self.name = v
  end

  def self.species = "a class method: self is #{self}"
  def secret_bare = secret
  def secret_via_self = self.secret
  def peek(other) = other.secret
  def in_block = [1].map { self }
  def to_s = "Person(#{@name})"
  def inspect = to_s

  private

  def secret = "the secret of #{@name}"
end

a = Person.new("ann")
puts "3. self in an instance method:    a.whoami -> #{a.whoami}, a.whoami.equal?(a) -> #{a.whoami.equal?(a)}"
puts "4. a receiverless call goes to self: a.greet -> #{a.greet.inspect} (greet called name with no receiver)"
puts "5. self in def self.species:      #{Person.species}"
puts "6. the setter trap:               a.rename_wrong(\"bo\") -> #{a.rename_wrong("bo").inspect}, but a.name is still #{a.name.inspect} (name = v made a local)"
puts "                                  a.rename_right(\"bo\") -> #{a.rename_right("bo").inspect}, and a.name is now #{a.name.inspect} (self.name = v called the setter)"
puts "7. private methods and self:      secret (bare) -> #{a.secret_bare.inspect}; self.secret -> #{a.secret_via_self.inspect}"
begin
  a.peek(Person.new("cy"))
rescue NoMethodError => e
  puts "                                  other.secret -> #{e.class}: #{e.message}"
end

class Counter
  attr_accessor :count
  def initialize = @count = 0

  def bump_wrong
    count = count + 1
  end

  def bump_right
    self.count += 1
  end

  def read_bare = count
end

c = Counter.new
begin
  c.bump_wrong
rescue NoMethodError => e
  puts "8. count = count + 1:             #{e.class}: #{e.message} (the local count shadows the reader and starts as nil)"
end
puts "   self.count += 1:               -> #{c.bump_right}, c.count is #{c.count}; a bare read still works: read_bare -> #{c.read_bare}"
puts "9. self inside a block:           a.in_block -> #{a.in_block.inspect} (the enclosing self, not the block)"
def top_level_method = "self here is #{self}"
puts "10. a top-level def:              top_level_method -> #{top_level_method.inspect}; Object.private_method_defined?(:top_level_method) -> #{Object.private_method_defined?(:top_level_method)}"
