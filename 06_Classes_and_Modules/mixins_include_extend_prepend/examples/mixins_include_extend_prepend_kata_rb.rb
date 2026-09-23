# Exercise 1: a Timestamped module whose `save` runs first when prepended and
# is shadowed by the class's own `save` when merely included.

module Timestamped
  def save
    "timestamped(" + super + ")"
  end
end

class PrependedRecord
  prepend Timestamped

  def save = "PrependedRecord#save"
end

class IncludedRecord
  include Timestamped

  def save = "IncludedRecord#save"
end

puts "PrependedRecord.ancestors.first(2): #{PrependedRecord.ancestors.first(2).inspect}"
puts "PrependedRecord.new.save:           #{PrependedRecord.new.save}"
puts "IncludedRecord.ancestors.first(2):  #{IncludedRecord.ancestors.first(2).inspect}"
puts "IncludedRecord.new.save:            #{IncludedRecord.new.save}"
puts "included: Timestamped#save is reached only through super, which IncludedRecord#save never calls"
