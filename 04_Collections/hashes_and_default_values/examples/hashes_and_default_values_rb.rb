# Hashes: insertion order, nil for a missing key, fetch, three kinds of default
# and the shared-default trap. The Python twin (hashes_and_default_values_py.py)
# prints the same numbered rows.

def row(n, label, value)
  printf("%2d. %-56s %s\n", n, label, value)
end

def raises(klass)
  yield
  "no error"
rescue klass => e
  "#{e.class}: #{e.message}"
end

h = {b: 1, a: 2}
h[:c] = 3
row 1,  "h = {b: 1, a: 2}; h[:c] = 3; h.keys",                h.keys.inspect
row 2,  'key class of {a: 1}, {"a" => 1}, {"a": 1}',          [{a: 1}, {"a" => 1}, {"a": 1}].map { it.keys.first.class }.inspect
row 3,  "h[:zz]  (missing key)",                              h[:zz].inspect
row 4,  "h.fetch(:zz)  (the raising form)",                   raises(KeyError) { h.fetch(:zz) }
row 5,  'h.fetch(:zz, 0), h.fetch(:zz) { |k| "no #{k}" }',    [h.fetch(:zz, 0), h.fetch(:zz) { |k| "no #{k}" }].inspect

counts = Hash.new(0)
"hello".each_char { |c| counts[c] += 1 }
row 6,  'counts = Hash.new(0); count the chars of "hello"',   counts.inspect
row 7,  "counts[:zz], counts.size  (default not stored)",     [counts[:zz], counts.size].inspect
row 8,  "counts.fetch(:zz)  (fetch ignores the default)",     raises(KeyError) { counts.fetch(:zz) }

groups = Hash.new { |hash, k| hash[k] = [] }
%w[apple fig kiwi plum banana].each { |w| groups[w.size] << w }
row 9,  "Hash.new { |h, k| h[k] = [] }; group words by size",  groups.inspect
groups[99]
row 10, "groups[99]; groups.size  (the block stores)",        [groups[99], groups.size].inspect

t = Hash.new([])
t[:a] << 1
t[:b] << 2
row 11, "t = Hash.new([]); t[:a] << 1; t[:b] << 2; t, t[:zz]", [t, t[:zz]].inspect
u = {}
u[:a] ||= []
u[:a] << 1
row 12, "u = {}; u[:a] ||= []; u[:a] << 1",                   u.inspect

n = {a: {b: [10, 20]}}
row 13, "n.dig(:a, :b, 1), n.dig(:a, :zz, 1)",                [n.dig(:a, :b, 1), n.dig(:a, :zz, 1)].inspect
row 14, "h.transform_keys(&:to_s), h.transform_values {it*10}", [h.transform_keys(&:to_s), h.transform_values { it * 10 }].inspect
row 15, "[[:a, 1]].to_h, h.to_a, h.to_h { |k, v| [v, k] }",   [[[:a, 1]].to_h, h.to_a, h.to_h { |k, v| [v, k] }].inspect

pair = nil
h.each { |item| pair = item; break }
k, v = nil, nil
h.each { |key, val| k, v = key, val; break }
row 16, "h.each { |pair| } yields, then |k, v| auto-splats",  "#{pair.inspect} is an #{pair.class}; k = #{k.inspect}, v = #{v}"
row 17, "h.key?(:a), h.value?(2), h.key?(:zz)",               [h.key?(:a), h.value?(2), h.key?(:zz)].inspect

key = "x"
s = {}
s[key] = 1
key << "y"
row 18, 'key = "x"; s[key] = 1; key << "y"; s, s.keys[0].frozen?', [s, s.keys[0].frozen?].inspect
row 19, "{1 => :int, 1.0 => :float}.size  (1.eql?(1.0) is false)", {1 => :int, 1.0 => :float}.size

ident = {}.compare_by_identity
ident["a".dup] = 1
ident["a".dup] = 2
plain = {}
plain["a".dup] = 1
plain["a".dup] = 2
row 20, "two equal String keys: compare_by_identity, plain",   [ident.size, plain.size].inspect
row 21, "{a: 1}.merge({b: 2}); merge({a: 2}) { |k, o, n| o + n }", [{a: 1}.merge({b: 2}), {a: 1}.merge({a: 2}) { |_k, o, nn| o + nn }].inspect

d = {a: 1, b: 2}
row 22, "d = {a: 1, b: 2}; d.delete(:a), d.delete(:zz), d",   [d.delete(:a), d.delete(:zz), d].inspect
