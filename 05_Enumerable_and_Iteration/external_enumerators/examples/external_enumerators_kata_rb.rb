# Kata: merge two sorted arrays, and interleave two arrays of different lengths,
# with nothing but external enumerators: next, peek and StopIteration.
def row(n, label, value) = puts(format("%2d. %-44s %s", n, label, value.inspect))

def merge(a, b)
  ea, eb = a.each, b.each
  out = []
  loop { out << (ea.peek <= eb.peek ? ea.next : eb.next) }   # ends when either peek raises StopIteration
  loop { out << ea.next }                                    # drain whichever side is left...
  loop { out << eb.next }                                    # ...the other loop ends at once
  out
end

def interleave(a, b)
  ea, eb = a.each, b.each
  out = []
  loop do
    out << ea.next
    out << eb.next
  end
  loop { out << ea.next }
  loop { out << eb.next }
  out
end

row 1, "merge([1, 4, 9], [2, 3, 10, 11])", merge([1, 4, 9], [2, 3, 10, 11])
row 2, "merge([], [5, 6])", merge([], [5, 6])
row 3, "interleave(%w[a b c], [1, 2])", interleave(%w[a b c], [1, 2])
row 4, "interleave([1], %w[x y z])", interleave([1], %w[x y z])
e = [1, 2, 3].each
e.next
row 5, "the trap: to_a after next starts over", [e.to_a, e.next]
