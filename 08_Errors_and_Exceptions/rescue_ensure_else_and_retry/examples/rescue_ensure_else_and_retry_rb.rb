# rescue_ensure_else_and_retry_rb.rb -- the order in which begin / rescue / else /
# ensure run, retry, ensure on return, the return-inside-ensure trap, and rescue
# inside a def. Every clause prints, so the order is read off the output.

def full_form(fail)
  begin
    puts "   begin body runs"
    raise ZeroDivisionError, "divided by 0" if fail
    puts "   begin body finished"
  rescue ZeroDivisionError, ArgumentError => e
    puts "   rescue runs: #{e.class}: #{e.message}"
  else
    puts "   else runs: no exception was raised"
  ensure
    puts "   ensure runs"
  end
end

puts "1. the full form, no exception"
full_form(false)

puts "2. the full form, an exception"
full_form(true)

puts "3. rescue A, B => e catches either class, and their subclasses"
[ZeroDivisionError, IndexError, KeyError].each do |klass|
  begin
    raise klass, "raised on purpose"
  rescue ZeroDivisionError, IndexError => e
    puts "   caught #{e.class}, which is_a?(IndexError): #{e.is_a?(IndexError)}"
  end
end

puts "4. retry re-runs the begin body"
attempts = 0
begin
  attempts += 1
  puts "   attempt #{attempts}"
  raise "flaky" if attempts < 3
  puts "   succeeded on attempt #{attempts}"
rescue RuntimeError
  retry if attempts < 3
end

puts "5. ensure runs on return"
def early_return
  return "the return value"
ensure
  puts "   ensure ran on the way out"
end
puts "   method returned #{early_return.inspect}"

puts "6. return inside ensure swallows the exception (never do this)"
def swallow
  raise "this exception is lost"
ensure
  return "ensure's return value"
end
puts "   method returned #{swallow.inspect}; no exception reached the caller"

puts "7. rescue in a def needs no begin"
def parse(text)
  Integer(text)
rescue ArgumentError => e
  "rescued #{e.class}"
end
puts "   parse(\"12\")  -> #{parse("12").inspect}"
puts "   parse(\"abc\") -> #{parse("abc").inspect}"

puts "8. what the rescued object carries"
begin
  1 / 0
rescue => e
  puts "   e.class            #{e.class}"
  puts "   e.message          #{e.message.inspect}"
  puts "   e.backtrace        an #{e.backtrace.class} of #{e.backtrace.first.class}s"
  puts "   e.full_message     a #{e.full_message(highlight: false).class} (paths inside, not printed)"
end

puts "9. begin/end is an expression"
v = begin
  raise "x"
rescue
  "the rescue clause's value"
end
puts "   body raised, rescue ran:     #{v.inspect}"
v = begin
  1
rescue
  2
else
  3
ensure
  4
end
puts "   body ok, else and ensure ran: #{v.inspect} (ensure's 4 is discarded)"
