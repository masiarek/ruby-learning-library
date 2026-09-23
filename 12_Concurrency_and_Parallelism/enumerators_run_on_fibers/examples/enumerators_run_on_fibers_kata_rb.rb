# Kata: an Enumerator over the words of a sentence, read from the outside with
# next and peek so that each word is printed with the one that follows it.
# The StopIteration that ends the loop is the one `loop` rescues; the one
# from peek is rescued by hand.
words = Enumerator.new do |y|
  "the quick brown fox".split.each { |w| y << w }
end

loop do
  word = words.next
  following = begin
    words.peek
  rescue StopIteration
    "(none)"
  end
  puts "#{word.ljust(6)} -> next: #{following}"
end
puts "after the loop: next raises #{(words.next rescue $!.class)}"
