# Kata: a REPL of your own in a dozen lines -- read, eval in one binding,
# print with inspect, keep `_` as the last value, survive errors.
class MiniRepl
  def initialize
    @binding = binding
  end

  def run(lines)
    lines.each do |line|
      value = @binding.eval(line)
      @binding.local_variable_set(:_, value)
      puts "=> #{value.inspect}"
    rescue StandardError => e
      puts "!! #{e.class}: #{e.message}"
    end
  end
end

MiniRepl.new.run(["1 + 1", "x = 2", "x * 3", "_ + 1", "1 / 0", "[_, x]", "\"str\".upcase"])
