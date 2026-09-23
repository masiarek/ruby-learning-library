# Kata: six orderings of one list, none of which depends on how sort breaks ties.
def row(n, label, value) = puts(format("%2d. %-46s %s", n, label, value.inspect))

people = [["Ann", 30], ["Bob", 25], ["Cid", 30], ["Abe", 25], ["Eve", 41]]

row 1, "by age, ties in input order (with_index)", people.sort_by.with_index { |(_, age), i| [age, i] }.map(&:first)
row 2, "by age descending, then name ascending", people.sort_by { |name, age| [-age, name] }.map(&:first)
row 3, "the same with sort and a block", people.sort { |a, b| (b[1] <=> a[1]).nonzero? || (a[0] <=> b[0]) }.map(&:first)
row 4, "names by length, then alphabetically", people.map(&:first).sort_by { |n| [n.size, n] }
ages = people.sort_by { |_, age| age }.map(&:last)
row 5, "sort_by { age }: the ages, and are they valid?", [ages, ages.each_cons(2).all? { |a, b| a <= b }]
names = people.map(&:first)
row 6, "sort returns a new array; sort! the same one", [names.sort.equal?(names), names.sort!.equal?(names)]
