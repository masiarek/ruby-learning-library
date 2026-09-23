# Kata: compress a sorted list of integers into inclusive ranges, then expand
# the ranges back and check the round trip.

def to_ranges(ints)
  ints.slice_when { |a, b| b != a + 1 }.map { |run| run.first..run.last }
end

def expand(ranges) = ranges.flat_map(&:to_a)

[[1, 2, 3, 5, 7, 8, 9], [4], [], [1, 3, 5], [10, 11, 12, 13]].each do |ints|
  ranges = to_ranges(ints)
  verdict = expand(ranges) == ints ? "round trip ok" : "ROUND TRIP FAILED"
  printf("%-24s -> %-28s %s\n", ints.inspect, ranges.inspect, verdict)
end
