# `case ... in` tests a value against a pattern: an array shape, a hash shape,
# a class, a nested mix -- binding variables as it goes. The Python twin asks
# the same thirteen questions of `match`/`case`.

def row(n, label, value)
  puts format("%2d. %-44s -> %s", n, label, value)
end

def compiles(src)
  RubyVM::InstructionSequence.compile(src)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

# 1. an array pattern: a class check, a binding, and a splat for the rest
case [1, 2, 3]
in [Integer => a, *rest]
  row 1, "[1, 2, 3] in [Integer => a, *rest]", "a = #{a.inspect}, rest = #{rest.inspect}"
end

# 2. a hash pattern names the keys it needs; extra keys are ignored
person = {name: "Ada", age: 36, city: "London"}
case person
in {name: String => n, age:}
  row 2, "person in {name: String => n, age:}", "n = #{n.inspect}, age = #{age.inspect}  (city: ignored)"
end

# 3. **nil forbids extra keys; **rest collects them
describe = lambda do |h|
  case h
  in {name:, **nil} then "exact"
  in {name:, **rest} then "extra: #{rest.keys.inspect}"
  end
end
row 3, "{name:, **nil} vs {name:, **rest}", "#{describe.(person)} / #{describe.({name: "Ada"})}"

# 4. patterns nest
doc = {user: {name: "Ada", roles: ["dev", "admin"]}}
case doc
in {user: {name: String => n, roles: [String => first, *]}}
  row 4, "nested {user: {roles: [String => first, *]}}", "n = #{n.inspect}, first = #{first.inspect}"
end

# 5. a find pattern: anything, then "admin", then the rest
case %w[dev admin ops]
in [*, "admin", *post]
  row 5, "find pattern [*, \"admin\", *post]", "post = #{post.inspect}"
end

# 6. alternatives with |
shape = case [1, 2, 3]
        in [_, _] | [_, _, _] then "pair or triple"
        end
row 6, "alternatives [_, _] | [_, _, _]", shape.inspect

# 7. => is a one-line pattern match that binds
config = {host: "localhost", port: 80, tls: false}
config => {host:, port:}
row 7, "rightward config => {host:, port:}", "host = #{host.inspect}, port = #{port.inspect}"

# 8. `in` as a boolean expression, which may also bind
row 8, "boolean: value in pattern",
    "{a: 1} in {a: Integer} -> #{({a: 1} in {a: Integer})}; 5 in String -> #{(5 in String)}; 5 in Integer => five binds five = #{(5 in Integer => five) && five}"

# 9. nil is a pattern
matched = case nil
          in nil then "matched nil"
          end
row 9, "nil pattern", matched.inspect

# 10. a Struct answers both an array pattern and a hash pattern
Point = Struct.new(:x, :y)
as_array = case Point.new(1, 2); in [x, y] then [x, y] end
as_hash = case Point.new(1, 2); in {x:, y:} then [x, y] end
row 10, "Struct: in [x, y] / in {x:, y:}", "#{as_array.inspect} / #{as_hash.inspect}"

# 11. a Data object too, plus the Const[...] and Const(...) forms that also check the class
Coord = Data.define(:lat, :lng)
c = Coord.new(lat: 1.5, lng: 2.5)
h = case c; in {lat:, lng:} then [lat, lng] end
b = case c; in Coord[lat, lng] then [lat, lng] end
k = case c; in Coord(lat:, lng:) then [lat, lng] end
row 11, "Data: {lat:, lng:} / Coord[a, b] / Coord(k:)", "#{h.inspect} / #{b.inspect} / #{k.inspect}"

# 12. on one line, the subject needs a ; before `in`, or `5 in Integer` is read as row 8
row 12, "one line: case 5 in X / case 5; in X", "#{compiles('case 5 in Integer then 1 end')} / #{compiles('case 5; in Integer then 1 end')}"

# 13. hash pattern keys are symbols, so a string-keyed hash never matches one
row 13, "hash pattern keys are symbols",
    "in {\"name\" => n} -> #{compiles('case h; in {"name" => n} then 1 end')}; {\"name\" => \"Ada\"} in {name:} -> #{({"name" => "Ada"} in {name:})}"
