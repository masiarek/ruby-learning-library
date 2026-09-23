# define_method_rb.rb — a method made from a block keeps the variables around it.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

class Light
  def initialize(colour) = @colour = colour

  for c in %i[red green blue]                          # 1. `for` shares ONE variable c
    define_method(:"for_#{c}?") { @colour == c }
  end

  %i[red green blue].each do |c|                       # 2. each: a fresh c per block call
    define_method(:"#{c}?") { @colour == c }
  end

  RETURNED = define_method(:noop) { }                  # 3. what define_method returns

  def greet = "hi"
  define_method(:hello, instance_method(:greet))       # 4. from an UnboundMethod ...
  define_method(:double, ->(x) { x * 2 })              #    ... or from a lambda

  factor = 3                                           # 6. a local of the class body
  define_method(:triple) { |x| x * factor }
  def triple_def(x) = x * factor                       #    def opens a new scope

  define_method(:takes_block) { |&blk| blk.call(2) }   # 7. a block arrives through &blk

  private define_method(:secret) { :s }                # 8. private takes the Symbol

  %w[red green blue].each do |c|                       # 10. the string route
    class_eval "def str_#{c}?; @colour == :#{c}; end"
  end

  def is?(colour) = @colour == colour                  # 12. one general method ...
  define_method(:is_red?) { is?(:red) }                #     ... specialised by a closure
end

class Person
  def self.my_attr(*names)                             # 9. attr_accessor, reimplemented
    names.each do |n|
      define_method(n) { instance_variable_get(:"@#{n}") }
      define_method(:"#{n}=") { |v| instance_variable_set(:"@#{n}", v) }
    end
  end
  my_attr :name, :age
end

light = Light.new(:red)
row 1, "for c in [...]: for_red? for_green? for_blue?",
    [light.for_red?, light.for_green?, light.for_blue?].inspect
row 2, "each { |c| }: red? green? blue?", [light.red?, light.green?, light.blue?].inspect
row 3, "define_method(:noop) { } returned", Light::RETURNED.inspect
Light.define_method(:from_outside) { :out }              # public: callable on the class from anywhere
row "", "Light.define_method(...) from outside the class", light.from_outside.inspect
row 4, "hello (from instance_method(:greet))", light.hello.inspect
row "", "double (from a lambda): double(4)", light.double(4)
begin
  light.double
rescue ArgumentError => e
  row 5, "double with no argument", "#{e.class}: #{e.message}"
end
row 6, "triple(3) -- the block sees factor", light.triple(3)
begin
  light.triple_def(3)
rescue NameError => e
  row "", "triple_def(3) -- def does not", "#{e.class}: #{e.message}"
end
begin
  RubyVM::InstructionSequence.compile("class X; define_method(:m) { yield }; end")
rescue SyntaxError => e
  row 7, "define_method(:m) { yield }", "#{e.class}: #{e.message[/Invalid yield/]}"
end
row "", "takes_block { |x| x * 10 } -- use &blk", light.takes_block { |x| x * 10 }
begin
  light.secret
rescue NoMethodError => e
  row 8, "private define_method(:secret): light.secret", "#{e.class}: #{e.message}"
end
row "", "light.send(:secret)", light.send(:secret).inspect
person = Person.new
person.name = "Ada"
person.age = 36
row 9, "my_attr :name, :age -> name, age", "#{person.name.inspect}, #{person.age}"
row "", "Person.instance_methods(false).sort", Person.instance_methods(false).sort.inspect
row 10, 'class_eval "def str_#{c}? ..." per colour', [light.str_red?, light.str_green?, light.str_blue?].inspect
row 11, "Light.instance_methods(false).grep(/red/)", Light.instance_methods(false).grep(/red/).sort.inspect
row 12, "is_red? -- is?(:red) behind a closure", light.is_red?
