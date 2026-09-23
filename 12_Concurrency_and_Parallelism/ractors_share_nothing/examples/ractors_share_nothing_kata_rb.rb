# Kata: four ractors count the words of four texts and report through one
# Ractor::Port. The port hands the results over in whatever order the
# ractors finish, so they are sorted by name before printing.
Warning[:experimental] = false

texts = {
  "a" => "the cat sat on the mat",
  "b" => "a ractor shares nothing that is not frozen",
  "c" => "join every ractor before you print",
  "d" => "one two three",
}

port = Ractor::Port.new
ractors = texts.map do |name, text|
  Ractor.new(port, name, text) do |pt, n, t|
    pt << [n, t.split.size]
    :done
  end
end

counts = Array.new(ractors.size) { port.receive }.sort
counts.each { |name, n| puts "text #{name}: #{n} words" }
puts "total: #{counts.sum { |_, n| n }} words"
puts "every ractor's value: #{ractors.map(&:value).uniq.inspect}"
