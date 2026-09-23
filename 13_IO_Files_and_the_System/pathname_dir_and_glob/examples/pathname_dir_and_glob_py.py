# The Python twin: pathlib.Path, glob, os.path and tempfile, over the same
# small project tree.
import fnmatch
import glob
import os
import posixpath
import shutil
import tempfile
from pathlib import Path, PurePosixPath


def row(n, text, value=""):
    print(f"{n:2d}. {text:<56} {value}")


row(1, "the runner's cwd is the example's folder: its name", Path.cwd().name)
row(2, "Path(__file__).resolve().parent is this file's folder", Path(__file__).resolve().parent.name)

with tempfile.TemporaryDirectory() as d:
    os.chdir(d)
    os.makedirs("lib/deep")
    os.makedirs("spec")
    Path("lib/app.rb").write_text("print(1)\n")
    Path("lib/deep/util.rb").touch()
    Path("spec/app_spec.rb").touch()
    Path("README.md").write_text("# hi\n")
    Path("lib/notes.txt").touch()

    app = Path("lib") / "app.rb"
    row(3, 'Path("lib") / "app.rb"; joinpath', f"{app!r}; {Path('lib').joinpath('deep', 'util.rb')}")
    row(4, "name, suffix, parent, parent again, stem", [app.name, app.suffix, str(app.parent), str(app.parent), app.stem])
    row(5, "exists, is_file, is_dir, and a missing name", [app.exists(), app.is_file(), app.parent.is_dir(), Path("nope").exists()])
    row(6, "read_text and stat().st_size", f"{app.read_text()!r}, {app.stat().st_size}")
    row(7, "iterdir of lib, sorted", sorted(str(p) for p in Path("lib").iterdir()))
    row(8, "os.path.relpath(x, 'spec'); Path(x).relative_to('spec', walk_up=True)", f"{os.path.relpath('lib/deep/util.rb', 'spec')}; {Path('lib/deep/util.rb').relative_to('spec', walk_up=True)}")

    found = glob.glob("**/*.rb", recursive=True)
    row(9, 'glob.glob("**/*.rb", recursive=True), sorted by hand', f"{sorted(found)}; sorted=(no order is promised)")
    row(10, "no braces: two globs, joined and sorted", sorted(glob.glob("**/*.rb", recursive=True) + glob.glob("**/*.md", recursive=True)))
    row(11, "glob.glob for strings; Path.rglob gives Paths", f"{glob.glob('*.md')}; {sorted(str(p) for p in Path('lib').rglob('*.rb'))}")
    row(12, "os.listdir has no . and ..; os.scandir the same", f"{sorted(os.listdir('.'))} vs {sorted(e.name for e in os.scandir('.'))}")
    row(13, "a glob skips dotfiles unless include_hidden=True", f"{sorted(glob.glob('*'))}; {sorted(glob.glob('*', include_hidden=True))}")

    row(14, "os.path.join restarts at an absolute part", f"{os.path.join('lib', 'deep', 'util.rb')}; {os.path.join('a/', '/b')}")
    row(15, "posixpath.normpath(posixpath.join('/base/a', '../b'))", posixpath.normpath(posixpath.join("/base/a", "../b")))
    row(16, "posixpath.normpath('a//b/../c'); PurePosixPath keeps ..", f"{posixpath.normpath('a//b/../c')}; {PurePosixPath('a//b/../c')}")
    row(17, "Path(x).stem, splitext, dirname, dirname of a bare", [Path("/a/b/c.rb").stem, os.path.splitext("c.tar.gz"), os.path.dirname("/a/b/c.rb"), os.path.dirname("c.rb")])
    row(18, "with_suffix; is_absolute of lib and /lib; not absolute", [str(Path("x.tar.gz").with_suffix(".zip")), Path("lib").is_absolute(), Path("/lib").is_absolute(), not Path("lib").is_absolute()])
    row(19, "parts; parents", f"{list(app.parts)}; {[str(p) for p in app.parents]}")
    row(20, "fnmatch: * crosses /, and there is no PATHNAME flag", [fnmatch.fnmatch("lib/app.rb", "*.rb"), "n/a"])
    row(21, "no ftype: is_dir() and is_file()", [Path("lib").is_dir(), Path("lib/app.rb").is_file()])

    os.rename("README.md", "README.txt")
    renamed = glob.glob("README*")
    os.remove("README.txt")
    shutil.rmtree("spec")
    row(22, "os.rename; os.remove; shutil.rmtree (exists after)", f"{renamed}; {os.path.exists('README.txt')}; {os.path.isdir('spec')}")

    made = tempfile.mkdtemp(prefix="prefix-")
    prefixed = os.path.basename(made).startswith("prefix-")
    shutil.rmtree(made)
    row(23, "tempfile.mkdtemp(prefix=) without a with: made, removed", f"prefixed={prefixed}; gone={not os.path.isdir(made)}")
    os.chdir("/")
    row(24, "inside TemporaryDirectory's with the directory exists", os.path.isdir(d))
row(25, "after the with it is gone", os.path.isdir(d))
