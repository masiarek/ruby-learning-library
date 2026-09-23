# classes_at_runtime_kata_rb.rb — temperature classes generated from a table.

class Temperature
  attr_reader :value
  def initialize(value) = @value = value
end

TO_KELVIN = {
  Celsius:    ->(v) { v + 273.15 },
  Fahrenheit: ->(v) { (v + 459.67) * 5 / 9 },
  Kelvin:     ->(v) { v },
}

TO_KELVIN.each do |name, convert|
  klass = Class.new(Temperature) do
    define_method(:to_kelvin) { convert.call(value).round(2) }   # closes over this unit's lambda
  end
  Object.const_set(name, klass)                                  # gives it its name
end

puts "1. Celsius.name / superclass         -> #{Celsius.name} / #{Celsius.superclass}"
puts "2. Celsius.new(100).to_kelvin        -> #{Celsius.new(100).to_kelvin}"
puts "3. Fahrenheit.new(212).to_kelvin     -> #{Fahrenheit.new(212).to_kelvin}"
puts "4. Kelvin.new(373.15).to_kelvin      -> #{Kelvin.new(373.15).to_kelvin}"
puts "5. Temperature.subclasses names      -> #{Temperature.subclasses.map(&:name).sort.inspect}"
puts "6. Object.const_get(\"Celsius\").new(0).to_kelvin -> #{Object.const_get("Celsius").new(0).to_kelvin}"
