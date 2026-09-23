# Kata: deep_freeze freezes an object and, for arrays and hashes, everything
# inside it, recursively -- what a plain freeze leaves mutable.

def deep_freeze(obj)
  case obj
  when Array then obj.each { |e| deep_freeze(e) }
  when Hash then obj.each { |k, v| deep_freeze(k); deep_freeze(v) }
  end
  obj.freeze
end

config = { list: [1, [2]], name: "n" }
deep_freeze(config)
puts "   config.frozen?             #{config.frozen?}"
puts "   config[:list].frozen?      #{config[:list].frozen?}"
puts "   config[:list][1].frozen?   #{config[:list][1].frozen?}"
puts "   config[:name].frozen?      #{config[:name].frozen?}"

attempts = {
  "config[:list][1] << 3" => -> { config[:list][1] << 3 },
  "config[:name] << \"!\""  => -> { config[:name] << "!" },
  "config[:extra] = 1"     => -> { config[:extra] = 1 }
}
attempts.each do |label, attempt|
  attempt.call
  puts "   #{label.ljust(26)} worked"
rescue FrozenError => e
  puts "   #{label.ljust(26)} #{e.class}: #{e.message}"
end
puts "   Ractor.shareable?(config)  #{Ractor.shareable?(config)}"
