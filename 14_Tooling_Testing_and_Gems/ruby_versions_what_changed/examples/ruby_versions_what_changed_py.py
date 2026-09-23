# The same check for Python: which of the timeline's features does this
# interpreter have? Only features present in both 3.12 and 3.14 are asserted;
# what 3.13 and 3.14 added is described on the page, not keyed here.
import asyncio
import builtins
import importlib.util
import itertools
import sys
import typing


def compiles(src, mode="exec"):
    try:
        compile(src, "<snippet>", mode)
        return True
    except SyntaxError:
        return False


def row(n, release, feature, evidence):
    print(f"{n:2d}. {release:<4} {feature:<40} {evidence}")


row(1, "now", "sys.version_info >= (3, 12)", f"{sys.version_info >= (3, 12)}   (major {sys.version_info[0]})")
row(2, "3.8", "walrus :=, positional-only /",
    f"(y := 1) compiles: {compiles('(y := 1)', 'eval')}   def f(a, /, b): {compiles('def f(a, /, b): pass')}")
row(3, "3.9", "dict | dict, str.removeprefix",
    f"{{1: 1}} | {{2: 2}}: {({1: 1} | {2: 2}) == {1: 1, 2: 2}}   removeprefix: {hasattr(str, 'removeprefix')}")
row(4, "3.10", "match statement, zip(strict=), pairwise",
    f"match compiles: {compiles('match x:\n case 1: pass')}   zip strict: {compiles('zip([], strict=True)', 'eval')}   pairwise: {hasattr(itertools, 'pairwise')}")
row(5, "3.11", "ExceptionGroup, except*, tomllib, Self",
    f"ExceptionGroup: {hasattr(builtins, 'ExceptionGroup')}   except*: {compiles('try: pass\nexcept* ValueError: pass')}   "
    f"tomllib: {importlib.util.find_spec('tomllib') is not None}   typing.Self: {hasattr(typing, 'Self')}")
row(6, "3.12", "f-string quotes, type stmt, def f[T]",
    f"f\"{{\"a\"}}\": {compiles(chr(102) + chr(34) + '{' + chr(34) + 'a' + chr(34) + '}' + chr(34), 'eval')}   "
    f"type X = int: {compiles('type X = int')}   def f[T](x: T): {compiles('def f[T](x: T) -> T: return x')}")
row(7, "3.12", "itertools.batched, sys.monitoring",
    f"batched: {hasattr(itertools, 'batched')}   sys.monitoring: {hasattr(sys, 'monitoring')}   TaskGroup (3.11): {hasattr(asyncio, 'TaskGroup')}")
row(8, "3.13", "copy.replace, free threading, new REPL",
    "not asserted: hasattr(copy, 'replace') differs between this library's 3.12 and 3.14 runners")
row(9, "3.14", "t-strings, deferred annotations",
    "not asserted: compiles('t\"x\"') likewise differs, so the page describes both releases")
row(10, "both", "what rows 8 and 9 prove", "a feature check is worth exactly the set of interpreters it ran on")
