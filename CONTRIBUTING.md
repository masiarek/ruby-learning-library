# Conventions

House rules for writing a page here. Readers browsing lessons do not need this file; it is for whoever is about to add one.

## The rule that comes before the others

**A page never claims something a program has not printed — on both machines.** CI runs every example on `ubuntu-latest` and `macos-latest`, under Ruby 4.0 from `ruby/setup-ruby` and under the Python 3 each runner image ships — **3.12 on Ubuntu, 3.14 on macOS** — and an answer key is only what both agree on. A sentence that no program here backs, such as a remark about how a JIT performs or what a language did in 2007, ends with *(Not machine-checked here.)* or links to the sibling library page that does check it.

## The shape of a lesson

```
03_Blocks_Procs_and_Lambdas/
  closures_capture_variables/
    README.md                                   the lesson
    examples/
      closures_capture_variables_rb.rb          the Ruby program
      closures_capture_variables_rb.out         its recorded output (generated — do not hand-edit)
      closures_capture_variables_py.py          the Python twin: the same question, asked of Python
      closures_capture_variables_py.out         its recorded output
      closures_capture_variables_kata_rb.rb     the solution to the page's first exercise
      closures_capture_variables_kata_rb.out    its recorded output
```

One idea per folder. The folder name is the idea, in `lower_snake_case`, and it becomes a permanent URL — name it for what it teaches, not for where it sits in the reading order. A page names an example by its bare stem, so stems must be unique across languages: the suffix is `_rb`, `_py` or `_sh`, and a kata solution is `_kata_rb`.

## The page

Every lesson has the same sections, in this order. `tools/check_pages.py` fails a page that is missing one.

```markdown
# The title is a claim

**Level:** 201 · who this page is for

**One line:** the claim, stated so a reader can decide in five seconds whether this is their page.

The mechanism, in prose. One paragraph, one line — do not hard-wrap.

<!-- output:the_title_is_a_claim_rb -->
<!-- /output -->

## Reading the output

What the run shows, paragraph by paragraph or line by line.

## Compared with Python

The contrast, in prose, then the twin's output, then the link to the Python library's page on the same idea when there is one.

<!-- output:the_title_is_a_claim_py -->
<!-- /output -->

## Try it

1. An exercise a reader can do in ten minutes with what the page taught.
2. A second one that reaches a little further.

<details markdown="1">
<summary><strong>Solution to 1</strong></summary>

<!-- source:the_title_is_a_claim_kata_rb -->
<!-- /source -->

<!-- output:the_title_is_a_claim_kata_rb -->
<!-- /output -->

</details>

## See also

- [A neighbouring lesson](../neighbour/README.md) — why a reader of this page would go there
- [A lesson in another chapter](../../07_The_Object_Model/singleton_classes/README.md) — likewise
- [The Python library's page ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/counting_characters/index.html) — what it measures that this page does not
```

`**Level:**` is `101` / `201` / `301`, then `·`, then who it is for. The one-line summary states the *claim*, not the topic. Put the output block early; explain it after.

**The Python comparison is a measurement.** The `_py.py` twin asks Python the question the Ruby program asked, prints the answer in the same shape, and the page's *Compared with Python* section reads the two outputs against each other. Where the Python library already has a page on the idea, link it there — with ` ↗` — rather than repeating it.

## Output is generated, never typed

Mark the spot and let the tool fill it:

```markdown
<!-- output:closures_capture_variables_rb -->
<!-- /output -->
```

`tools/run_examples.py` runs the example and pastes what it actually printed, with a provenance line above the fence. Inside the markers is generated; outside is yours. A second kind, `<!-- source:stem -->`, pastes the program itself — used for kata solutions, where the code is the answer.

```bash
python3 tools/run_examples.py                      # verify + refill
python3 tools/run_examples.py --update --only X    # record X's output as its answer key
python3 tools/run_examples.py --check              # write nothing, fail on drift (CI)
python3 tools/check_all.py --staged                # every gate CI runs, on what you are about to commit
```

**Always pass `--only` with `--update`**, and read what it recorded before committing: `--update` accepts whatever the program printed, so it will happily enshrine a bug. `--only` takes a stem, a file path or a folder, so `--only 03_Blocks_Procs_and_Lambdas/closures_capture_variables` records one lesson's three programs at once.

## The programs

**Ruby: 4.0 or later, run as `ruby -E UTF-8 <file>` from the example's folder, under `LC_ALL=C`.** The tool finds the Ruby itself (`$RUBY`, `PATH`, Homebrew) and refuses an older one. Core, default gems and bundled gems only — `json`, `set`, `minitest`, `csv`, `bigdecimal` and `debug` all ship with Ruby 4.0; nothing is installed. Ruby 4.0 bundles Minitest 6, which no longer ships `minitest/mock` (it moved to the `minitest-mock` gem), so a test double here is a singleton method. A lesson whose subject is a command-line flag, a warning or an exit status starts a child Ruby with `RbConfig.ruby` and prints what the child did, in view.

**Python: standard library, run as `python3 -I`, and it must print the same thing under 3.12 and 3.14.** CI's two runners differ in exactly that, so before recording a twin run it under both — `/usr/local/bin/python3.12` on the machine this library was started on:

```bash
python3 tools/run_examples.py --update --only X
PYTHON=/usr/local/bin/python3.12 python3 tools/run_examples.py --check --only X
```

An exception's message is not API in either language — CPython rewords them between releases, and Ruby 3.4 changed how a method name is quoted — so a key prefers `e.class` / `type(e).__name__` unless the message *is* the lesson. `dis` output, `ast.dump` output, `locals()` write-through, `sys.getrefcount` numbers and `sys._is_gil_enabled` all differ between 3.12 and 3.14: describe them, do not key them.

**Shell: `bash`, in a `mktemp -d` directory, printing each command before running it**, so a verified block reads like a terminal. `ruby` on the script's `PATH` is the Ruby the `.rb` examples ran under.

**Write non-ASCII characters as escapes that brace or name them:** `"\u{e9}"` in Ruby, `"\N{LATIN SMALL LETTER E WITH ACUTE}"` in Python. A source file then never depends on an editor, a terminal or a tool keeping an invisible character intact. Avoid the four-digit backslash-u form: at least one tool that writes files here decodes it on the way to disk.

**Deterministic, on both machines.** These are the things that print differently from one run or one machine to the next; none of them may reach a key:

- **Object addresses.** Ruby's default `inspect` prints `#<Foo:0x000...>` and Python's default `repr` prints `<Foo object at 0x...>`. Define `inspect` / `__repr__`, or print the class name.
- **`object_id`, `id()`, `hash`.** Ruby seeds `String#hash` per process; Python randomizes `hash(str)` per process. Print whether two ids or hashes are *equal*, never the numbers.
- **Iteration order of a Python `set` of strings** — randomized by the same hash seed. Sort before printing.
- **Unstable sort orders.** Ruby's `sort`/`sort_by` are not stable, and which order they produce for equal keys depends on the platform's sort routine. Print a stable idiom's result, or a check that the order is *valid*, never the raw unstable order.
- **Timings, clocks, `Time.now`, `Process.pid`, temporary-directory names, `RUBY_PLATFORM`, `RUBY_DESCRIPTION`, `RUBY_VERSION` beyond the major release, `sys.version` beyond `(3,)`.**
- **Counts of a version-sized thing:** `Object.instance_methods.size`, `ObjectSpace.each_object.count`, `Symbol.all_symbols.size`. Print a membership check or a comparison instead.
- **Thread and process interleavings.** Join, collect through a `Queue`, then print in a fixed order.

**Stderr is not keyed.** The runner records stdout only, and notes an example that wrote to stderr; a lesson about a warning captures the warning (`Warning.warn` override, `Open3.capture3` on a child) and prints it on stdout. Ractor examples set `Warning[:experimental] = false` first.

**An exception is a result.** Rescue it and print its class and message; the runner stops on an example that exits non-zero.

**Written to be read aloud.** Numbered sections, aligned columns, prose in the print statements. A reader should understand the output without the page and the page without the output — and the Ruby program and its Python twin print the same rows in the same order, so the two blocks can be read side by side.

## Two machines

CI's *Show toolchain* step prints what each runner has. Measured differences between the two go here, with the date — add a row when CI finds one:

| | Ubuntu runner | macOS runner |
|---|---|---|
| CPU | x86-64 | arm64 |
| Ruby | 4.0.7, from `ruby/setup-ruby`, with YJIT | 4.0.7, from `ruby/setup-ruby`, with YJIT |
| `python3` | 3.12.3 | 3.14.7 |
| `bash` | 5.2.21 | 3.2.57 |

The runner versions are from the first CI run, on 2026-09-23, and all 387 examples printed the same on both. The keys were recorded on an x86-64 Mac with Ruby 4.0.0 (Homebrew) and Python 3.14.7, and every Python twin was also run under Python 3.12 there; the Numbers chapter's platform-sensitive values (`format("%.2f", …)`, `Float#round`, seeded `Random`) were additionally run under `ruby:4.0-slim` on Linux x86-64 and arm64 before recording.

## Cross-references

Every lesson links its neighbours and is linked back: `python3 tools/check_pages.py --backlinks` reports a lesson-to-lesson link that is not returned, and `--fix` appends the return link under the target's *See also*. Links to the sibling libraries are the point of this one, and go both ways too — when a page here links a Python library page, that page gets a *See also* bullet back.

- In a table cell, do not put `||` inside backticks: the site's Markdown keeps the `\|` escape literally inside a code span where GitHub shows `||`. Reword the cell, or move the code out of the table.
- Link a folder by naming its `README.md` — `[label](some_folder/README.md)`, never `[label](some_folder/)`.
- **A link that leaves the library ends its label with ` ↗`**; an internal link never does. `python3 tools/check_link_style.py --fix` adds and removes them; CI runs it without `--fix`.
- A sibling library's page is linked as `https://masiarek.github.io/<library>/<chapter>/<lesson>/index.html`, and a root page as `.../<NAME>.html`. Check the page exists before linking it.

The siblings, for the comparisons a page reaches for:

- [Python ↗](https://masiarek.github.io/python-learning-library/) — the twin of every page here.
- [Ruby text ↗](https://masiarek.github.io/ruby-text-learning-library/) — strings, encodings, regex, literals and the Perl heritage. This library links there rather than repeating it.
- [Regex ↗](https://masiarek.github.io/regex-learning-library/) — one regex question per page, with a Ruby column.
- [Concurrency ↗](https://masiarek.github.io/concurrency-learning-library/) — the ideas behind chapter 12, in six other languages.
- [Encodings ↗](https://masiarek.github.io/encodings-learning-library/), [Perl ↗](https://masiarek.github.io/perl-learning-library/), [Rust ↗](https://masiarek.github.io/rust-learning-library/), [C ↗](https://masiarek.github.io/c-learning-library/), [Java text ↗](https://masiarek.github.io/java-text-learning-library/), [Go ↗](https://masiarek.github.io/go-learning-library/), [Linux ↗](https://masiarek.github.io/linux-learning-library/), [Math ↗](https://masiarek.github.io/math-learning-library/), [ABAP ↗](https://masiarek.github.io/abap-learning-library/).

## Nav order

A new lesson folder gets a row in `NAV_ORDER` in `mkdocs_hooks.py` and a row in its chapter's README table. Its sidebar label is its README's `# H1` with the backticks dropped; give it an entry in `LABEL_OVERRIDES` only when that H1 is too long for a sidebar. `tools/check_nav_chain.py` fails on a row naming a folder that does not exist, so commit the folder and its row together.
