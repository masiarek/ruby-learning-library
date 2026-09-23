#!/usr/bin/env python3
"""Every lesson has what a lesson here needs, and the links run both ways.

A lesson is a folder inside a numbered chapter -- `01_Objects_and_Values/`
`nil_false_and_truthiness/` -- holding a README.md and an examples/ folder. For
every lesson this gate checks that:

  1. the page opens with an H1, a `**Level:**` line and a `**One line:**` line;
  2. it carries the three sections every lesson here has -- `## Compared with
     Python`, `## Try it` and `## See also` -- and See also holds a link;
  3. examples/ holds at least one Ruby program (`*_rb.rb`) and one Python twin
     (`*_py.py`), and every program there has its recorded `.out` key beside it;
  4. the chapter's README.md links the lesson, so the shelf lists it;
  5. `NAV_ORDER` in mkdocs_hooks.py lists the folder, so the sidebar places it.

With --backlinks it also follows every link from one lesson to another and
requires the link to be returned: a comparison that only one of the two pages
knows about is half-built. --fix appends the missing return links under the
target's See also, labelled with the source page's title and its one-line claim.

    python3 tools/check_pages.py                                  # exit 1 on a problem
    python3 tools/check_pages.py --chapter 03_Blocks_Procs_and_Lambdas
    python3 tools/check_pages.py --backlinks                      # also require return links
    python3 tools/check_pages.py --backlinks --fix                # and write them

Links are read outside fenced code only, so a page that quotes a link inside a
code block is not asked to return it.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
CHAPTER = re.compile(r"^\d\d_")
FENCE = re.compile(r"^\s*(```|~~~)")
LINK = re.compile(r'(?<!!)\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)')
REQUIRED_SECTIONS = ("## Compared with Python", "## Try it", "## See also")
EXAMPLE_SUFFIXES = (".rb", ".py", ".sh")


def chapters(only: str | None = None) -> list[Path]:
    return [
        d
        for d in sorted(REPO.iterdir())
        if d.is_dir() and CHAPTER.match(d.name) and (only is None or d.name == only)
    ]


def lessons_in(chapter: Path) -> list[Path]:
    return [d for d in sorted(chapter.iterdir()) if d.is_dir() and (d / "README.md").exists()]


def prose(text: str) -> list[tuple[int, str]]:
    """(line number, line) for every line outside a fenced code block."""
    out = []
    fenced = False
    for n, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            fenced = not fenced
            continue
        if not fenced:
            out.append((n, line))
    return out


def links_in(text: str) -> list[tuple[str, str]]:
    found = []
    for _, line in prose(text):
        for m in LINK.finditer(line):
            found.append((m.group(1), m.group(2)))
    return found


def h1_of(text: str) -> str:
    for _, line in prose(text):
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def one_line_of(text: str) -> str:
    for _, line in prose(text):
        if line.startswith("**One line:**"):
            return line[len("**One line:**"):].strip()
    return ""


def nav_order() -> dict[str, list[str]]:
    sys.path.insert(0, str(REPO))
    import mkdocs_hooks  # noqa: E402

    return mkdocs_hooks.NAV_ORDER


def check_lesson(lesson: Path, nav: dict[str, list[str]]) -> list[str]:
    rel = lesson.relative_to(REPO)
    page = lesson / "README.md"
    text = page.read_text(encoding="utf-8")
    problems: list[str] = []
    lines = [line for _, line in prose(text)]

    if not h1_of(text):
        problems.append(f"{rel}/README.md: no `# ` title")
    if not any(line.startswith("**Level:**") for line in lines):
        problems.append(f"{rel}/README.md: no `**Level:**` line")
    if not one_line_of(text):
        problems.append(f"{rel}/README.md: no `**One line:**` claim")
    for heading in REQUIRED_SECTIONS:
        if not any(line.rstrip() == heading for line in lines):
            problems.append(f"{rel}/README.md: no `{heading}` section")

    see_also = [line for line in lines[lines.index("## See also"):] if line.startswith("- [")] if "## See also" in lines else []
    if "## See also" in lines and not see_also:
        problems.append(f"{rel}/README.md: See also has no link")

    examples = lesson / "examples"
    if not examples.is_dir():
        problems.append(f"{rel}: no examples/ folder")
    else:
        programs = [p for p in sorted(examples.iterdir()) if p.suffix in EXAMPLE_SUFFIXES]
        if not any(p.name.endswith("_rb.rb") for p in programs):
            problems.append(f"{rel}/examples: no Ruby program (*_rb.rb)")
        if not any(p.name.endswith("_py.py") for p in programs):
            problems.append(f"{rel}/examples: no Python twin (*_py.py)")
        for p in programs:
            if not p.with_suffix(".out").exists():
                problems.append(f"{rel}/examples/{p.name}: no recorded .out key -- run tools/run_examples.py --update --only {p.stem}")

    chapter_readme = lesson.parent / "README.md"
    if not chapter_readme.exists():
        problems.append(f"{lesson.parent.relative_to(REPO)}: no chapter README.md")
    elif f"]({lesson.name}/README.md)" not in chapter_readme.read_text(encoding="utf-8"):
        problems.append(f"{lesson.parent.relative_to(REPO)}/README.md: does not link {lesson.name}/README.md")

    if lesson.name not in nav.get(lesson.parent.name, []):
        problems.append(f"mkdocs_hooks.py: NAV_ORDER[{lesson.parent.name!r}] does not list {lesson.name!r}")

    return problems


def resolve(page_dir: Path, href: str) -> Path | None:
    if href.startswith(("http://", "https://", "#", "mailto:")):
        return None
    target = (page_dir / href.split("#", 1)[0]).resolve()
    return target


def missing_backlinks(all_lessons: list[Path]) -> list[tuple[Path, Path]]:
    """(source lesson, target lesson) pairs where target never links back."""
    known = {d.resolve() for d in all_lessons}
    cache: dict[Path, str] = {}

    def text_of(d: Path) -> str:
        if d not in cache:
            cache[d] = (d / "README.md").read_text(encoding="utf-8")
        return cache[d]

    missing: list[tuple[Path, Path]] = []
    seen: set[tuple[Path, Path]] = set()
    for src in all_lessons:
        s = src.resolve()
        for _, href in links_in(text_of(src)):
            target = resolve(src, href)
            if target is None or target.name != "README.md":
                continue
            tdir = target.parent
            if tdir not in known or tdir == s or (s, tdir) in seen:
                continue
            seen.add((s, tdir))
            returns = any(
                (r := resolve(tdir, h)) is not None and r == s / "README.md"
                for _, h in links_in(text_of(tdir))
            )
            if not returns:
                missing.append((src, tdir))
    return missing


def append_see_also(target: Path, bullet: str) -> None:
    page = target / "README.md"
    lines = page.read_text(encoding="utf-8").split("\n")
    try:
        start = next(i for i, line in enumerate(lines) if line.rstrip() == "## See also")
    except StopIteration:
        while lines and lines[-1].strip() == "":
            lines.pop()
        lines += ["", "## See also", "", bullet, ""]
        page.write_text("\n".join(lines), encoding="utf-8")
        return
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("## ")), len(lines))
    last = start
    for i in range(start + 1, end):
        if lines[i].strip():
            last = i
    lines.insert(last + 1, bullet)
    page.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--chapter", help="check one chapter folder only")
    ap.add_argument("--backlinks", action="store_true", help="require every lesson-to-lesson link to be returned")
    ap.add_argument("--fix", action="store_true", help="with --backlinks: append the missing return links")
    args = ap.parse_args()

    nav = nav_order()
    chosen = chapters(args.chapter)
    if args.chapter and not chosen:
        print(f"check_pages: no chapter folder named {args.chapter!r}")
        return 2

    problems: list[str] = []
    all_lessons: list[Path] = []
    for chapter in chosen:
        if not (chapter / "README.md").exists():
            problems.append(f"{chapter.name}: no README.md")
        for lesson in lessons_in(chapter):
            all_lessons.append(lesson)
            problems += check_lesson(lesson, nav)

    fixed = 0
    if args.backlinks:
        # Return links are checked across the whole library even when one
        # chapter was chosen: the page that must link back may be elsewhere.
        universe = [l for ch in chapters() for l in lessons_in(ch)]
        pairs = missing_backlinks(universe)
        if args.chapter:
            chosen_dirs = {l.resolve() for l in all_lessons}
            pairs = [(s, t) for s, t in pairs if s.resolve() in chosen_dirs or t in chosen_dirs]
        for src, tdir in pairs:
            src_text = (src / "README.md").read_text(encoding="utf-8")
            title = h1_of(src_text)
            why = one_line_of(src_text)
            why = re.split(r" — | -- ", why, maxsplit=1)[0].rstrip(".")
            if len(why) > 110:
                why = why[:107].rsplit(" ", 1)[0] + "…"
            href = os.path.relpath(src / "README.md", tdir)
            if args.fix:
                append_see_also(tdir, f"- [{title}]({href}) — {why}")
                fixed += 1
            else:
                problems.append(
                    f"{tdir.relative_to(REPO)}/README.md: does not link back to "
                    f"{src.relative_to(REPO)} (run with --backlinks --fix)"
                )

    if fixed:
        print(f"check_pages: appended {fixed} return link(s) under See also.")
    if problems:
        print(f"check_pages: {len(problems)} problem(s)\n")
        for p in problems:
            print(f"  {p}")
        return 1
    print(f"check_pages: {len(all_lessons)} lesson(s) in {len(chosen)} chapter(s) have every part a lesson needs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
