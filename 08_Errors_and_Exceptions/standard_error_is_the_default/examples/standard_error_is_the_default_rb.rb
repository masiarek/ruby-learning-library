# standard_error_is_the_default_rb.rb -- the exception hierarchy, what a bare rescue
# catches and what slips past it, rescue Exception as the anti-pattern, and a real
# stack overflow and a NotImplementedError going straight through `rescue => e`.

puts "1. the hierarchy, classes only, up to Exception"
[StandardError, RuntimeError, ArgumentError, TypeError, NameError, NoMethodError,
 ZeroDivisionError, KeyError, StopIteration, FrozenError, IOError, Errno::ENOENT,
 SystemStackError, NotImplementedError, LoadError, SyntaxError,
 SystemExit, Interrupt, NoMemoryError].each do |klass|
  chain = klass.ancestors.grep(Class).take_while { _1 != Object }
  puts "   #{klass.name.ljust(20)} #{chain.map(&:name).join(' < ')}"
end

puts "2. what a bare rescue catches (a bare rescue inside, rescue Exception outside)"
[RuntimeError, ArgumentError, StopIteration, Errno::ENOENT,
 SystemExit, Interrupt, NoMemoryError, NotImplementedError, LoadError, SystemStackError].each do |klass|
  begin
    begin
      raise klass
    rescue => e
      puts "   #{klass.name.ljust(20)} caught by the bare rescue"
    end
  rescue Exception => e
    puts "   #{klass.name.ljust(20)} SLIPPED PAST it; rescue Exception caught #{e.class}"
  end
end

puts "3. a bare rescue is rescue StandardError"
begin
  raise "anything"
rescue => e
  puts "   StandardError === e                 #{StandardError === e}"
end
puts "   Exception.new.is_a?(StandardError)  #{Exception.new.is_a?(StandardError)}"
puts "   StandardError.superclass            #{StandardError.superclass}"

puts "4. rescue Exception swallows exit (the anti-pattern)"
begin
  exit 1
rescue Exception => e
  puts "   swallowed #{e.class} (status #{e.status}); the program goes on"
end

puts "5. a real stack overflow is not a StandardError"
def down = down
begin
  begin
    down
  rescue => e
    puts "   the bare rescue caught #{e.class}"
  end
rescue SystemStackError => e
  puts "   slipped past the bare rescue: #{e.class}: #{e.message}"
end

puts "6. a method left as raise NotImplementedError is not caught either"
class Shape
  def area = raise(NotImplementedError, "#{self.class} must define area")
end
begin
  begin
    Shape.new.area
  rescue => e
    puts "   the bare rescue caught #{e.class}"
  end
rescue NotImplementedError => e
  puts "   slipped past the bare rescue: #{e.class}: #{e.message}"
end
