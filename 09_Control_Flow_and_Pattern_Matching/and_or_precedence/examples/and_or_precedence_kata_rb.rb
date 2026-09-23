# Exercise 1: predict, then print, a handful of precedence puzzles; then
# show the ||= memoization trap on a method whose answer is false.

a = nil || "x"
b = nil or "x"
c = (nil or "x")
puts "a = nil || \"x\"      -> a is #{a.inspect}"
puts "b = nil or \"x\"      -> b is #{b.inspect}"
puts "c = (nil or \"x\")    -> c is #{c.inspect}"
puts "1 and 2              -> #{(1 and 2).inspect}"
puts "nil or 1 and 2       -> #{(nil or 1 and 2).inspect}"
puts "!true == false       -> #{(!true == false).inspect}"
puts "not true == false    -> #{(not true == false).inspect}"

class Report
  def initialize
    @computed = 0
  end

  def trap?
    @trap ||= compute
  end

  def fixed?
    return @fixed if defined?(@fixed)

    @fixed = compute
  end

  def computed = @computed

  private

  def compute
    @computed += 1
    false
  end
end

r = Report.new
3.times { r.trap? }
puts "@trap ||= compute, called 3 times  -> compute ran #{r.computed} time(s)"

r = Report.new
3.times { r.fixed? }
puts "defined?(@fixed) guard, called 3 times -> compute ran #{r.computed} time(s)"
