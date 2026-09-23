# One measured thing -- a Ruby String is bytes plus an encoding label -- for a
# page that is otherwise a map of the Ruby text library.
def row(n, text, value = "")
  puts format("%2d. %-56s %s", n, text, value)
end

s = "caf\u{e9}"
row 1, "a String: inspect, class, encoding", "#{s.inspect}; #{s.class}; #{s.encoding}"
row 2, "length counts characters; bytesize counts bytes", "#{s.length}; #{s.bytesize}"
row 3, "bytes; codepoints", "#{s.bytes.inspect}; #{s.codepoints.inspect}"
row 4, "valid_encoding?; ascii_only?", "#{s.valid_encoding?}; #{s.ascii_only?}"
b = s.b
row 5, "s.b is the same bytes under a BINARY label: encoding, length, == s", "#{b.encoding}; #{b.length}; #{b == s}"
row 6, "force_encoding relabels (length); encode converts (bytes)", "#{s.dup.force_encoding("ISO-8859-1").length}; #{s.encode("ISO-8859-1").bytes.inspect}"
bad = "\xE9"
row 7, 'a lone "\xE9": valid_encoding?; relabelled ISO-8859-1, then encoded', "#{bad.valid_encoding?}; #{bad.dup.force_encoding("ISO-8859-1").encode("UTF-8").inspect}"
ascii_err = begin
  s.encode("US-ASCII")
rescue EncodingError => e
  "#{e.class}: #{e.message}"
end
row 8, 'encode("US-ASCII") raises; undef: :replace; fallback:', "#{ascii_err}; #{s.encode("US-ASCII", undef: :replace)}; #{s.encode("US-ASCII", fallback: {"\u{e9}" => "e"})}"
mix_err = begin
  s + "\xE9".force_encoding("ISO-8859-1")
rescue EncodingError => e
  "#{e.class}: #{e.message}"
end
row 9, "UTF-8 + ISO-8859-1, non-ASCII on both sides, raises", mix_err
row 10, "default_external (-E UTF-8 here); __ENCODING__; String.new; \"\"", "#{Encoding.default_external}; #{__ENCODING__}; #{String.new.encoding}; #{"".encoding}"
combining = "e\u{301}"
row 11, 'e + U+0301: length; grapheme clusters; NFC == "\u{e9}"; upcase', "#{combining.length}; #{combining.grapheme_clusters.length}; #{combining.unicode_normalize(:nfc) == "\u{e9}"}; #{s.upcase}; #{"stra\u{df}e".upcase}"
row 12, '\w is ASCII: s[/\w+/]; \p{L} is Unicode: match?(/\A\p{L}+\z/)', "#{s[/\w+/].inspect}; #{s.match?(/\A\p{L}+\z/)}"
row 13, 'padding counts characters: "%-6s|" % s', "%-6s|" % s
row 14, "s[3], s[-1] are characters; byteslice(3, 2) bytes; byteslice(3, 1) valid?", "#{s[3].inspect}; #{s[-1].inspect}; #{s.byteslice(3, 2).inspect}; #{s.byteslice(3, 1).valid_encoding?}"
