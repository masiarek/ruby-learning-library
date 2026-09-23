# Only nil and false are falsy in Ruby. Everything else, including 0, 0.0, "",
# [] and {}, is truthy, and no class can change that. The Python twin
# (nil_false_and_truthiness_py.py) prints the same numbered rows.

def row(label, shown)
  puts "   #{label.ljust(36)} #{shown}"
end

puts "1. the truth table: !!x"
[nil, false, 0, 0.0, "", [], {}, :a].each do |x|
  row x.inspect, (!!x).inspect
end

puts "2. nil is an object with methods"
row "nil.to_s", nil.to_s.inspect
row "nil.to_a", nil.to_a.inspect
row "nil.to_i", nil.to_i.inspect
row "nil.inspect", nil.inspect.inspect

puts "3. || returns the first truthy operand"
x = nil
row "x = nil;   x || \"default\"", (x || "default").inspect
x = 0
row "x = 0;     x || \"default\"", (x || "default").inspect
x = ""
row "x = \"\";    x || \"default\"", (x || "default").inspect
x = false
row "x = false; x || \"default\"", (x || "default").inspect

puts "4. nil and false are two different objects"
row "nil == false", (nil == false).inspect
row "nil.nil?", nil.nil?.inspect
row "false.nil?", false.nil?.inspect
row "false == 0", (false == 0).inspect

puts "5. truthiness is not a method a class can define"
class Hollow
  def !
    true
  end
end
h = Hollow.new
row "!h   (Hollow defines !)", (!h).inspect
row "h ? :truthy : :falsy", (h ? :truthy : :falsy).inspect
row "!!h  (calls ! twice)", (!!h).inspect
row "[].empty?", [].empty?.inspect
row "[] ? :truthy : :falsy", ([] ? :truthy : :falsy).inspect

puts "6. if 0 and if \"\" take the then branch"
n = 0
row "n = 0;  n ? :then : :else", (n ? :then : :else).inspect
s = ""
row "s = \"\"; s ? :then : :else", (s ? :then : :else).inspect

puts "7. dropping nil is not dropping falsy"
mixed = [nil, 1, false, 2]
row "mixed.compact", mixed.compact.inspect
row "mixed.select(&:itself)", mixed.select(&:itself).inspect
