# Kata: sort version strings the way RubyGems does, next to a plain string sort,
# and check each against a pessimistic requirement.
versions = ["1.10.0", "1.9.2", "1.9.10", "2.0.0.pre1", "2.0.0"]

puts "1. as strings:      #{versions.sort.inspect}"
puts "2. as Gem::Version: #{versions.sort_by { Gem::Version.new(it) }.inspect}"

req = Gem::Requirement.new("~> 1.9")
puts "3. #{req} accepts:"
versions.each do |s|
  v = Gem::Version.new(s)
  puts format("   %-10s %-5s prerelease: %s", s, req.satisfied_by?(v), v.prerelease?)
end
puts "4. newest non-prerelease: #{versions.map { Gem::Version.new(it) }.reject(&:prerelease?).max}"
