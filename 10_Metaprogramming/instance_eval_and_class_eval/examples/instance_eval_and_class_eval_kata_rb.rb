# instance_eval_and_class_eval_kata_rb.rb — one method for one person, one for all of them.

class Person
  def initialize(name) = @name = name
end

ada = Person.new("Ada")
bob = Person.new("Bob")

ada.instance_eval do                                  # self is ada; def lands on ada's singleton class
  def greet = "Hello from #{@name}"
end

Person.class_eval do                                  # self is Person; def lands on Person
  def wave = "#{@name} waves"
end

suffix = "!"
ada.instance_exec(suffix) { |s| @name += s }          # arguments come through instance_exec

puts "1. ada.greet                       -> #{ada.greet.inspect}"
puts "2. bob.respond_to?(:greet)         -> #{bob.respond_to?(:greet)}"
puts "3. ada.singleton_methods           -> #{ada.singleton_methods.inspect}"
puts "4. bob.wave                        -> #{bob.wave.inspect}"
puts "5. Person.instance_methods(false)  -> #{Person.instance_methods(false).sort.inspect}"
puts "6. ada.instance_variable_get(:@name) -> #{ada.instance_variable_get(:@name).inspect}"
