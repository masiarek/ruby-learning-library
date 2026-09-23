# custom_exception_classes_rb.rb -- a StandardError subclass with a default message,
# extra attributes, an overridden message, a family caught by its base class,
# full_message, the exception protocol, detailed_message, and what Ruby lacks.

class AppError < StandardError
  def initialize(msg = "the application failed")
    super
  end
end

class NotFound < AppError
  attr_reader :code

  def initialize(msg = "not found", code: 404)
    super(msg)
    @code = code
  end
end

class Loud < AppError
  def message
    "LOUD: #{super}"
  end
end

puts "1. a default message via super"
begin
  raise AppError
rescue AppError => e
  puts "   raise AppError                  -> #{e.message.inspect}"
end
begin
  raise AppError, "given instead"
rescue AppError => e
  puts "   raise AppError, \"given instead\" -> #{e.message.inspect}"
end

puts "2. extra attributes"
begin
  raise NotFound
rescue NotFound => e
  puts "   #{e.class}: #{e.message.inspect}, code #{e.code}"
end
begin
  raise NotFound.new("no such user", code: 410)
rescue NotFound => e
  puts "   #{e.class}: #{e.message.inspect}, code #{e.code}"
end

puts "3. overriding message"
begin
  raise Loud, "x"
rescue Loud => e
  puts "   e.message #{e.message.inspect}   e.to_s #{e.to_s.inspect}"
end

puts "4. a family is caught by its base class"
[AppError, NotFound, Loud].each do |klass|
  begin
    raise klass
  rescue AppError => e
    puts "   rescue AppError caught #{e.class}"
  end
end

puts "5. full_message, first line (line number masked)"
def boom = raise(NotFound.new("gone", code: 410))
begin
  boom
rescue => e
  first = e.full_message(highlight: false, order: :top).lines.first.chomp
  puts "   #{first.sub(/:\d+:in/, ':LINE:in')}"
end

puts "6. raise obj calls obj.exception: any object can be raised that way"
class Ticket
  def initialize(id) = @id = id

  def exception(msg = nil)
    NotFound.new(msg || "ticket #{@id} is missing", code: 404)
  end
end
begin
  raise Ticket.new(7)
rescue NotFound => e
  puts "   raise Ticket.new(7)                -> #{e.class}: #{e.message.inspect}"
end
begin
  raise Ticket.new(7), "custom text"
rescue NotFound => e
  puts "   raise Ticket.new(7), \"custom text\" -> #{e.class}: #{e.message.inspect}"
end

puts "7. detailed_message (3.2) is what full_message prints; message is untouched"
class Detailed < AppError
  def detailed_message(highlight: false, **)
    "#{super} [hint: check the config]"
  end
end
begin
  raise Detailed, "bad setting"
rescue Detailed => e
  puts "   e.message           #{e.message.inspect}"
  puts "   e.detailed_message  #{e.detailed_message(highlight: false).inspect}"
  puts "   full_message line 1 #{e.full_message(highlight: false).lines.first.chomp.sub(/:\d+:in/, ':LINE:in')}"
end

puts "8. initialize without super: the message falls back to the class name"
class NoSuper < AppError
  def initialize(code)
    @code = code
  end
end
begin
  raise NoSuper.new(5)
rescue NoSuper => e
  puts "   #{e.class}: #{e.message.inspect}"
end

puts "9. == compares class, message and backtrace"
puts "   AppError.new(\"a\") == AppError.new(\"a\")  #{AppError.new("a") == AppError.new("a")}"
puts "   AppError.new(\"a\") == AppError.new(\"b\")  #{AppError.new("a") == AppError.new("b")}"

puts "10. no exception groups: collect the errors and raise one wrapper"
class MultiError < AppError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super("#{errors.size} errors")
  end
end
begin
  raise MultiError.new([ArgumentError.new("a"), TypeError.new("b"), ArgumentError.new("c")])
rescue MultiError => e
  puts "   #{e.message}: #{e.errors.map(&:class).inspect}"
  puts "   ArgumentErrors inside: #{e.errors.grep(ArgumentError).size}, TypeErrors: #{e.errors.grep(TypeError).size}"
end
