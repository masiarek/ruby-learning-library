# Exercise 1: a small error family that carries the field it is about, builds its
# default message from that field, and is caught as a family by its base class.

class ValidationError < StandardError
  attr_reader :field

  def initialize(field, msg = "#{field} is invalid")
    @field = field
    super(msg)
  end
end

class MissingField < ValidationError
  def initialize(field)
    super(field, "#{field} is required")
  end
end

def validate(record)
  raise MissingField, :name unless record.key?(:name)
  raise ValidationError, :age unless record[:age].is_a?(Integer)
  "ok"
end

[{ age: 3 }, { name: "Ann", age: "three" }, { name: "Ann", age: 30 }].each do |record|
  begin
    puts "   #{record.inspect} -> #{validate(record)}"
  rescue ValidationError => e
    puts "   #{record.inspect} -> #{e.class}: #{e.message} (field #{e.field.inspect})"
  end
end
