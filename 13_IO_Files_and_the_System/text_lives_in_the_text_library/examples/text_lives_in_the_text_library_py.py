# The Python twin: str and bytes are two types, so most of Ruby's label
# operations have no counterpart and the failures move to the boundary.
import re
import sys
import unicodedata


def row(n, text, value=""):
    print(f"{n:2d}. {text:<56} {value}")


s = "caf\N{LATIN SMALL LETTER E WITH ACUTE}"
row(1, "a str: repr, type; a str carries no encoding label", f"{s!r}; {type(s).__name__}; n/a")
row(2, "len counts characters; len(s.encode()) counts bytes", f"{len(s)}; {len(s.encode())}")
row(3, "list(s.encode()); [ord(c) for c in s]", f"{list(s.encode())}; {[ord(c) for c in s]}")
row(4, "a str is always valid text (no valid_encoding); isascii", f"n/a; {s.isascii()}")
b = s.encode()
row(5, "s.encode() is a second type: type, len, == s", f"{type(b).__name__}; {len(b)}; {b == s}")
row(6, "no relabel (bytes carry no label); encode('latin-1') converts", f"n/a; {list(s.encode('latin-1'))}")
lone = b"\xe9"
try:
    lone.decode()
except UnicodeDecodeError as e:
    dec = f"{type(e).__name__}: {e.reason}"
row(7, "b'\\xe9'.decode() fails at the boundary; .decode('latin-1')", f"{dec}; {lone.decode('latin-1')!r}")
try:
    s.encode("ascii")
except UnicodeEncodeError as e:
    enc = f"{type(e).__name__}: {e.reason}"
row(8, "encode('ascii') raises; errors='replace'; 'xmlcharrefreplace'", f"{enc}; {s.encode('ascii', errors='replace')}; {s.encode('ascii', errors='xmlcharrefreplace')}")
try:
    s + b
except TypeError as e:
    mix = type(e).__name__
row(9, "str + bytes raises, whatever the bytes hold", mix)
row(10, "getdefaultencoding; utf8_mode; type(b''); type('')", f"{sys.getdefaultencoding()}; {sys.flags.utf8_mode}; {type(b'').__name__}; {type('').__name__}")
combining = "e\N{COMBINING ACUTE ACCENT}"
sharp = "stra\N{LATIN SMALL LETTER SHARP S}e"
row(11, "e + U+0301: len; no grapheme clusters; NFC ==; upper", f"{len(combining)}; n/a; {unicodedata.normalize('NFC', combining) == s[-1]}; {s.upper()}; {sharp.upper()}")
word = re.match(r"\w+", s).group()
letters = bool(re.fullmatch(r"[^\W\d_]+", s))
row(12, "\\w is Unicode here: re.match(r'\\w+', s); [^\\W\\d_]+ for letters", f"{word!r}; {letters}")
row(13, "padding counts characters: '%-6s|' % s", "%-6s|" % s)
tail = s.encode()[3:4].decode(errors="replace")
row(14, "s[3], s[-1] are characters; s.encode()[3:5] bytes; [3:4] decoded", f"{s[3]!r}; {s[-1]!r}; {s.encode()[3:5]!r}; {tail!r}")
