# The Python twin: a module is a file, a package is a folder, and both are
# objects you can look inside. Each numbered row is printed by the Ruby program too.

import importlib
import math
import shutil
import sys
import tempfile
import types
from pathlib import Path


def row(n, label, value):
    print(f"{n:2d}. {label:<62} {value}")


def failing(thunk):
    try:
        return thunk()
    except (AttributeError, TypeError) as e:
        return type(e).__name__          # messages are reworded between Python releases


class Item:                              # a top-level Item, in the module __main__
    def __repr__(self):
        return "<Item (__main__)>"


# The package, written to a temporary folder so that the import is a real one.
root = Path(tempfile.mkdtemp())
(root / "shop").mkdir()
(root / "shop" / "__init__.py").write_text(
    'VERSION = "1.0"\n'
    'def version():\n    return f"Shop {VERSION}"\n'
    'class Item:\n    def __repr__(self):\n        return "<shop.Item>"\n'
    'def slug(text):\n    return text.lower().replace(" ", "-")\n',
    encoding="utf-8",
)
(root / "shop" / "cart.py").write_text(
    'class Cart:\n    def __repr__(self):\n        return "<shop.cart.Cart>"\n',
    encoding="utf-8",
)
(root / "warehouse").mkdir()
(root / "warehouse" / "__init__.py").write_text(
    'class Item:\n    def __repr__(self):\n        return "<warehouse.Item>"\n',
    encoding="utf-8",
)
sys.path.insert(0, str(root))

import shop                              # noqa: E402  the folder shop/ with __init__.py
import shop.cart                         # noqa: E402  the file shop/cart.py
import warehouse                         # noqa: E402
from shop.cart import Cart               # noqa: E402

row(1, "shop/cart.py -- Cart's qualified name / Cart()",
    f"{Cart.__module__}.{Cart.__qualname__} / {Cart()!r}")
row(2, "shop.Item, warehouse.Item, Item -- the same class?",
    f"{shop.Item is warehouse.Item} / {shop.Item is Item} ({shop.Item()!r}, {warehouse.Item()!r})")
row(3, "module function: shop.slug / import_module / Cart().slug",
    f"{shop.slug('Hello World')!r} / {importlib.import_module('shop').slug('Hello World')!r} / {failing(lambda: Cart().slug('x'))}")
row(4, "def version() in __init__ -- shop.version() / public names",
    f"{shop.version()!r} / {sorted(n for n in vars(shop) if not n.startswith('_'))!r}")
row(5, "round(math.pi, 2) / math.sqrt(16) -- one dot for both",
    f"{round(math.pi, 2)} / {math.sqrt(16)} / (no :: form)")
row(6, "one dot for everything -- shop.Cart (never defined there)", failing(lambda: shop.Cart))
row(7, "shop.Item.__module__ / Item.__module__", f"{[shop.Item.__module__, Item.__module__]!r}")
row(8, "a module cannot be instantiated -- shop()", failing(lambda: shop()))
row(9, "classes in vars(shop) / getattr(shop, \"Item\")",
    f"{sorted(n for n, v in vars(shop).items() if isinstance(v, type))!r} / {getattr(shop, 'Item').__name__}")
util = types.ModuleType("util")          # 10. a module built in memory, no file at all
util.helper = lambda: "helped"
row(10, "type(shop).__name__ / types.ModuleType(\"util\").helper()",
    f"{type(shop).__name__} / {util.helper()!r}")

shutil.rmtree(root, ignore_errors=True)   # the package was only ever for this run
