# Kata: the `count = count + 1` trap. Reading `count` bare reaches the reader;
# assigning `count = ...` makes a local for the whole method, so a setter
# needs self.
class Counter
  attr_accessor :count
  def initialize = @count = 0

  def bump_wrong
    count = count + 1
  end

  def bump_right
    self.count += 1
  end

  def bump_ivar
    @count += 1
  end

  def read_bare = count
end

c = Counter.new
begin
  c.bump_wrong
rescue NoMethodError => e
  puts "1. bump_wrong  -> #{e.class}: #{e.message}"
end
puts "   (count = count + 1 makes count a local for the whole method, so the right-hand count is that local, nil)"
puts "2. bump_right  -> #{c.bump_right} (self.count += 1 reads through the reader and writes through the setter)"
puts "3. bump_ivar   -> #{c.bump_ivar} (@count += 1 skips both)"
puts "4. read_bare   -> #{c.read_bare} (a bare read still reaches the reader)"
puts "5. c.count     -> #{c.count}"
