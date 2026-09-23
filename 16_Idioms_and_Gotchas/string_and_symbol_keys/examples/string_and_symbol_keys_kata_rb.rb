# Kata: symbolize every key in a nested structure, arrays included.
require "json"

def deep_symbolize(obj)
  case obj
  when Hash  then obj.to_h { |k, v| [k.to_sym, deep_symbolize(v)] }
  when Array then obj.map { |v| deep_symbolize(v) }
  else obj
  end
end

text = '{"user": {"name": "ann", "tags": ["x", "y"]}, "items": [{"id": 1}, {"id": 2}]}'
parsed = JSON.parse(text)

puts "before: #{parsed.inspect}"
puts "after:  #{deep_symbolize(parsed).inspect}"
puts "dig:    #{deep_symbolize(parsed).dig(:items, 1, :id)}"
puts "same as symbolize_names? #{deep_symbolize(parsed) == JSON.parse(text, symbolize_names: true)}"
