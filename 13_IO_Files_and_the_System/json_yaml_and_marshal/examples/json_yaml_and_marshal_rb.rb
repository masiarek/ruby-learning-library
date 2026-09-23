# JSON (text, for everyone), YAML (text, safe by default) and Marshal (bytes,
# Ruby only): what each keeps, what each loses, and what each refuses.
require "json"
require "yaml"
require "date"

def row(n, text, value = "")
  puts format("%2d. %-58s %s", n, text, value)
end

def indented(text)
  text.lines.each { |line| puts "      #{line}" }
end

h = {a: 1, "b" => [1, 2.5, nil, true], c: :sym}
row 1, "JSON.generate is compact, and Symbols become Strings", JSON.generate(h)
row 2, "to_json on a Hash, Array, String, nil, Symbol, Float", [{a: 1}.to_json, [1, "two"].to_json, "str".to_json, nil.to_json, :sym.to_json, 1.5.to_json].join(" ")
row 3, "JSON.pretty_generate({a: 1, b: [1, 2]}):"
indented JSON.pretty_generate({a: 1, b: [1, 2]})
row 4, "JSON.parse gives String keys", JSON.parse('{"a": 1, "b": [1, 2.5, null, true]}').inspect
row 5, "  symbolize_names: true gives Symbol keys", JSON.parse('{"a": 1}', symbolize_names: true).inspect
row 6, "a Symbol value comes back as a String", JSON.parse(JSON.generate({a: :sym})).inspect
row 7, "non-String keys are stringified: {1 => 2, nil => 3}", JSON.generate({1 => 2, nil => 3})
row 8, "a scalar document: parse of 3, \"s\", null", [JSON.parse("3"), JSON.parse('"s"'), JSON.parse("null")].inspect
row 9, "duplicate keys: the last one wins", JSON.parse('{"a": 1, "a": 2}').inspect
begin
  JSON.parse("nope")
rescue JSON::ParserError => e
  row 10, "bad input raises; its ancestors", "#{e.class} < #{e.class.superclass} < #{e.class.superclass.superclass}"
end
begin
  JSON.generate(Float::NAN)
rescue JSON::GeneratorError => e
  row 11, "NaN is not JSON: generate raises", e.class
end
row 12, "non-ASCII stays UTF-8; ascii_only: true escapes it", "#{JSON.generate("caf\u{e9}")} #{JSON.generate("caf\u{e9}", ascii_only: true)}"
S = Struct.new(:x)
row 13, "a Struct or a Time has no JSON shape: to_json is to_s, quoted", "#{S.new(1).to_json} #{Time.utc(2024, 1, 1).to_json}"

row 14, "YAML.dump({a: 1, \"b\" => [1, 2], c: nil}):"
indented YAML.dump({a: 1, "b" => [1, 2], c: nil})
row 15, "YAML.load: yes is true, ~ is nil, '1' stays a String", YAML.load("a: 1\nb:\n  - x\nc: yes\nd: ~\ne: '1'\n").inspect
begin
  YAML.load("--- !ruby/object:Object {}\n")
rescue Psych::DisallowedClass => e
  row 16, "YAML.load is safe: a !ruby/object tag raises", "#{e.class}: #{e.message}"
end
row 17, "  YAML.unsafe_load builds it", YAML.unsafe_load("--- !ruby/object:Object {}\n").class
date_err = begin
  YAML.load("d: 2024-01-01\n")
rescue Psych::DisallowedClass => e
  e.class
end
row 18, "Symbols are allowed; a Date is not until permitted_classes:", "#{YAML.load("--- :sym\n").inspect}; #{date_err}; #{YAML.load("d: 2024-01-01\n", permitted_classes: [Date])["d"].class}"
alias_err = begin
  YAML.load("a: &x 1\nb: *x\n")
rescue Psych::Exception => e
  e.class
end
row 19, "aliases are off by default; aliases: true allows them", "#{alias_err}; #{YAML.load("a: &x 1\nb: *x\n", aliases: true).inspect}"
row 20, "YAML round trip keeps Symbols and nesting", YAML.load(YAML.dump({a: [1, {b: "c"}]})).inspect

dumped = Marshal.dump([1, "a", :b])
row 21, "Marshal.dump gives a binary String; dump(1) in hex; version", "#{dumped.class} #{dumped.encoding}; #{Marshal.dump(1).unpack1("H*")}; #{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}"
row 22, "the round trip keeps Ruby types: Symbol, Range, Time", Marshal.load(Marshal.dump({a: [1, 2], c: 1..3, d: Time.utc(2024, 1, 1)})).inspect
deep = {a: [1, [2]]}
copy = Marshal.load(Marshal.dump(deep))
copy[:a][1] << 3
row 23, "load(dump(x)) is a deep copy: original, copy", "#{deep.inspect}, #{copy.inspect}"
proc_err = begin
  Marshal.dump(proc {})
rescue TypeError => e
  "#{e.class}: #{e.message}"
end
io_err = begin
  Marshal.dump($stdout)
rescue TypeError => e
  e.message
end
row 24, "Marshal refuses a Proc and an IO", "#{proc_err}; #{io_err}"
garbage = begin
  Marshal.load("garbage")
rescue TypeError => e
  e.class
end
row 25, "Marshal.load of garbage raises", garbage
toml = begin
  require "toml"
  "loaded"
rescue LoadError => e
  "#{e.class}: #{e.message}"
end
row 26, "TOML: no parser in Ruby's standard library", toml
