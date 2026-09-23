# method_missing_and_respond_to_missing_kata_rb.rb — an open Settings object.

class Settings
  def initialize = @data = {}

  def method_missing(name, *args)
    if name.end_with?("=") && args.size == 1
      @data[name.to_s.chomp("=").to_sym] = args.first    # settings.host = "x"
    elsif @data.key?(name) && args.empty?
      @data[name]                                        # settings.host
    else
      super                                              # anything else is still an error
    end
  end

  def respond_to_missing?(name, include_private = false)
    name.end_with?("=") || @data.key?(name) || super
  end
end

s = Settings.new
s.host = "example.org"
puts "1. s.host after s.host = \"example.org\" -> #{s.host.inspect}"
puts "2. s.respond_to?(:host=)                -> #{s.respond_to?(:host=)}"
puts "3. s.respond_to?(:host) / (:port)       -> #{s.respond_to?(:host)} / #{s.respond_to?(:port)}"
puts "4. s.method(:host).call                 -> #{s.method(:host).call.inspect}"
begin
  s.nope!
rescue NoMethodError => e
  puts "5. s.nope!                              -> #{e.class}: #{e.message}"
end
