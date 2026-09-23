# Kata: "more than one way" made concrete - the word-frequency program written
# three ways, with a check that all three agree.

TEXT = "the quick brown fox jumps over the lazy dog the fox sleeps and the dog barks and barks"

def top_five_with_tally(text)
  text.scan(/[a-z']+/).tally.sort_by { |w, c| [-c, w] }.first(5)
end

def top_five_with_each_with_object(text)
  counts = text.scan(/[a-z']+/).each_with_object(Hash.new(0)) { |w, h| h[w] += 1 }
  counts.sort_by { |w, c| [-c, w] }.first(5)
end

def top_five_with_group_by(text)
  text.scan(/[a-z']+/).group_by(&:itself).map { |w, ws| [w, ws.size] }.sort_by { |w, c| [-c, w] }.first(5)
end

results = {
  "tally" => top_five_with_tally(TEXT),
  "each_with_object" => top_five_with_each_with_object(TEXT),
  "group_by" => top_five_with_group_by(TEXT),
}

results.each do |name, pairs|
  puts "#{name}:"
  pairs.each { |w, c| puts format("  %-8s %d", w, c) }
end
puts "all three equal? #{results.values.uniq.size == 1}"
