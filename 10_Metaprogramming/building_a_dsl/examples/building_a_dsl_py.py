"""building_a_dsl_py.py -- the same rows: a class-body DSL, decorators, `with` and keyword arguments."""

from contextlib import contextmanager


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Config:
    class Error(Exception):
        pass

    def __init_subclass__(cls, **kwargs):              # 1. the class body IS the DSL
        super().__init_subclass__(**kwargs)
        body = {k: v for k, v in vars(cls).items() if not k.startswith("__")}
        cls.settings = {k: (v.settings if isinstance(v, type) else v) for k, v in body.items()}
        if "port" not in cls.settings:
            raise Config.Error("port is required")     # 10. validation


class App:
    def __init__(self):
        self.routes = {}

    def route(self, path):                             # 6. a decorator stores the function
        def register(fn):
            self.routes[path] = fn
            return fn
        return register

    def call(self, path):                              # 7. the app is passed in explicitly
        return self.routes[path](self, path)

    def redirect_to(self, path):
        return f"redirect to {path}"


class Cfg:                                             # 8, 9. a plain object for `with` and **kwargs
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)

    def __repr__(self):
        return "Cfg(" + ", ".join(f"{k}={v!r}" for k, v in vars(self).items()) + ")"


@contextmanager
def edit(cfg):
    yield cfg
    if not hasattr(cfg, "port"):
        raise Config.Error("port is required")


default_port = 8080


class Site(Config):
    host = "example.org"
    port = 80
    timeout = 30                                       # 3. any name is just an assignment

    class database(Config):                            # 4. nesting is a nested class
        adapter = "pg"
        port = 5432


row(1, "class Site(Config): host = ...; port = 80", Site.settings)
row(2, "Site.host", repr(Site.host))
row(3, "timeout = 30 -- no hook needed for a new key", Site.settings["timeout"])
row(4, "class database(Config): adapter = 'pg' -- nested", repr(Site.settings["database"]["adapter"]))


def configure():
    local = 8080

    class Body(Config):
        port = local                                   # sees the enclosing function's local
        plus_one = port + 1                            # sees an earlier body name

        def sees_method(self):
            return port                                # a nested def does NOT see body names
    try:
        Body().sees_method()
        seen_from_def = "sees it"
    except NameError:
        seen_from_def = "NameError"
    return Body.port, Body.plus_one, seen_from_def


sees_local, sees_earlier, seen_from_def = configure()
row(5, "class body sees: local / earlier name / from a def", f"{sees_local} / {sees_earlier} / {seen_from_def}")

app = App()


@app.route("/")
def home(app, path):
    return app.redirect_to("/home")


@app.route("/about")
def about(app, path):
    return f"about page ({path})"


row(6, 'app.call("/about") -- a stored function', repr(app.call("/about")))
row(7, 'app.call("/") -- the app arrives as a parameter', repr(app.call("/")))

cfg = Cfg()
with edit(cfg) as c:                                   # 8. `with` is the yielded style
    c.host = "example.org"
    c.port = 80
row(8, "with edit(cfg) as c: c.host = ... -- sees everything", repr(cfg))
row(9, 'Cfg(host="x", port=80) -- keywords, no DSL', repr(Cfg(host="x", port=80)))
try:
    class Broken(Config):
        host = "x"
except Config.Error as e:
    row(10, "class Broken(Config): host = 'x' -- validation", f"{type(e).__name__}: {e}")
row(11, "list(app.routes) -- insertion order", list(app.routes))
row(12, "sorted(vars(Site)) minus dunders", sorted(k for k in vars(Site) if not k.startswith("__")))


class Page(Config):                                    # 13. a body assignment shadows a builtin, harmlessly
    port = 1
    print = "text"


row(13, "class Page(Config): print = 'text'", f"settings['print'] = {Page.settings['print']!r}; print still works")
row("", "no method_missing layer to collide with", "-")
