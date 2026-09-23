"""sorted() and list.sort() are guaranteed stable, compute the key once per
element, and take reverse= without disturbing ties. Rows are numbered to match
sort_stability_and_sort_by_rb.rb."""

import heapq
from collections import namedtuple
from functools import cmp_to_key
from operator import attrgetter, itemgetter


def row(n, label, value):
    print(f"{n:2d}. {label:<66} {value!r}")


Person = namedtuple("Person", "name age")
people = [Person("Ann", 30), Person("Bob", 25), Person("Cid", 30),
          Person("Abe", 25), Person("Eve", 41), Person("Fay", 30)]
words = ["pear", "fig", "banana", "kiwi", "apple", "plum", "cherry", "date"]

print("How often the key is computed")
key_calls = 0


def key(w):
    global key_calls
    key_calls += 1
    return (len(w), w)


by_key = sorted(words, key=key)
row(1, "sorted(words, key=key): key calls, result", [key_calls, by_key])
key_calls = 0
compares = 0


def compare(a, b):
    global compares
    compares += 1
    ka, kb = key(a), key(b)
    return -1 if ka < kb else (1 if ka > kb else 0)


by_cmp = sorted(words, key=cmp_to_key(compare))
row(2, "cmp_to_key(compare): key calls >= 2 * (n - 1), same result", [key_calls >= 2 * (len(words) - 1), by_cmp == by_key])
row(3, "compare ran at least n - 1 times  (exact count: Python version)", compares >= len(words) - 1)

print()
print("Equal keys: sorted is stable, so the tie order is the input order, and it can be printed")
by_age = sorted(people, key=attrgetter("age"))
ages = [p.age for p in by_age]
row(4, "ages; non-decreasing?; the same people?; and the names", [ages, ages == sorted(ages), sorted(p.name for p in by_age) == sorted(p.name for p in people), [p.name for p in by_age]])
row(5, "the with_index idiom, sorted(enumerate(people), key=(age, i))", [p.name for i, p in sorted(enumerate(people), key=lambda ip: (ip[1].age, ip[0]))])
row(6, 'sorted(..., key=attrgetter("age", "name"))  (tiebreak by name)', [p.name for p in sorted(people, key=attrgetter("age", "name"))])
row(7, "reverse=True keeps ties in input order; reversed(...) does not", [[p.name for p in sorted(people, key=attrgetter("age"), reverse=True)], [p.name for p in reversed(by_age)]])

print()
print("sorted, list.sort, and comparison functions")
nums = [3, 1, 2]
s = sorted(nums)
row(8, "s = sorted(nums); s, nums, s is nums; nums.sort() returns", [s, nums, s is nums, nums.sort()])
row(9, "sorted(reverse=True), sorted()[::-1], key=-x, heapq.nlargest(2)", [sorted([3, 1, 2], reverse=True), sorted([3, 1, 2])[::-1], sorted([3, 1, 2], key=lambda x: -x), heapq.nlargest(2, [3, 1, 2])])
mixed = []
for arr in ([3, "a", 2], [3, None]):
    try:
        sorted(arr)
        mixed.append("sorted")
    except TypeError as e:
        mixed.append(type(e).__name__)
row(10, 'sorted([3, "a", 2]), sorted([3, None])  (type only)', mixed)
try:
    sorted([2, 1], key=cmp_to_key(lambda a, b: None))
    none_cmp = "sorted"
except TypeError as e:
    none_cmp = type(e).__name__
row(11, "cmp_to_key(lambda a, b: None)  (must return a number)", none_cmp)

print()
print("min, max, and strings")
row(12, 'min(people, key=attrgetter("name")).name, max(..."age").name', [min(people, key=attrgetter("name")).name, max(people, key=attrgetter("age")).name])
row(13, 'sorted(["b", "a", "C"]), sorted(..., key=str.lower)', [sorted(["b", "a", "C"]), sorted(["b", "a", "C"], key=str.lower)])
row(14, 'sorted(["10", "9", "100"]), sorted(..., key=int)', [sorted(["10", "9", "100"]), sorted(["10", "9", "100"], key=int)])
strs = ["10", "9", "100"]
row(15, "strs.sort(key=int) returns None; strs; hasattr(tuple, \"sort\")", [strs.sort(key=int), strs, hasattr(tuple, "sort")])
row(16, 'sorted({"b": 2, "a": 1}.items(), key=itemgetter(1)), dict(...)', [sorted({"b": 2, "a": 1}.items(), key=itemgetter(1)), dict(sorted({"b": 2, "a": 1}.items(), key=itemgetter(1)))])
