# raise_has_four_forms_rb.rb -- raise "msg", raise Klass, raise Klass, "msg" and
# raise Klass.new("msg"); a bare raise inside and outside a rescue; the backtrace
# argument; fail; raising a non-exception; $! and $@; and the Klass.exception hook.

def report
  yield
rescue Exception => e
  puts "   #{e.class}: #{e.message.inspect}"
end

puts "1. raise \"msg\" makes a RuntimeError"
report { raise "just a message" }

puts "2. raise Klass makes an instance whose message is the class name"
report { raise ArgumentError }

puts "3. raise Klass, \"msg\""
report { raise ArgumentError, "with a message" }

puts "4. raise Klass.new(\"msg\"); and raise obj, \"msg\" replaces the message"
report { raise ArgumentError.new("an instance") }
report { raise ArgumentError.new("original"), "replaced" }

puts "5. a bare raise inside rescue re-raises the same object"
begin
  begin
    raise IOError, "inner"
  rescue IOError => inner
    raise
  end
rescue IOError => outer
  puts "   outer got #{outer.class}: #{outer.message.inspect}; same object: #{outer.equal?(inner)}"
end

puts "6. a bare raise outside any rescue: a RuntimeError with an empty message"
report { raise }

puts "7. a third argument sets the backtrace"
begin
  raise ArgumentError, "blame someone else", ["frame_a", "frame_b"]
rescue => e
  puts "   e.backtrace #{e.backtrace.inspect}"
end
def check(value)
  raise ArgumentError, "bad value", caller unless value
end
def validate = check(nil)
begin
  validate
rescue => e
  puts "   with caller: the first entry is in #{e.backtrace.first[/in '(.*)'/, 1].inspect}, not in check"
end

puts "8. fail is an alias of raise"
report { fail "fail is raise" }

puts "9. raising something that is not an exception"
report { raise 42 }
report { raise Object }
report { raise "a", "b" }

puts "10. $! and $@ inside rescue, and after it"
begin
  raise "boom"
rescue => e
  puts "   $!.equal?(e)            #{$!.equal?(e)}"
  puts "   $@.equal?(e.backtrace)  #{$@.equal?(e.backtrace)}"
end
puts "   $! after the rescue     #{$!.inspect}"

puts "11. raise Klass, args calls Klass.exception(*args)"
class Custom < StandardError
  def self.exception(*args)
    puts "   Custom.exception called with #{args.inspect}"
    super
  end
end
report { raise Custom }
report { raise Custom, "msg" }
