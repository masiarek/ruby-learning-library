# Python's twin: the stdlib is the "default gems", site-packages the installed
# ones; importlib.metadata reads what pip installed; tomllib reads pyproject.toml.
import builtins
import importlib
import importlib.metadata
import sys
import tomllib


def row(n, label, value=""):
    print(f"{n:2d}. {label:<38} {value}")


std = sys.stdlib_module_names
row(1, "json: part of the standard install?", f"stdlib module: {'json' in std}")
row(2, "csv: part of the standard install?", f"stdlib module: {'csv' in std}   (Ruby moved csv out; Python did not)")
row(3, "minitest / unittest:", f"minitest: {'minitest' in std}   unittest: {'unittest' in std}")
row(4, "set:", f"builtin type: {'set' in dir(builtins)} -- no module at all")

import json  # noqa: E402

try:
    importlib.metadata.version("json")
    meta = "has package metadata"
except importlib.metadata.PackageNotFoundError as e:
    meta = f"no package metadata ({type(e).__name__}: the stdlib is not a package)"
row(5, "what import json loaded", f"json.__spec__.name = {json.__spec__.name}; {meta}")

first = importlib.import_module("unittest")
second = importlib.import_module("unittest")
row(6, "no gem 'x' in code: import just finds", f"first: loads   second: cached (same object: {first is second})")

try:
    importlib.metadata.version("nope")
except importlib.metadata.PackageNotFoundError as e:
    row(7, "importlib.metadata.version('nope')",
        f"{type(e).__name__}   is a ModuleNotFoundError: {isinstance(e, ModuleNotFoundError)}   e.name: {e.name!r}")


def ver(s):
    return tuple(int(part) for part in s.split("."))


row(8, "versions compare as numbers",
    f"tuples (1, 10) > (1, 9): {ver('1.10') > ver('1.9')}   as strings: {'1.10' > '1.9'}   "
    f"(no Version class in the stdlib)")
row(9, "a requirement, ~= 1.2 by hand",
    f"satisfied by 1.9: {(1, 2) <= ver('1.9') < (2, 0)}   by 2.0: {(1, 2) <= ver('2.0') < (2, 0)}")

pyproject = tomllib.loads('''
[project]
name = "demo"
version = "0.1.0"
dependencies = ["minitest~=5.0", "csv"]

[project.optional-dependencies]
dev = ["rake"]
''')
project = pyproject["project"]
row(10, "a pyproject.toml, read by tomllib",
    f"dependencies: {project['dependencies']}   dev: {project['optional-dependencies']['dev']}")
row(11, "the [project] table is the gemspec",
    f"{project['name']}-{project['version']}   (name, version, dependencies in one file)")
