# Kata: censor! edits the caller's string in place with gsub!; censor returns
# a new string with gsub and leaves the original alone. equal? tells them
# apart, and the second censor! returns nil because nothing was left to change.

def censor!(text, word) = text.gsub!(word, "*" * word.length)
def censor(text, word) = text.gsub(word, "*" * word.length)

original = "the secret is a secret".dup
copy = censor(original, "secret")
puts "   censor returns            #{copy.inspect}"
puts "   original afterwards       #{original.inspect}"
puts "   copy.equal?(original)     #{copy.equal?(original)}"

result = censor!(original, "secret")
puts "   censor! returns           #{result.inspect}"
puts "   original afterwards       #{original.inspect}"
puts "   result.equal?(original)   #{result.equal?(original)}"
puts "   censor! a second time     #{censor!(original, "secret").inspect}"
