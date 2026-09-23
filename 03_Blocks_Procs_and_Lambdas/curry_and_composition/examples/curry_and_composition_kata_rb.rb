# Exercise 1: pipeline(*callables) composes with reduce(:>>); a slug maker
# is built from three steps, and a three-argument clamp is curried down to
# a one-argument percentage clamp.

def pipeline(*steps) = steps.reduce(:>>)

slug = pipeline(:strip.to_proc, :downcase.to_proc, ->(s) { s.gsub(/\s+/, "-") })
puts slug.call("  Hello Big World ")
puts ["  A B ", "c"].map(&slug).inspect

clamp = ->(lo, hi, x) { x.clamp(lo, hi) }
to_percent = clamp.curry[0][100]
puts [-5, 42, 250].map(&to_percent).inspect
puts "to_percent.arity = #{to_percent.arity}, lambda? #{to_percent.lambda?}"

# the same clamp, fully applied in one go, and then composed after slug's length
puts clamp.curry[0, 100, 7]
puts (slug >> :size.to_proc >> to_percent).call("  a very long title indeed ")
