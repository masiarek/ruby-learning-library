# Kata: blank?(x) -- the idea Rails calls "blank": nil, false, an empty or
# whitespace-only string, an empty array or hash. Plain truthiness says only nil
# and false are falsy, so blank? has to ask each object what it is.

def blank?(x)
  case x
  when nil, false then true
  when String then x.strip.empty?
  else x.respond_to?(:empty?) ? x.empty? : false
  end
end

puts "   value    truthy?  blank?"
[nil, false, 0, "", "  ", [], {}, "a", [nil], true].each do |x|
  puts "   #{x.inspect.ljust(8)} #{(!!x).to_s.ljust(8)} #{blank?(x)}"
end
