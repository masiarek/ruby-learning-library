# A class is never closed: `class String` again adds to the one String.
# Each numbered row below is printed by the Python twin too, in the same order.

require "open3"
require "rbconfig"

def row(n, label, value)
  puts format("%2d. %-50s %s", n, label, value)
end

def failing
  yield
rescue NoMethodError, TypeError => e
  "#{e.class}: #{e.message}"
end

row 1, "\"hello\".shout before anyone defines it", failing { "hello".shout }

class String                       # 2. the core String, reopened
  def shout = upcase + "!"
end
row 2, "class String; def shout; end -- \"hello\".shout", "hello".shout.inspect

class Integer                      # 3. a literal picks up the method too
  def double = self * 2
end
row 3, "class Integer; def double; end -- 21.double", "#{21.double} (owner: #{Integer.instance_method(:double).owner})"

class Widget
  def a = :a
end
early = Widget.new                 # built before the class is reopened
class Widget
  def b = :b
end
row 4, "Widget reopened: instance_methods(false) / early.b",
    "#{Widget.instance_methods(false).sort.inspect} / #{early.b.inspect}"

child = <<~RUBY                    # 5. run under -w in a child, so the warning is in view
  class String; def shout = upcase; end
  class String; def shout = upcase + "?"; end
  print "x".shout
RUBY
out, err, = Open3.capture3(RbConfig.ruby, "-w", "-e", child)
warnings = err.lines.filter_map { |line| line[/warning: .*/] }
row 5, "redefining shout: the child prints / ruby -w says",
    "#{out.inspect} / #{warnings.join("; ")}"

before = Widget
class Widget; end
row 6, "a second class Widget statement -- same class?", Widget.equal?(before).to_s

row 7, "class Widget < String (another superclass)",
    failing { eval("class Widget < String; end") }

class Object                       # 8. every object, nil included, gains the method
  def yell = "#{self}!"
end
row 8, "class Object; def yell; end -- nil.yell / 1.yell", "#{nil.yell.inspect} / #{1.yell.inspect}"

String.remove_method(:shout)          # 9. public since Ruby 2.5: no send needed
row 9, "String.remove_method(:shout) -- \"hello\".shout", failing { "hello".shout }

module Shouting                    # 10. the scoped alternative: a refinement
  refine String do
    def shout = upcase + "!!"
  end
end
using Shouting
row 10, "refine String + using -- \"hello\".shout in this file", "hello".shout.inspect
