# import loads a module once (sys.modules); importlib.reload and runpy.run_path
# run it again; a relative import resolves inside a package; LazyLoader defers.
import importlib
import importlib.util
import os
import runpy
import sys
import tempfile


def row(n, label, value=""):
    print(f"{n:2d}. {label:<42} {value}")


before = len(sys.modules)
was_loaded = "json" in sys.modules
import json  # noqa: E402

again = importlib.import_module("json")
row(1, "import json twice",
    f"first: loads (was cached: {was_loaded})   second: cached (same object: {again is json})")
row(2, "sys.modules (the once-dict)",
    f"grew: {len(sys.modules) > before}   holds json: {'json' in sys.modules}")

with tempfile.TemporaryDirectory() as d:
    pkg = os.path.join(d, "pkg")
    os.mkdir(pkg)
    open(os.path.join(pkg, "__init__.py"), "w").close()
    with open(os.path.join(pkg, "helper.py"), "w") as f:
        f.write('import os\n'
                'print("    (helper body ran, from", os.path.basename(os.path.dirname(__file__)) + ")")\n'
                'def hi():\n    return "hi"\n')
    with open(os.path.join(pkg, "main_part.py"), "w") as f:
        f.write('from . import helper\n'
                'print("    main_part sees helper.hi() =", helper.hi())\n')
    with open(os.path.join(d, "helper2.py"), "w") as f:
        f.write("print('    (helper2 body ran)')\n")
    with open(os.path.join(d, "greeter.py"), "w") as f:
        f.write("print('    (greeter body ran)')\nclass Greeter: pass\n")

    sys.path.insert(0, d)
    row(3, "import pkg.main_part, which does", "from . import helper inside the package:")
    main = importlib.import_module("pkg.main_part")
    row(4, "import pkg.main_part again", "nothing runs; both are remembered:")
    main_again = importlib.import_module("pkg.main_part")
    row(4, "", f"(same module object: {main_again is main})")
    row(5, "reload(helper); run_path(helper.py)", "each runs the body again:")
    importlib.reload(sys.modules["pkg.helper"])
    runpy.run_path(os.path.join(pkg, "helper.py"))

    row(6, f"sys.path is a {type(sys.path).__name__}; after insert(0, d)", "import helper2 (no extension):")
    import helper2  # noqa: E402

    again2 = importlib.import_module("helper2")
    row(6, "", f"found helper2.py: {helper2.__name__ == 'helper2'}   again: cached ({again2 is helper2})")

    try:
        import nope  # noqa: F401
    except ModuleNotFoundError as e:
        row(7, "import nope", f"{type(e).__name__}: {e}   (e.name: {e.name!r})")

    spec = importlib.util.find_spec("greeter")
    loader = importlib.util.LazyLoader(spec.loader)
    spec.loader = loader
    lazy = importlib.util.module_from_spec(spec)
    sys.modules["greeter"] = lazy
    loader.exec_module(lazy)
    row(8, "importlib.util.LazyLoader for greeter",
        f"registered: {'greeter' in sys.modules}   body ran yet: no")
    row(8, "", "first attribute access loads it:")
    klass = lazy.Greeter
    row(8, "", f"Greeter is {type(klass).__name__} {klass.__name__}")
