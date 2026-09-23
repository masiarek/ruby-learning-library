# The Python twin: which implementation, which flags, and what a child started
# with another flag reports. The 3.13 experimental JIT and free-threaded build
# have no switch that both CI Pythons (3.12 and 3.14) share, so they stay in prose.

import ast
import dis
import gc
import platform
import subprocess
import sys


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


def child(*args):
    done = subprocess.run([sys.executable, "-I", *args], capture_output=True, text=True)
    return [done.stdout.strip(), done.returncode == 0]


def raises(fn):
    try:
        return fn()
    except Exception as e:  # noqa: BLE001 - the class is the result
        return type(e).__name__


def set_optimize():
    sys.flags.optimize = 1


row(1, "sys.implementation.name, platform.python_implementation()", [sys.implementation.name, platform.python_implementation()])
row(2, "sys.version_info >= (3, 12)", sys.version_info >= (3, 12))
row(3, "sys.flags.optimize in this process (no flag)", sys.flags.optimize)
row(4, "child -O -c 'print(sys.flags.optimize, __debug__)'", child("-O", "-c", "import sys; print(sys.flags.optimize, __debug__)"))
row(5, "flags under -I: isolated, ignore_environment, safe_path", [sys.flags.isolated, sys.flags.ignore_environment, sys.flags.safe_path])
row(6, "sys.flags.optimize = 1 at runtime raises", raises(set_optimize))
row(7, "a JIT switch in sys.flags? hasattr(sys.flags, 'jit')", hasattr(sys.flags, "jit"))
row(8, "dis.opmap has BINARY_OP, LOAD_CONST, RETURN_VALUE", [name in dis.opmap for name in ("BINARY_OP", "LOAD_CONST", "RETURN_VALUE")])
row(9, "sys.getrecursionlimit(), sys.getswitchinterval()", [sys.getrecursionlimit(), sys.getswitchinterval()])
row(10, "one parser: ast root here; child -X oldparser (ignored)", [type(ast.parse("1 + 2")).__name__, child("-X", "oldparser", "-c", "import ast; print(type(ast.parse('1 + 2')).__name__)")])
row(11, "callable(gc.freeze) (3.7: tidy up before fork)", callable(gc.freeze))
row(12, "hasattr(sys, 'monitoring') (3.12: the event API)", hasattr(sys, "monitoring"))
