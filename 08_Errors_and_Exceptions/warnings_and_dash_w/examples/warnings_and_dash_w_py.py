# warnings_and_dash_w_py.py -- the same eight rows put to Python through child
# interpreters: warnings.warn goes to stderr as file:line: Category: message,
# stacklevel, DeprecationWarning shown from __main__ only, -W error / -W ignore /
# -X dev, which categories are shown by default, the compiler's SyntaxWarnings as
# the nearest thing to -w, catch_warnings(record=True), and Warning is an Exception.
# Stderr lines that CPython lays out differently in 3.12 and 3.14 (the indented
# source echo, the Traceback header) are dropped; temp-dir paths are cut to the base name.

import os
import re
import subprocess
import sys
import tempfile
import warnings


def child(label, *flags, code):
    done = subprocess.run([sys.executable, "-I", *flags, "-c", code], capture_output=True, text=True)
    print(f"   {label}")
    for line in done.stdout.splitlines():
        print(f"      stdout: {line}")
    for line in done.stderr.splitlines():
        if line and not line.startswith(" ") and not line.startswith("Traceback"):
            print(f"      stderr: {re.sub(r'^\S*/', '', line)}")
    print(f"      exit status: {done.returncode}")


print("1. warnings.warn writes to stderr, not stdout")
child("warnings.warn('careful'); print('out')", code='import warnings; warnings.warn("careful"); print("out")')

print("2. the prefix is always file:line: Category; stacklevel=2 blames the caller")
child("warn from inside old(), default stacklevel",
      code='import warnings\ndef old():\n    warnings.warn("old api")\nold()')
child("warn from inside old(), stacklevel=2",
      code='import warnings\ndef old():\n    warnings.warn("old api", stacklevel=2)\nold()')

print("3. DeprecationWarning is shown from __main__ only; -W default and -X dev show it everywhere")
child("python3 -c 'warnings.warn(\"old\", DeprecationWarning)'", code='import warnings; warnings.warn("old", DeprecationWarning); print("out")')
with tempfile.TemporaryDirectory() as tmp:
    with open(os.path.join(tmp, "oldlib.py"), "w") as f:
        f.write('import warnings\n\n\ndef old():\n    warnings.warn("old api", DeprecationWarning)\n')
    code = f'import sys; sys.path.insert(0, {tmp!r}); import oldlib; oldlib.old(); print("out")'
    child("the same warning raised inside an imported module", code=code)
    child("... under python3 -W default", "-W", "default", code=code)
    child("... under python3 -X dev", "-X", "dev", code=code)

print("4. -W error turns a warning into an exception; -W ignore silences it")
child("python3 -W error -c '...'", "-W", "error", code='import warnings; warnings.warn("careful"); print("out")')
child("python3 -W ignore -c '...'", "-W", "ignore", code='import warnings; warnings.warn("careful"); print("out")')

print("5. the categories, and whether a warning of each is shown from __main__ by default")
for name in ("UserWarning", "DeprecationWarning", "PendingDeprecationWarning", "SyntaxWarning",
             "RuntimeWarning", "FutureWarning", "ImportWarning", "ResourceWarning"):
    done = subprocess.run([sys.executable, "-I", "-c", f'import warnings; warnings.warn("x", {name})'],
                          capture_output=True, text=True)
    print(f"   {name:<26} {'shown' if name in done.stderr else 'hidden'}")

print("6. no -w: the closest thing is the compiler's SyntaxWarning")
child("if 'a' is 'a': ...", code='if "a" is "a":\n    print("compared")')
child("assert (1, 'msg')", code='assert (1, "msg")')

print("7. capturing warnings in-process with catch_warnings(record=True)")
with warnings.catch_warnings(record=True) as caught:
    warnings.simplefilter("always")
    warnings.warn("captured one")
    warnings.warn("captured two", DeprecationWarning)
print(f"   captured {[(str(w.message), w.category.__name__) for w in caught]!r}")

print("8. a Warning is an Exception, which is what makes -W error possible")
print(f"   DeprecationWarning.__mro__ {[c.__name__ for c in DeprecationWarning.__mro__]}")
child("python3 -X dev: sys.flags.dev_mode", "-X", "dev", code="import sys; print(sys.flags.dev_mode, sys.warnoptions)")
child("default: sys.flags.dev_mode", code="import sys; print(sys.flags.dev_mode, sys.warnoptions)")
