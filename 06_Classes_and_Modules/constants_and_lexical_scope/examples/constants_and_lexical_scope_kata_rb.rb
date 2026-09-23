# Exercise 1: the same constant read from a compact-form class and a nested
# one -- one fails, one works, and Module.nesting says why.

module Config
  DEFAULTS = { host: "localhost", port: 80 }.freeze
end

class Config::Loader             # compact form: nesting is [Config::Loader] only
  def self.nesting = Module.nesting
  def self.bare = DEFAULTS
  def self.qualified = Config::DEFAULTS
end

module Config
  class Reader                   # nested form: nesting is [Config::Reader, Config]
    def self.nesting = Module.nesting
    def self.bare = DEFAULTS
  end
end

puts "Config::Loader.nesting:   #{Config::Loader.nesting.inspect}"
begin
  Config::Loader.bare
rescue NameError => e
  puts "Config::Loader.bare:      #{e.class}: #{e.message}"
end
puts "Config::Loader.qualified: #{Config::Loader.qualified.inspect}"
puts "Config::Reader.nesting:   #{Config::Reader.nesting.inspect}"
puts "Config::Reader.bare:      #{Config::Reader.bare.inspect}"
