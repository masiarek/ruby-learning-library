# Kata: normalize a string in place without chaining bang methods, then show
# why the chained version is a trap.
def normalize!(s)
  s.strip!
  s.downcase!
  s
end

def normalize_chained!(s)
  s.strip!.downcase!
end

a = "  MiXed  "
puts "1. normalize!(\"  MiXed  \")           -> #{normalize!(a).inspect}, and a is now #{a.inspect}"
b = "clean"
puts "2. normalize!(\"clean\")               -> #{normalize!(b).inspect} (nothing changed, still returns the string)"
c = "clean"
begin
  normalize_chained!(c)
rescue NoMethodError => e
  puts "3. normalize_chained!(\"clean\")       -> #{e.class}: #{e.message}"
end
d = "  MiXed  "
puts "4. normalize_chained!(\"  MiXed  \")   -> #{normalize_chained!(d).inspect} (works only because strip! changed something)"
e = " mixed "
puts "5. normalize_chained!(\" mixed \")     -> #{normalize_chained!(e).inspect} (strip! changed it, downcase! did not, and e is #{e.inspect})"
