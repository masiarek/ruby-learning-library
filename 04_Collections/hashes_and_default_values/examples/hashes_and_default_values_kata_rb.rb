# Kata: count words with Hash.new(0), group the words by their count with
# Hash.new { |h, k| h[k] = [] }, then print the groups from the most frequent down.

text = "the cat and the dog and the bird"
counts = Hash.new(0)
text.split.each { |word| counts[word] += 1 }
puts "counts:   #{counts.inspect}"

by_count = Hash.new { |h, k| h[k] = [] }
counts.each { |word, n| by_count[n] << word }
puts "by_count: #{by_count.inspect}"

by_count.keys.sort.reverse.each do |n|
  puts "#{n} x  #{by_count[n].sort.join(', ')}"
end

by_count[99]
puts "reading by_count[99] stored a key: #{by_count.keys.inspect}"
puts "counts['zzz'] did not: #{counts['zzz']} and #{counts.keys.inspect}"
