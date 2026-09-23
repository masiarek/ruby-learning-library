# Kata: render an ERB template in a clean Binding that holds only the
# variables you pass in -- so a template cannot reach the caller's locals.

require "erb"

def clean_binding
  binding
end

def render(template, **vars)
  b = clean_binding
  vars.each { |name, value| b.local_variable_set(name, value) }
  ERB.new(template).result(b)
end

secret = "s3cret"

puts "1. render with greeting: and name:   -> " + render("<%= greeting %>, <%= name %>!", greeting: "Hello", name: "Ada").inspect
puts "2. the clean binding sees no locals  -> " + clean_binding.local_variables.inspect
begin
  render("<%= secret %>")
rescue NameError => e
  puts "3. render(\"<%= secret %>\")           -> #{e.class}"
end
puts "4. the caller's binding sees secret -> " + ERB.new("<%= secret %>").result(binding).inspect
