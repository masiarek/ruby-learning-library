# Kata: ten questions about a week and a half of temperature readings,
# each answered by one Enumerable method.
def row(n, label, value) = puts(format("%2d. %-46s %s", n, label, value.inspect))

temps = [12, 15, 15, 9, 21, 22, 22, 22, 18, 7]

row 1,  "days above 20, with their index", temps.each_with_index.select { |t, _| t > 20 }.map { |t, i| "day #{i}: #{t}" }
row 2,  "runs of non-decreasing readings", temps.chunk_while { |a, b| b >= a }.to_a
row 3,  "day-to-day changes", temps.each_cons(2).map { |a, b| b - a }
row 4,  "three-day moving averages", temps.each_cons(3).map { |w| (w.sum / 3.0).round(1) }
row 5,  "how often each reading occurs", temps.tally
row 6,  "the most frequent reading", temps.tally.max_by { |_, n| n }.first
row 7,  "readings in groups of four", temps.each_slice(4).to_a
row 8,  "coldest and warmest", temps.minmax
row 9,  "readings sorted by distance from 15", temps.sort_by { |t| [(t - 15).abs, t] }
row 10, "first warm day, and the days before it", [temps.find { |t| t > 20 }, temps.take_while { |t| t <= 20 }]
