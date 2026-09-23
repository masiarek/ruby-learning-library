# Kata: describe(name, str) -- encoding label, characters, bytes, validity --
# for strings that share bytes or characters but not labels.
def describe(name, str)
  puts format("%-11s %-10s chars=%d bytes=%d valid=%-5s ascii_only=%s", name, str.encoding, str.length, str.bytesize, str.valid_encoding?, str.ascii_only?)
end

utf8 = "caf\u{e9}"
describe "utf8", utf8
describe "utf8.b", utf8.b
describe "latin1", utf8.encode("ISO-8859-1")
describe "relabelled", utf8.dup.force_encoding("ISO-8859-1")
describe "invalid", "caf\xE9"
describe "ascii", "cafe"
