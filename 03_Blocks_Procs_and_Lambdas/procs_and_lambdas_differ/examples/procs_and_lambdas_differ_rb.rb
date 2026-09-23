# Both are Proc objects, but a lambda checks its argument count and returns
# from itself, while a proc pads or drops arguments and returns from the
# method that created it. The Python twin prints the same rows.

W = 44
def row(n, label, value) = puts("#{n.to_s.rjust(2)}. #{label.ljust(W)} #{value}")

def from_lambda
  l = -> { return 10 }
  v = l.call
  "lambda returned #{v}, method continues"
end

def from_proc
  pr = proc { return 10 }
  pr.call
  "never reached"
end

def make_orphan
  proc { return 1 }             # its method is gone by the time it is called
end

def via_yield
  yield 3
end

four = [Proc.new { }, proc { }, lambda { }, -> { }]
row 1, "Proc.new, proc, lambda, -> are all Proc:", "#{four.map(&:class).uniq.join}, lambda? #{four.map(&:lambda?).join(' ')}"

pr = proc { |a, b| [a, b] }
row 2, "a proc pads, drops, and splats one array:", "call(1) = #{pr.call(1)}, call(1, 2, 3) = #{pr.call(1, 2, 3)}, call([1, 2]) = #{pr.call([1, 2])}"

l = lambda { |a, b| [a, b] }
errors = [[1], [1, 2, 3], [[1, 2]]].map do |args|
  begin
    l.call(*args).to_s
  rescue ArgumentError => e
    "#{e.class} (given #{args.size})"
  end
end
row 3, "a lambda checks the count, no splat:", errors.join(", ")

begin
  l.call(1)
rescue ArgumentError => e
  row 4, "the lambda's message:", e.message
end

row 5, "return in a lambda:", from_lambda
row 6, "return in a proc:", "method returned #{from_proc}"
begin
  make_orphan.call
rescue LocalJumpError => e
  row 7, "return in a proc whose method is gone:", "#{e.class}: #{e.message}"
end

arities = [proc { |a, b| }, lambda { |a, b| }, proc { |a, b = 1| }, lambda { |a, b = 1| }, proc { |*a| }, proc { }]
row 8, "arity, proc then lambda:", "|a, b| #{arities[0].arity} #{arities[1].arity}, |a, b = 1| #{arities[2].arity} #{arities[3].arity}, |*a| #{arities[4].arity}, none #{arities[5].arity}"

sq = ->(x) { x * x }
big = ->(n) { n > 5 }
row 9, "four ways to call, and === for case/when:", "call #{sq.call(3)}, .() #{sq.(3)}, [] #{sq[3]}, yield #{via_yield(&sq)}; big === 7: #{big === 7}"

begin
  lambda(&pr)
  row 10, "lambda(&a_proc) turns it into a lambda?", "lambda? #{lambda(&pr).lambda?} (unexpected)"
rescue ArgumentError => e
  row 10, "lambda(&a_proc) turns it into a lambda?", "#{e.class}: #{e.message}"
end

row 11, "Symbol#to_proc, Method#to_proc are lambdas:", "#{:upcase.to_proc.lambda?} #{method(:puts).to_proc.lambda?}"
