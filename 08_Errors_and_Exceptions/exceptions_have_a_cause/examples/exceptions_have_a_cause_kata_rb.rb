# Exercise 1: wrap a low-level Errno::ENOENT in a ConfigError that names the path,
# keep the original as the cause, and walk the chain from the handler.

class ConfigError < StandardError; end

def load_config(path)
  File.read(path)
rescue Errno::ENOENT
  raise ConfigError, "no config at #{path}"
end

puts "1. the handler sees the wrapper and the cause"
begin
  load_config("missing.conf")
rescue ConfigError => e
  puts "   #{e.class}: #{e.message}"
  puts "   cause: #{e.cause.class}"
end

puts "2. the chain, walked"
begin
  load_config("missing.conf")
rescue ConfigError => e
  step = e
  depth = 0
  while step
    puts "   #{depth}: #{step.class}"
    step = step.cause
    depth += 1
  end
end
