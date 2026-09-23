# exceptions_have_a_cause_rb.rb -- a raise inside a rescue records the exception it
# replaces as `cause`; cause: sets it by hand, cause: nil hides it; a chain of three;
# what full_message shows; circular causes; a raise inside ensure; cause is read-only.

class Low < StandardError; end
class Mid < StandardError; end
class High < StandardError; end

def chain_of(e)
  classes = []
  while e
    classes << e.class
    e = e.cause
  end
  classes
end

puts "1. a raise inside rescue sets cause automatically"
begin
  begin
    raise Low, "disk full"
  rescue Low
    raise High, "save failed"
  end
rescue High => e
  puts "   #{e.class}: #{e.message.inspect}; cause: #{e.cause.class}: #{e.cause.message.inspect}"
end

puts "2. cause: sets it explicitly, to any exception object"
kept = Low.new("kept aside")
begin
  raise High, "wrapped", cause: kept
rescue High => e
  puts "   e.cause.class #{e.cause.class}; the same object: #{e.cause.equal?(kept)}"
end

puts "3. cause: nil hides the exception being handled"
begin
  begin
    raise Low, "noise"
  rescue Low
    raise High, "clean", cause: nil
  end
rescue High => e
  puts "   e.cause #{e.cause.inspect}"
end

puts "4. a chain of three, walked with cause"
begin
  begin
    begin
      raise Low, "l"
    rescue Low
      raise Mid, "m"
    end
  rescue Mid
    raise High, "h"
  end
rescue High => e
  puts "   #{chain_of(e).inspect}"
  puts "5. what full_message prints about the chain (labels only)"
  e.full_message(highlight: false, order: :top).lines.reject { _1.start_with?("\t") }.each do |line|
    puts "   #{line.chomp.sub(/\A.*?:\d+:in /, '')}"
  end
end

puts "6. no rescue in progress: cause is nil"
begin
  raise High, "no context"
rescue High => e
  puts "   e.cause #{e.cause.inspect}"
end

puts "7. a cause chain may not loop"
a = Low.new("a")
b = High.new("b")
begin
  begin
    raise a
  rescue Low
    begin
      raise b
    rescue High
      raise a, cause: b
    end
  end
rescue Exception => e
  puts "   raise a, cause: b while b's cause is a -> #{e.class}: #{e.message.inspect}"
end

puts "8. a raise inside ensure, while another exception is in flight, gets a cause too"
begin
  begin
    raise Low, "from the body"
  ensure
    begin
      raise High, "from ensure"
    rescue High => inner
      puts "   inner.cause.class #{inner.cause.class}"
    end
  end
rescue Low => e
  puts "   the body's #{e.class} still reaches the outer rescue"
end

puts "9. cause is read-only"
puts "   Exception.method_defined?(:cause=) #{Exception.method_defined?(:cause=)}"
