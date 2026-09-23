# Kata: a setter that clamps what it stores. The assignment still evaluates
# to the argument; only send shows what the body returned.
class Thermostat
  attr_reader :target

  def target=(degrees)
    @target = degrees.clamp(10, 30)
  end
end

t = Thermostat.new
r = (t.target = 99)
puts "1. r = (t.target = 99)      -> r is #{r} (the argument, unclamped)"
puts "2. t.target                 -> #{t.target} (the setter clamped what it stored)"
puts "3. t.send(:target=, 99)     -> #{t.send(:target=, 99)} (the body's value, visible only through send)"
puts "4. (t.target = 5), t.target -> #{(t.target = 5)}, #{t.target}"
