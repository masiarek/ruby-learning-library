# hooks_inherited_included_method_added_kata_rb.rb — a command registry filled by `inherited`.

class Command
  def self.registry = @registry ||= {}

  def self.inherited(sub)
    super
    name = sub.name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase   # ListFiles -> list_files
    Command.registry[name] = sub
  end

  def self.run(name, *args)
    klass = Command.registry.fetch(name) { raise ArgumentError, "no command #{name.inspect}" }
    klass.new.call(*args)
  end
end

class ListFiles < Command
  def call(dir = ".") = "listing #{dir}"
end

class ShowVersion < Command
  def call = "version 1.0"
end

puts "1. Command.registry.keys       -> #{Command.registry.keys.inspect}"
puts "2. Command.run(\"list_files\", \"/tmp\") -> #{Command.run("list_files", "/tmp").inspect}"
puts "3. Command.run(\"show_version\")    -> #{Command.run("show_version").inspect}"
begin
  Command.run("nope")
rescue ArgumentError => e
  puts "4. Command.run(\"nope\")            -> #{e.class}: #{e.message}"
end
puts "5. Command.subclasses.map(&:name).sort -> #{Command.subclasses.map(&:name).sort.inspect}"
