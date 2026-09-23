# sort_by computes each key once; sort with a block recomputes at every
# comparison; neither promises the order of equal keys, so this program prints
# the stable idiom and validity checks, never a raw tie order (it differs by
# platform). Rows are numbered so the Python twin
# (sort_stability_and_sort_by_py.py) can print the same row beside it.

def row(n, label, value) = puts(format("%2d. %-66s %s", n, label, value.inspect))

Person = Struct.new(:name, :age)
people = [Person.new("Ann", 30), Person.new("Bob", 25), Person.new("Cid", 30),
          Person.new("Abe", 25), Person.new("Eve", 41), Person.new("Fay", 30)]
words = %w[pear fig banana kiwi apple plum cherry date]

puts "How often the key is computed"
key_calls = 0
by_key = words.sort_by { |w| key_calls += 1; [w.size, w] }
row 1, "sort_by { [w.size, w] }: key calls, result", [key_calls, by_key]
key_calls = 0
compares = 0
key = ->(w) { key_calls += 1; [w.size, w] }
by_block = words.sort { |a, b| compares += 1; key.(a) <=> key.(b) }
row 2, "sort { key(a) <=> key(b) }: key calls >= 2 * (n - 1), same result", [key_calls >= 2 * (words.size - 1), by_block == by_key]
row 3, "the sort block ran at least n - 1 times  (exact count: platform)", compares >= words.size - 1

puts
puts "Equal keys: what sort_by promises (a valid order) and what it does not (which one)"
by_age = people.sort_by(&:age)
row 4, "sort_by(&:age).map(&:age); non-decreasing?; the same people?", [by_age.map(&:age), by_age.map(&:age) == by_age.map(&:age).sort, by_age.map(&:name).sort == people.map(&:name).sort]
stable = people.sort_by.with_index { |p, i| [p.age, i] }
row 5, "sort_by.with_index { |p, i| [p.age, i] }.map(&:name)  (stable)", stable.map(&:name)
row 6, "sort_by { |p| [p.age, p.name] }.map(&:name)  (tiebreak by name)", people.sort_by { |p| [p.age, p.name] }.map(&:name)
row 7, "descending: with_index { [-p.age, i] } vs stable.reverse", [people.sort_by.with_index { |p, i| [-p.age, i] }.map(&:name), stable.reverse.map(&:name)]

puts
puts "sort, sort!, and the block"
nums = [3, 1, 2]
sorted = nums.sort
row 8, "s = nums.sort; s, nums, s.equal?(nums); nums.sort!.equal?(nums)", [sorted, nums, sorted.equal?(nums), nums.sort!.equal?(nums)]
row 9, "sort { |a, b| b <=> a }, sort.reverse, sort_by { -x }, max(2)", [[3, 1, 2].sort { |a, b| b <=> a }, [3, 1, 2].sort.reverse, [3, 1, 2].sort_by { |x| -x }, [3, 1, 2].max(2)]
mixed = [[3, "a", 2], [3, nil]].map do |arr|
  arr.sort
  :sorted
rescue ArgumentError => e
  e.class
end
row 10, "[3, \"a\", 2].sort, [3, nil].sort  (class only)", mixed
nil_block = begin
  [2, 1].sort { |a, b| nil }
rescue ArgumentError => e
  e.class
end
row 11, "[2, 1].sort { nil }  (the block must return an Integer)", nil_block

puts
puts "min_by, max_by, and strings"
row 12, "people.min_by(&:name).name, people.max_by(&:age).name", [people.min_by(&:name).name, people.max_by(&:age).name]
row 13, "%w[b a C].sort, %w[b a C].sort_by(&:downcase)", [%w[b a C].sort, %w[b a C].sort_by(&:downcase)]
row 14, "%w[10 9 100].sort, %w[10 9 100].sort_by(&:to_i)", [%w[10 9 100].sort, %w[10 9 100].sort_by(&:to_i)]
strs = %w[10 9 100]
row 15, "strs.sort_by!(&:to_i).equal?(strs), strs; Enumerable has sort_by!?", [strs.sort_by!(&:to_i).equal?(strs), strs, Enumerable.instance_methods.include?(:sort_by!)]
row 16, "{b: 2, a: 1}.sort_by { |k, v| v }, .to_h", [{b: 2, a: 1}.sort_by { |k, v| v }, {b: 2, a: 1}.sort_by { |k, v| v }.to_h]
