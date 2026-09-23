"""The Python twin: there is no implicit receiver. `self` is an ordinary first
parameter (named self by convention), a bare name inside a method is a local
or a global and never an attribute, and `self.name = v` is the only way to
reach the instance -- so Python has the same setter trap, for the opposite
reason."""

try:
    self
except NameError:
    print("1. self at module level:          NameError (there is no self here; __name__ is", repr(__name__) + ")")


class Person:
    try:
        self
    except NameError:
        print("2. self in a class body:          NameError (the body sees __qualname__ =", repr(__qualname__) + ")")

    def __init__(self, name):
        self.name = name

    def whoami(self):
        return self

    def greet(this):
        return "hi from " + this.name

    def greet_bare(self):
        try:
            return greet()
        except NameError as e:
            return type(e).__name__ + " (a bare greet() is a global lookup)"

    def rename_wrong(self, v):
        name = v
        return name

    def rename_right(self, v):
        self.name = v
        return v

    @classmethod
    def species(cls):
        return "a classmethod: cls is " + cls.__name__

    @staticmethod
    def motto():
        return "a staticmethod: neither self nor cls"

    def _secret(self):
        return "the secret of " + self.name

    def peek(self, other):
        return other._secret()

    def in_lambda(self):
        return (lambda: self)()

    def __repr__(self):
        return f"Person({self.name})"


a = Person("ann")
print("3. self is the first parameter:   a.whoami() ->", a.whoami(), "; a.whoami() is a ->", a.whoami() is a, "; Person.greet(a) ->", repr(Person.greet(a)), "(named this, not self)")
print("4. no receiverless call:          a.greet_bare() ->", a.greet_bare())
print("5. cls, or nothing:               " + Person.species() + "; " + Person.motto())
print("6. the setter trap:               a.rename_wrong('bo') ->", repr(a.rename_wrong("bo")), "but a.name is still", repr(a.name), "(name = v made a local)")
print("                                  a.rename_right('bo') ->", repr(a.rename_right("bo")), "and a.name is now", repr(a.name), "(self.name = v set the attribute)")
print("7. private is a convention:       a._secret() ->", repr(a._secret()), "; a.peek(Person('cy')) ->", repr(a.peek(Person("cy"))), "(nothing enforced)")


class Counter:
    def __init__(self):
        self.count = 0

    def bump_wrong(self):
        count = count + 1

    def bump_right(self):
        self.count += 1
        return self.count


c = Counter()
try:
    c.bump_wrong()
except UnboundLocalError as e:
    print("8. count = count + 1:            ", type(e).__name__, "(the assignment makes count a local for the whole method, read before it is set)")
print("   self.count += 1:               ->", c.bump_right(), "; c.count is", c.count)
print("9. self inside a lambda:          a.in_lambda() is a ->", a.in_lambda() is a, "(a closed-over variable, like any other)")


def top_level_function():
    return "a module-level function"


print("10. a top-level def:              'top_level_function' in globals() ->", "top_level_function" in globals(), "(a module attribute, not a method of anything)")
