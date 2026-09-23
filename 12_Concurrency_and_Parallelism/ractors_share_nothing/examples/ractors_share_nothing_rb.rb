# Ractors share nothing that is not frozen.
#
# Warning[:experimental] is switched off first, so no "Ractor is experimental"
# line reaches stderr; report_on_exception is off so the one ractor that
# raises on purpose is reported through Ractor::RemoteError only. Every
# ractor is joined through `value`, and results that arrive through a port
# are sorted before they are printed.
Warning[:experimental] = false
Thread.report_on_exception = false

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value)
end

# 1-2. A ractor runs a block and hands its last value back through `value`
row 1, "Ractor.new { 6 * 7 }.value", Ractor.new { 6 * 7 }.value
row 2, "Ractor.new(10) { |n| n + 1 }.value", Ractor.new(10) { |n| n + 1 }.value

# 3. A mutable argument is copied on the way in
arr = [1, 2, 3]
seen = Ractor.new(arr) { |a| a << 4; a.size }.value
row 3, "an Array argument is copied: inside size / outside", "#{seen} / #{arr.inspect}"

# 4-5. What may be shared: frozen all the way down
checks = [Ractor.shareable?("s".freeze), Ractor.shareable?("s"), Ractor.shareable?(1), Ractor.shareable?(:a), Ractor.shareable?([1, "a"].freeze)]
row 4, "shareable? \"s\".freeze / \"s\" / 1 / :a / [1, \"a\"].freeze", checks.inspect
deep = Ractor.make_shareable([1, ["a"]])
row 5, "make_shareable deep-freezes: outer/inner/string/ok?", [deep.frozen?, deep[1].frozen?, deep[1][0].frozen?, Ractor.shareable?(deep)].inspect

# 6. The block may not read an outer local
x = 5
begin
  Ractor.new { x }
rescue ArgumentError => e
  row 6, "a block that reads an outer local", "#{e.class}: #{e.message}"
end

# 7. An unfrozen constant is off limits inside the ractor
UNFROZEN = "mutable"
begin
  Ractor.new { UNFROZEN }.value
rescue Ractor::RemoteError => e
  row 7, "reading an unfrozen constant: the cause", "#{e.cause.class}: #{e.cause.message}"
end

# 8. An exception inside comes back wrapped
begin
  Ractor.new { raise ArgumentError, "inside" }.value
rescue Ractor::RemoteError => e
  row 8, "an exception inside: value raises", "#{e.class}: #{e.message} cause #{e.cause.class}: #{e.cause.message}"
end

# 9. Ractor::Port (4.0): many ractors send, the owner receives
port = Ractor::Port.new
workers = 3.times.map { |i| Ractor.new(port, i) { |pt, n| pt << [n, n * 10]; :sent } }
row 9, "3 ractors send through a Ractor::Port, sorted", "#{Array.new(3) { port.receive }.sort.inspect}, values #{workers.map(&:value).inspect}"

# 10. The default port: r.send / Ractor.receive; a mutable message is copied
s = "hello"
r = Ractor.new { Ractor.receive.upcase! }
r.send(s)
row 10, "send a String; the ractor upcase!s its copy", "#{r.value.inspect} / sender still #{s.inspect}"

# 11. Shareable objects pass by reference, others by copy
frozen = "shared".freeze
same = Ractor.new { Ractor.receive }.tap { |rr| rr << frozen }.value.equal?(frozen)
copy = Ractor.new { Ractor.receive }.tap { |rr| rr << s }.value.equal?(s)
row 11, "received equal?(sent): a frozen String / a mutable one", "#{same} / #{copy}"

# 12. move: true hands the object over; the sender may not touch it again
moved = "moved"
r2 = Ractor.new { Ractor.receive }
r2.send(moved, move: true)
row 12, "send(move: true): receiver has it / sender's copy", "#{r2.value.inspect} / #{(moved.size rescue $!.class)}"

# 13-14. Which ractor am I; several ractors, values in order
row 13, "Ractor.main? outside / inside", "#{Ractor.main?} / #{Ractor.new { Ractor.main? }.value}"
row 14, "4 ractors squaring; values collected in order", 4.times.map { |i| Ractor.new(i) { |n| n * n } }.map(&:value).inspect

# 15. A plain lambda cannot cross; Ractor.shareable_lambda can
plain = ->(a) { a * 2 }
shareable = Ractor.shareable_lambda { |a| a * 2 }
row 15, "pass a lambda: plain / Ractor.shareable_lambda", "#{(Ractor.new(plain) { |l| l.call(4) }.value rescue $!.class)} / #{Ractor.new(shareable) { |l| l.call(4) }.value}"
