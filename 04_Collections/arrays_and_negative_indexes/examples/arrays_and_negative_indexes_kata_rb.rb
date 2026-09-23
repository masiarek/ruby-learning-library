# Kata: rotate an array right by k places with negative slices and the splat,
# for any integer k, without Array#rotate -- then check against a.rotate(-k).

def rotate_right(a, k)
  return a.dup if a.empty?
  k %= a.size                  # 0, k > size and negative k all reduce to 0...size
  [*a[-k..], *a[...-k]]        # the last k elements first, then everything before them
end

a = [1, 2, 3, 4, 5]
(-2..7).each do |k|
  mine = rotate_right(a, k)
  verdict = mine == a.rotate(-k) ? "== a.rotate(-k)" : "DIFFERS from a.rotate(-k)"
  printf("k = %2d  %-16s %s\n", k, mine.inspect, verdict)
end
puts "empty: #{rotate_right([], 3).inspect}"
