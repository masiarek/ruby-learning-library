# Kata: the data section as a tiny table. Everything after __END__ is read
# back through DATA, one line at a time, and never parsed as Ruby.

rows = DATA.each_line(chomp: true).reject(&:empty?).map { |line| line.split(",") }
header, *body = rows

widths = header.each_index.map { |i| rows.map { |r| r[i].length }.max }
line = ->(cells) { cells.each_with_index.map { |c, i| c.ljust(widths[i]) }.join("  ") }

puts line.call(header)
puts widths.map { |w| "-" * w }.join("  ")
body.each { |cells| puts line.call(cells) }
puts "#{body.size} rows read from the data section"

__END__
name,language,year
Matz,Ruby,1995
Guido,Python,1991
Larry,Perl,1987
