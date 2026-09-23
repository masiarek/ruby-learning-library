# 13 — IO, files and the system

**One line:** Ruby talks to the outside world through a few Kernel methods with strong conventions — `puts`, `gets`, `File.open` with a block, `system`, `ARGV`, `ENV`, `exit` — and each convention has a Python twin that differs in a detail worth measuring: what closes a file, what a newline means, what a missing key returns, what a child process hands back.

This chapter is the part of Ruby that touches the operating system: files and directories, the three standard streams, the command line and the environment, other programs, the serialisation formats a script reads and writes, time, and the formatting that turns values into output. Each lesson runs its Ruby program and its Python twin under the same conditions — in a temporary directory that the program removes, with child processes started from `RbConfig.ruby` and `sys.executable`, with `TZ` pinned to UTC and no `Time.now` — so that every row is the same on Ubuntu and on macOS, and a claim about "what Ruby prints" is a recorded fact rather than a memory.

For a Python programmer the shapes carry over almost one to one: `File.open { }` is `with open()`, `puts` is `print`, `gets` is `input()` or `sys.stdin.readline()`, `ARGV` is `sys.argv[1:]`, `ENV` is `os.environ`, `system` and `Open3.capture3` are `subprocess.run`, `Pathname` is `pathlib.Path`, `JSON` is `json`, `Marshal` is `pickle`, `Time` and `Date` are `datetime` and `date`, `format` is the `%` operator and `"#{}"` is an f-string. Where the model breaks is in the return values and defaults: `gets` returns `nil` at end of input where `input()` raises; `puts nil` prints an empty line where `print(None)` prints the word; `system` returns `true`/`false`/`nil` where `subprocess.run` returns an object; `File.write` counts bytes where `write_text` counts characters; Ruby keeps the `\r` of a CRLF file where Python's text mode translates it; `JSON.parse` gives String keys even when you wrote Symbols; `YAML.load` is safe by default where `pickle.loads` never is; `Date >> 1` steps a month where `date` has no such step; `format("%.2f", 2.675)` rounds up where Python rounds down. Text — encodings, Unicode, regex, literals — is not repeated here: the last lesson is a map into the Ruby text library.

| Lesson | Level | The one thing |
|---|---|---|
| [`File.open` with a block closes the file for you](file_open_with_a_block/README.md) | 101 | the block form closes on the way out and returns the block's value; bytes versus characters, and CRLF kept versus translated |
| [`puts` adds a newline, `print` does not, `p` shows `inspect`](puts_print_p_and_pp/README.md) | 101 | the four writers captured character by character, beside `print` with `sep` and `end`, and `pprint`'s sorted keys |
| [`ARGV` holds strings and `ENV` is not a Hash](argv_env_and_exit_status/README.md) | 101 | `ARGV`, `$0`, `ENV`, `exit` and `OptionParser` measured from a parent process; `exit false` is 1 but `sys.exit(False)` is 0 |
| [`system` returns true, false or nil](running_other_programs/README.md) | 201 | six ways to run a program and what each hands back; the argv form skips the shell; a piped stdout is buffered in both languages |
| [`gets` returns nil at EOF, and reads `ARGV`'s files first](stdin_gets_and_argf/README.md) | 201 | `gets` is `ARGF.gets`; `nil` at end of input where `input()` raises `EOFError`; `fileinput` is `ARGF` |
| [`Pathname#/` joins, and `Dir.glob` is sorted](pathname_dir_and_glob/README.md) | 201 | `Pathname` beside `pathlib.Path`, `Dir.glob` sorted since 3.0 beside an unordered `glob.glob`, `File.join` versus `os.path.join` |
| [`JSON.parse` gives string keys; `YAML.load` is safe](json_yaml_and_marshal/README.md) | 201 | what JSON loses, what `YAML.load` refuses, what Marshal keeps; `pickle` has no safe mode and `tomllib` has no Ruby counterpart |
| [`Time` is an instant, `Date` is a calendar day](time_and_date/README.md) | 201 | fixed instants under `TZ=UTC`: seconds arithmetic, offsets, `Date >> 1` clamping, Rational day differences; aware versus naive in Python |
| [`#{}` calls `to_s`; `format` is printf](string_formatting_and_interpolation/README.md) | 101 | interpolation, `format`, `String#%`, named fields, padding by characters; f-strings, `!r`, and the thousands separator Ruby lacks |
| [Text lives in the Ruby text library](text_lives_in_the_text_library/README.md) | 101 | one type plus a label versus `str` and `bytes`, then a map of all twenty-three text-library lessons beside their Python pages |

## Read more

- [File ↗](https://docs.ruby-lang.org/en/4.0/File.html) — `open`, `read`, `write`, `foreach`, the modes and the encoding argument
- [IO ↗](https://docs.ruby-lang.org/en/4.0/IO.html) — the class under files, pipes and the standard streams: `gets`, `each_line`, `write`, `popen`
- [Kernel ↗](https://docs.ruby-lang.org/en/4.0/Kernel.html) — `puts`, `print`, `p`, `gets`, `system`, backticks, `format`, `exit`
- [ARGF ↗](https://docs.ruby-lang.org/en/4.0/ARGF.html) — the virtual file that bare `gets` reads
- [ENV ↗](https://docs.ruby-lang.org/en/4.0/ENV.html) — the Hash-like object that is not a Hash
- [Process ↗](https://docs.ruby-lang.org/en/4.0/Process.html) — `spawn`, `wait`, `wait2` and `Process::Status`
- [Open3 ↗](https://docs.ruby-lang.org/en/4.0/Open3.html) — `capture2`, `capture2e`, `capture3`, `popen3`
- [Pathname ↗](https://docs.ruby-lang.org/en/4.0/Pathname.html) and [Dir ↗](https://docs.ruby-lang.org/en/4.0/Dir.html) — paths as objects, and `glob`
- [JSON ↗](https://docs.ruby-lang.org/en/4.0/JSON.html), [Psych ↗](https://docs.ruby-lang.org/en/4.0/Psych.html) and [Marshal ↗](https://docs.ruby-lang.org/en/4.0/Marshal.html) — the three serialisers
- [Time ↗](https://docs.ruby-lang.org/en/4.0/Time.html) and [Date ↗](https://docs.ruby-lang.org/en/4.0/Date.html) — instants and calendar days
- [Built-in functions: `open` ↗](https://docs.python.org/3/library/functions.html#open) — Python's `open`, its modes, `encoding=` and `newline=`
- [`subprocess` ↗](https://docs.python.org/3/library/subprocess.html) — `run`, `Popen`, `check_output` and the `CompletedProcess`
- [`fileinput` ↗](https://docs.python.org/3/library/fileinput.html) — Python's `ARGF`
- [`pathlib` ↗](https://docs.python.org/3/library/pathlib.html) — `Path`, `/`, `glob` and `rglob`
- [`json` ↗](https://docs.python.org/3/library/json.html), [`pickle` ↗](https://docs.python.org/3/library/pickle.html) and [`tomllib` ↗](https://docs.python.org/3/library/tomllib.html) — the serialisers, and the warning at the top of `pickle`'s page
- [`datetime` ↗](https://docs.python.org/3/library/datetime.html) — aware and naive objects, `timedelta`, `strftime`
- [Format specification mini-language ↗](https://docs.python.org/3/library/string.html#formatspec) — everything after the colon in an f-string
