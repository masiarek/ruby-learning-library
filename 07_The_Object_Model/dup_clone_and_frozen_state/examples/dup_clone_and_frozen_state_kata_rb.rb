# Exercise 1: a Config whose dup gets its own settings Hash. Without the hook
# the copy shares the Hash; with initialize_copy it does not. Then freeze the
# original and compare dup with clone.

class SharedConfig
  attr_reader :settings
  def initialize(settings) = @settings = settings
end

class OwnConfig < SharedConfig
  def initialize_copy(source)
    super
    @settings = @settings.dup
  end
end

shared = SharedConfig.new({ "debug" => false })
shared_copy = shared.dup
shared_copy.settings["debug"] = true
puts "without the hook: original settings  #{shared.settings.inspect}"

own = OwnConfig.new({ "debug" => false })
own_copy = own.dup
own_copy.settings["debug"] = true
puts "with the hook:    original settings  #{own.settings.inspect}"
puts "                  copy settings      #{own_copy.settings.inspect}"

own.freeze
puts "own.frozen?          #{own.frozen?}"
puts "own.dup.frozen?      #{own.dup.frozen?}"
puts "own.clone.frozen?    #{own.clone.frozen?}"
begin
  own.clone.instance_variable_set(:@settings, {})
rescue FrozenError => e
  puts "clone writable?      #{e.class}"
end
own.dup.instance_variable_set(:@settings, {})
puts "dup writable?        yes"
