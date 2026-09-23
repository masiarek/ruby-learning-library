#!/usr/bin/env python3
"""Run every example, and hold its output to a recorded answer key.

This is the spine of the library. A lesson page never hand-types what a program
prints; it marks the spot and this tool fills it from a real run:

    <!-- output:bytes_plus_a_label_rb -->
    <!-- /output -->

Inside the markers is generated, outside is yours. There is a second kind,
`source:`, which pastes the program itself — for the pages where the code *is*
the lesson and a hand-copied fence could quietly drift from the file CI runs.

Three kinds of example, told apart by extension
-----------------------------------------------
    examples/<stem>.rb    run as `ruby -E UTF-8 <stem>.rb`, under Ruby 4.0 or later
    examples/<stem>.py    stdlib-only Python, run as `python3 -I <stem>.py` -- the twin
                          that asks Python the same question the Ruby program asks
    examples/<stem>.sh    run as `bash <stem>.sh`, with that same Ruby first on PATH

Which Python
------------
The Python twins run under the interpreter running this tool, unless `$PYTHON`
names another one. CI's Ubuntu runner has Python 3.12 and its macOS runner 3.14,
and a key must be what both print, so before recording a twin run it under both:

    PYTHON=/usr/local/bin/python3.12 python3 tools/run_examples.py --check --only X

Stems are unique repo-wide *across* extensions, because a Markdown block names a
bare stem with no path and no extension. The convention is a language suffix:
`blocks_are_not_objects_rb`, `blocks_are_not_objects_py`.

Which Ruby
----------
macOS still ships Ruby 2.6 as /usr/bin/ruby, and on a Mac without a version
manager that is the `ruby` on PATH. Its answer keys would describe a different
language -- no chilled literals, no `Regexp.linear_time?`, older Unicode, other
error-message quoting -- so this tool looks, in order, at `$RUBY`, at `ruby` on
PATH, and at Homebrew's keg, and takes the first that is 4.0 or later. It refuses
to run anything older rather than record it.

The pinned environment
----------------------
Every example runs with `LC_ALL=C`, `LANG=C`, and with `RUBYOPT`, `RUBYLIB`,
`PYTHONPATH` and `PYTHONSTARTUP` removed, so the key does not depend on
whoever ran it. Ruby is given `-E UTF-8` on top: under `LC_ALL=C` its default
external encoding is US-ASCII, and then `File.read` labels UTF-8 text as ASCII
and `p` prints an escape where the letter should be. `-E UTF-8` gives every
example what a reader's UTF-8 terminal gives them. The one lesson whose subject
is that locale default starts its own child processes, with their environment
written out in view.

Output is captured as bytes and decoded as UTF-8; a byte that is not valid UTF-8
is written into the key as `\\xNN`, which is deterministic. An example that exits
non-zero stops the run: a lesson about an exception rescues it and prints it.

Four modes
----------
    python3 tools/run_examples.py             verify + refill the .md blocks
    python3 tools/run_examples.py --update    accept current output as the key
    python3 tools/run_examples.py --check     write nothing; fail on any drift  (CI)
    python3 tools/run_examples.py --only X    touch example X and nothing else

``--only`` narrows both the running and the refilling to the stems you name.
A full ``--update`` re-records *every* answer key and refills *every* page, which
in a checkout open in two sessions means adopting whatever a colleague's
half-finished example happens to print. It is never right in CI: a partial run
cannot see repo-wide drift, which is the whole job there.
"""

from __future__ import annotations

import argparse
import difflib
import functools
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
MIN_RUBY = (4, 0)

# extension -> how the page labels the source fence
LANGS = {".rb": "ruby", ".py": "python", ".sh": "bash"}

# Where Homebrew puts its Ruby: Apple silicon first, then Intel.
HOMEBREW_RUBIES = ("/opt/homebrew/opt/ruby/bin/ruby", "/usr/local/opt/ruby/bin/ruby")

# Variables that would let a reader's shell change what an example prints.
STRIPPED = {
    "RUBYOPT", "RUBYLIB",
    "PYTHONPATH", "PYTHONSTARTUP",
}

# <!-- output:stem -->  ...generated...  <!-- /output -->
# <!-- source:stem -->  ...generated...  <!-- /source -->
BLOCK = re.compile(
    r"(?P<open><!--\s*(?P<kind>output|source):(?P<stem>[A-Za-z0-9_\-]+)\s*-->)"
    r"(?P<body>.*?)"
    r"(?P<close><!--\s*/(?P=kind)\s*-->)",
    re.DOTALL,
)

SKIP_DIRS = {".git", "site", ".venv", "__pycache__", ".github"}

# A fenced code block, opened or closed. The pages that DOCUMENT this mechanism
# (README.md, CONTRIBUTING.md) show the markers inside a fence — those are
# documentation, not blocks to fill.
FENCE = re.compile(r"^[ \t]*(?P<f>`{3,}|~{3,})", re.MULTILINE)


def fenced_spans(text: str) -> list[tuple[int, int]]:
    """Character ranges covered by fenced code blocks."""
    spans: list[tuple[int, int]] = []
    open_at: int | None = None
    open_fence = ""
    for m in FENCE.finditer(text):
        fence = m.group("f")
        if open_at is None:
            open_at, open_fence = m.start(), fence
        elif fence[0] == open_fence[0] and len(fence) >= len(open_fence):
            spans.append((open_at, m.end()))
            open_at = None
    if open_at is not None:
        spans.append((open_at, len(text)))
    return spans


def walk(root: Path):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            yield Path(dirpath) / name


def find_examples() -> dict[str, Path]:
    """Map stem -> path for every example under an examples/ folder. Stems are unique."""
    found: dict[str, Path] = {}
    for path in sorted(walk(REPO)):
        if path.suffix not in LANGS or path.parent.name != "examples":
            continue
        if path.stem in found:
            sys.exit(
                f"ERROR: duplicate example stem {path.stem!r}\n"
                f"  {found[path.stem].relative_to(REPO)}\n  {path.relative_to(REPO)}\n"
                "Stems are named bare in Markdown blocks, so they must be unique "
                "across languages too — add a _rb / _py / _sh suffix."
            )
        found[path.stem] = path
    return found


def ruby_version(exe: str) -> tuple[int, ...] | None:
    """(major, minor) of the Ruby at `exe`, or None if it does not run."""
    try:
        done = subprocess.run(
            [exe, "-e", "print RUBY_VERSION"], capture_output=True, text=True, timeout=30
        )
    except OSError:
        return None
    if done.returncode != 0:
        return None
    try:
        return tuple(int(part) for part in done.stdout.strip().split(".")[:2])
    except ValueError:
        return None


@functools.cache
def find_ruby() -> str:
    """The first Ruby 4.0+ among $RUBY, PATH and Homebrew. Exits if there is none."""
    candidates: list[tuple[str, str]] = []
    if os.environ.get("RUBY"):
        candidates.append(("$RUBY", os.environ["RUBY"]))
    on_path = shutil.which("ruby")
    if on_path:
        candidates.append(("PATH", on_path))
    candidates += [("Homebrew", p) for p in HOMEBREW_RUBIES if os.path.exists(p)]

    seen: list[str] = []
    for where, exe in candidates:
        version = ruby_version(exe)
        shown = ".".join(map(str, version)) if version else "did not run"
        seen.append(f"  {where:<9} {exe}  ->  {shown}")
        if version and version >= MIN_RUBY:
            return exe
    sys.exit(
        "ERROR: these examples need Ruby 4.0 or later. Looked at:\n"
        + "\n".join(seen or ["  (no ruby anywhere)"])
        + "\nInstall one (macOS: brew install ruby) or set RUBY=/path/to/ruby."
    )


def fixed_env() -> dict[str, str]:
    """One environment for every run, so the key is the program's and not the machine's."""
    env = {
        k: v
        for k, v in os.environ.items()
        if not (k.startswith("LC_") or k in {"LANG", "LANGUAGE"} or k in STRIPPED)
    }
    env.update({"LC_ALL": "C", "LANG": "C", "PYTHONUTF8": "1", "PYTHONIOENCODING": "utf-8"})
    # A shell example that types `ruby` gets the Ruby the .rb examples ran under.
    ruby_bin = str(Path(find_ruby()).parent)
    rest = [p for p in env.get("PATH", "").split(os.pathsep) if p and p != ruby_bin]
    env["PATH"] = os.pathsep.join([ruby_bin, *rest])
    return env


def _decode(raw: bytes) -> str:
    return raw.decode("utf-8", errors="backslashreplace")


def run_example(src: Path) -> str:
    """Run one example; return its stdout. Exits on failure.

    Run from the example's own folder so a page can tell the reader to `cd` there
    and type the same command. Python gets -I so a stray module beside it or on
    PYTHONPATH cannot change what the page claims.
    """
    if src.suffix == ".rb":
        cmd = [find_ruby(), "-E", "UTF-8", src.name]
    elif src.suffix == ".py":
        cmd = [os.environ.get("PYTHON") or sys.executable, "-I", src.name]
    else:
        cmd = ["bash", src.name]

    proc = subprocess.run(cmd, cwd=src.parent, capture_output=True, env=fixed_env(), timeout=120)
    if proc.returncode != 0:
        sys.exit(
            f"ERROR: {src.relative_to(REPO)} exited {proc.returncode}\n{_decode(proc.stderr)}"
        )
    if proc.stderr.strip():
        print(f"  note: {src.relative_to(REPO)} wrote to stderr:\n{_decode(proc.stderr)}")
    return _decode(proc.stdout)


def rendered_block(kind: str, src: Path, output: str, page: Path) -> str:
    """The generated body that goes between the markers on `page`."""
    href = os.path.relpath(src, page.parent)
    if kind == "source":
        body = src.read_text(encoding="utf-8").strip("\n")
        return (
            f"\n*[`{src.name}`]({href}) in full — pasted here by "
            f"`tools/run_examples.py` from the file CI runs.*\n\n"
            f"```{LANGS[src.suffix]}\n{body}\n```\n"
        )
    return (
        f"\n*Verified output of [`{src.name}`]({href}) — regenerated by "
        f"`tools/run_examples.py`, never hand-typed.*\n\n"
        f"```text\n{output.strip(chr(10))}\n```\n"
    )


def fill_pages(
    outputs: dict[str, str],
    sources: dict[str, Path],
    write: bool,
    problems: list[str],
    only: set[str] | None = None,
) -> list[str]:
    """Refill every generated block on every Markdown page. Returns drift.

    A block naming a stem that no longer exists is recorded in `problems` and left
    untouched rather than exiting on the spot — dying on the first one would leave
    every other page unfilled.

    With `only` set, a block naming any other stem is left exactly as it is. The
    selection is checked before the kind is, so a run scoped to one stem cannot
    rewrite either half of somebody else's page.
    """
    drift: list[str] = []
    for page in sorted(walk(REPO)):
        if page.suffix != ".md":
            continue
        text = page.read_text(encoding="utf-8")
        if "<!-- output:" not in text and "<!-- source:" not in text:
            continue
        skip = fenced_spans(text)

        def replace(m: re.Match) -> str:
            if any(lo <= m.start() < hi for lo, hi in skip):
                return m.group(0)
            stem, kind = m.group("stem"), m.group("kind")
            if only is not None and stem not in only:
                return m.group(0)
            known = sources if kind == "source" else outputs
            if stem not in known:
                problems.append(
                    f"{page.relative_to(REPO)}: asks for {kind} block {stem!r}, "
                    "but no examples/ file has that stem"
                )
                return m.group(0)
            return (
                m.group("open")
                + rendered_block(kind, sources[stem], outputs.get(stem, ""), page)
                + m.group("close")
            )

        new = BLOCK.sub(replace, text)
        if new != text:
            drift.append(str(page.relative_to(REPO)))
            if write:
                page.write_text(new, encoding="utf-8")
    return drift


def examples_under(token: Path, examples: dict[str, Path]) -> set[str]:
    """Every example stem inside `token`, if `token` names a directory."""
    for base in (token, REPO / token):
        try:
            if not base.is_dir():
                continue
            resolved = base.resolve()
        except OSError:
            continue
        held = {s for s, p in examples.items() if resolved in p.parents}
        if held:
            return held
    return set()


def resolve_selection(raw: list[str], examples: dict[str, Path]) -> set[str]:
    """Turn `--only` values into stems: a bare stem, a path to the file, or a folder.

    A token that names nothing is an error rather than an empty selection: a typo
    that records nothing looks exactly like a successful run.
    """
    wanted: set[str] = set()
    unknown: list[str] = []
    for token in (t.strip() for value in raw for t in value.split(",")):
        if not token:
            continue
        as_path = Path(token)
        held = examples_under(as_path, examples)
        if held:
            wanted |= held
            continue
        for candidate in (token, as_path.stem, as_path.name):
            if candidate in examples:
                wanted.add(candidate)
                break
        else:
            unknown.append(token)
    if unknown:
        sys.exit(
            f"ERROR: --only names no such example: {', '.join(unknown)}\n"
            f"Known stems: {', '.join(sorted(examples))}"
        )
    return wanted


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--update", action="store_true", help="record current output as the answer key")
    ap.add_argument("--check", action="store_true", help="write nothing; fail on drift (CI)")
    ap.add_argument(
        "--only",
        action="append",
        metavar="STEM[,STEM…]",
        help="restrict to these example stems (a path or a folder works too); "
        "repeat the flag or comma-separate. Not for CI.",
    )
    args = ap.parse_args()

    examples = find_examples()
    if not examples:
        print("No examples found (looked for *.rb / *.py / *.sh under any examples/ folder).")
        return 0

    selected = resolve_selection(args.only, examples) if args.only else None

    outputs: dict[str, str] = {}
    failures: list[str] = []

    for stem, src in sorted(examples.items()):
        key = src.with_suffix(".out")

        # Outside the selection: not ours. Not run, and deliberately not even
        # read — an output in hand is one `fill_pages` could write into someone
        # else's page.
        if selected is not None and stem not in selected:
            continue

        actual = run_example(src)
        outputs[stem] = actual

        if args.update:
            key.write_text(actual, encoding="utf-8")
            print(f"  recorded  {key.relative_to(REPO)}")
            continue
        if not key.exists():
            failures.append(f"{src.relative_to(REPO)}: no answer key — run with --update")
            continue
        recorded = key.read_text(encoding="utf-8")
        if recorded != actual:
            failures.append(f"{src.relative_to(REPO)}: output differs from {key.name}")
            # Print the diff here, not just the verdict: on a CI runner the
            # difference is usually a Linux/macOS quirk, and the log is the only
            # place anyone can see which line it was.
            print(f"  DIFF      {src.relative_to(REPO)} (recorded -> actual)")
            for line in difflib.unified_diff(
                recorded.splitlines(), actual.splitlines(),
                fromfile=key.name, tofile="actual", lineterm="", n=1,
            ):
                print("    " + line)
        else:
            print(f"  ok        {src.relative_to(REPO)}")

    drift = fill_pages(outputs, examples, write=not args.check, problems=failures, only=selected)

    if args.check and drift:
        failures.append(
            "Markdown output blocks are stale: " + ", ".join(drift)
            + " — run tools/run_examples.py"
        )
    elif drift:
        for page in drift:
            print(f"  filled    {page}")

    if failures:
        print("\nFAILED:")
        for f in failures:
            print(f"  - {f}")
        return 1

    if selected is not None:
        print(
            f"\n{len(selected)} of {len(examples)} example(s) verified. --only was in "
            f"effect: the other {len(examples) - len(selected)} were left untouched. "
            "Do a full run before committing."
        )
        return 0

    print(f"\n{len(examples)} example(s) verified against their recorded output.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
