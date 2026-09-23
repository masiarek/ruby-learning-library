# Kata: memoize a computed boolean correctly.
# `@verbose ||= compute` recomputes whenever the cached value is false, because
# `||=` cannot tell "false" from "never computed". Guard on `defined?` instead.

class Settings
  attr_reader :runs

  def initialize
    @runs = 0
  end

  def verbose_with_or_equals
    @verbose_a ||= compute_verbose
  end

  def verbose_with_defined
    return @verbose_b if defined?(@verbose_b)
    @verbose_b = compute_verbose
  end

  private

  def compute_verbose
    @runs += 1
    false # the setting is off, and that answer should be remembered
  end
end

s = Settings.new
3.times { s.verbose_with_or_equals }
puts "||= version, three reads: computed #{s.runs} time(s), value #{s.verbose_with_or_equals.inspect}"

s = Settings.new
3.times { s.verbose_with_defined }
puts "defined? version, three reads: computed #{s.runs} time(s), value #{s.verbose_with_defined.inspect}"
