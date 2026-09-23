"""The same toolbox in Python: comprehensions, builtins, itertools and
collections. Rows are numbered to match the_enumerable_toolbox_rb.rb."""

import heapq
import re
from collections import Counter, defaultdict
from itertools import batched, chain, cycle, dropwhile, groupby, islice, pairwise, takewhile


def row(n, label, value):
    print(f"{n:2d}. {label:<44} {value!r}")


def runs(xs, together):
    """Consecutive elements stay in one run while together(a, b) holds."""
    out = [[xs[0]]]
    for a, b in pairwise(xs):
        out[-1].append(b) if together(a, b) else out.append([b])
    return out


words = ["fig", "apple", "kiwi", "banana", "plum", "cherry"]
nums = [3, 1, 4, 1, 5, 9, 2, 6]
steps = [1, 2, 4, 9, 10, 11, 12, 15]
odd = lambda x: x % 2 == 1

print("Transform, keep, drop, find")
row(1, "[w.upper() for w in words]", [w.upper() for w in words])
row(2, "[w for w in words if len(w) == 4]", [w for w in words if len(w) == 4])
row(3, "[w for w in words if len(w) != 4]", [w for w in words if len(w) != 4])
row(4, 'next((w ... if w.startswith("b")), None), ..."z"', [next((w for w in words if w.startswith("b")), None), next((w for w in words if w.startswith("z")), None)])
row(5, "two comprehensions (no partition)", ([w for w in words if len(w) < 5], [w for w in words if len(w) >= 5]))
row(6, "[w.upper() for w in words if len(w) == 4]", [w.upper() for w in words if len(w) == 4])

print()
print("Group and count")
groups = defaultdict(list)
for w in words:
    groups[len(w)].append(w)
row(7, "defaultdict(list) loop  (no group_by)", dict(groups))
row(8, "groupby(nums, key=odd)  (unsorted input)", [(k, list(g)) for k, g in groupby(nums, key=odd)])
row(9, "groupby(sorted(nums, key=odd), key=odd)", [(k, list(g)) for k, g in groupby(sorted(nums, key=odd), key=odd)])
row(10, "dict(Counter(nums))", dict(Counter(nums)))
row(11, "sum(1 for x in nums if odd(x)), len(words)", [sum(1 for x in nums if odd(x)), len(words)])

print()
print("Windows and slices")
row(12, "list(batched(nums, 3))  (3.12+)", list(batched(nums, 3)))
row(13, "list(pairwise(nums))", list(pairwise(nums)))
row(14, "runs(steps, lambda a, b: b == a + 1)", runs(steps, lambda a, b: b == a + 1))
row(15, "runs(steps, lambda a, b: not b != a + 1)", runs(steps, lambda a, b: not b != a + 1))
row(16, "list(zip(words, nums))", list(zip(words, nums)))
row(17, "list(chain.from_iterable(words))[:5]", list(chain.from_iterable(words))[:5])

print()
print("Numbering")
row(18, '[f"{i}:{w}" for i, w in enumerate(words)]', [f"{i}:{w}" for i, w in enumerate(words)])
row(19, '[f"{i}. {w}" for i, w in enumerate(words, 1)]', [f"{i}. {w}" for i, w in enumerate(words, start=1)])

print()
print("Reduce to one value")
row(20, "sum(nums), sum(x * x for x in nums)", [sum(nums), sum(x * x for x in nums)])
row(21, "(min, max)(nums), (min, max)(words, key=len)", [(min(nums), max(nums)), (min(words, key=len), max(words, key=len))])
row(22, "heapq.nsmallest(2, words), .nlargest(2, words)", [heapq.nsmallest(2, words), heapq.nlargest(2, words)])
row(23, "any(...), all(isinstance(...)), not any(...)", [any(x > 8 for x in nums), all(isinstance(x, int) for x in nums), not any(isinstance(x, str) for x in nums)])

print()
print("Order and slice")
row(24, "sorted(words, key=lambda w: (len(w), w))", sorted(words, key=lambda w: (len(w), w)))
row(25, "sorted(words, key=lambda w: (-len(w), w))", sorted(words, key=lambda w: (-len(w), w)))
row(26, "list(takewhile(...)), list(dropwhile(...))", [list(takewhile(lambda x: x < 5, nums)), list(dropwhile(lambda x: x < 5, nums))])
row(27, "list(dict.fromkeys(nums))", list(dict.fromkeys(nums)))
row(28, "list(islice(cycle(words), 8))", list(islice(cycle(words), 8)))

print()
print("The two Ruby-only spellings, by hand")
row(29, "{w: len(w) for w in words}", {w: len(w) for w in words})
row(30, "re.search / a range test in a comprehension", [[w for w in words if re.search("an", w)], [x for x in nums if 2 <= x <= 5]])
