# define_method_kata_rb.rb — unit conversions generated from a table.

class Length
  FACTORS = { cm: 100, mm: 1000, km: 0.001 }

  def initialize(metres) = @metres = metres

  FACTORS.each do |unit, factor|                       # each block call has its own factor
    define_method(:"to_#{unit}") { (@metres * factor).round(4) }
  end

  private define_method(:to_leagues) { (@metres / 4828.032).round(4) }
end

len = Length.new(1.5)
puts "1. Length.new(1.5).to_cm             -> #{len.to_cm}"
puts "2. Length.new(1.5).to_mm             -> #{len.to_mm}"
puts "3. Length.new(1.5).to_km             -> #{len.to_km}"
puts "4. instance_methods(false).sort       -> #{Length.instance_methods(false).sort.inspect}"
puts "5. respond_to?(:to_leagues)           -> #{len.respond_to?(:to_leagues)} (private)"
puts "6. send(:to_leagues)                  -> #{len.send(:to_leagues)}"
