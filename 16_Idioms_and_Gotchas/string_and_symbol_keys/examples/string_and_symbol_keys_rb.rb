# A Hash looks keys up by eql? and hash, and "a" and :a are different objects of
# different classes, so a string key and a symbol key never find each other.
require "json"

def row(n, label, value)
  puts format("%2d. %-46s %s", n, label, value)
end

by_string = { "a" => 1 }
by_symbol = { a: 1 }

row 1, '{"a" => 1}[:a] / ["a"]', "#{by_string[:a].inspect} / #{by_string["a"].inspect}"
row 2, '{"a" => 1}.key?(:a) / key?("a")', "#{by_string.key?(:a)} / #{by_string.key?("a")}"

parsed = JSON.parse('{"a": 1, "b": [1, 2]}')
row 3, "JSON.parse('{\"a\": 1, \"b\": [1, 2]}')", "#{parsed.inspect}  key class #{parsed.keys.first.class}"
symbolized = JSON.parse('{"a": 1, "b": [1, 2]}', symbolize_names: true)
row 4, "JSON.parse(..., symbolize_names: true)", "#{symbolized.inspect}  key class #{symbolized.keys.first.class}"
row 5, "transform_keys(&:to_sym) / (&:to_s)", "#{by_string.transform_keys(&:to_sym).inspect} / #{by_symbol.transform_keys(&:to_s).inspect}"

quoted = { "a": 1 }
row 6, '{"a": 1}   (quotes, then a colon: the trap)', "#{quoted.inspect}  key class #{quoted.keys.first.class}"

both = { "a" => 1, :a => 2 }
row 7, '{"a" => 1, :a => 2}.size', "#{both.size}  #{both.inspect}"
row 8, '{a: 1} == {"a" => 1}', (by_symbol == by_string).inspect

as_json = by_symbol.to_json
back = JSON.parse(as_json)
row 9, "{a: 1}.to_json, then JSON.parse", "#{as_json}  -> #{back.inspect}  key class #{back.keys.first.class}"

row 10, ":a.to_s / \"a\".to_sym / :a.frozen? / \"a\".frozen?",
        "#{:a.to_s.inspect} / #{"a".to_sym.inspect} / #{:a.frozen?} / #{"a".frozen?}"
row 11, '{"a-b": 1}  (a symbol that needs quoting)', "#{({ "a-b": 1 }).inspect}  key class #{({ "a-b": 1 }).keys.first.class}"

begin
  by_string.fetch(:a)
rescue KeyError => e
  row 12, '{"a" => 1}.fetch(:a)', "#{e.class}: #{e.message}  <- the message shows the symbol"
end
