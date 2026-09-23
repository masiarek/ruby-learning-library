# Exercise 1: a Recorder proxy on BasicObject. It forwards every call to the
# target and keeps the names, and because BasicObject has no `class`, `nil?`
# or `inspect`, those calls are recorded and forwarded too.

class Recorder < BasicObject
  def initialize(target)
    @target = target
    @calls = []
  end

  def __calls = @calls

  def method_missing(name, *args, &blk)
    @calls << name
    @target.__send__(name, *args, &blk)
  end
end

rec = Recorder.new(%w[pear apple fig])

puts "rec.size            #{rec.size}"
puts "rec.first           #{rec.first}"
puts "rec.sort            #{rec.sort.inspect}"
puts "rec.class           #{rec.class}"
puts "rec.nil?            #{rec.nil?}"
puts "rec.inspect         #{rec.inspect}"
puts "rec.map(&:upcase)   #{rec.map(&:upcase).inspect}"
puts "recorded            #{rec.__calls.inspect}"
puts "rec.equal?(rec)     #{rec.equal?(rec)}   (equal? is BasicObject's own, so it was not recorded)"
