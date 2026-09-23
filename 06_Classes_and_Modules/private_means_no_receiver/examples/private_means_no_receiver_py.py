# The Python twin: `_name` is a convention, `__name` is mangled, and nothing is enforced.
# Each numbered row is printed by the Ruby program too, in the same order.


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def failing(thunk):
    try:
        return thunk()
    except (AttributeError, NameError, TypeError) as e:
        return type(e).__name__          # messages are reworded between Python releases


class Account:
    def __init__(self, owner, balance):
        self._owner = owner
        self._balance = balance

    def __repr__(self):
        return f"<Account {self._owner}>"

    @classmethod
    def open(cls, owner):                # the factory idiom; the constructor stays callable
        return cls(owner, 0)

    def receiverless_call(self):
        return _audit()                  # 2. no receiver: Python looks for a global, not a method

    def self_dot_call(self):
        return self._audit()             # 3. the only spelling that works

    def set_through_self(self):
        self._total = 1                  # 9. a "private" attribute is just an attribute
        return self._total

    def __eq__(self, other):
        return isinstance(other, Account) and self._balance == other._balance

    def _audit(self):                    # 7a. one underscore: "internal", by convention
        return f"audited {self._owner}"

    def __vault(self):                   # 7b. two underscores: the name is mangled
        return "vault"

    def _helper1(self):
        return "h1"


acct = Account.open("ann")
other = Account.open("bob")

row(1, "acct._audit() -- convention only, explicit receiver", repr(acct._audit()))
row(2, "inside the class, plain _audit()", failing(acct.receiverless_call))
row(3, "inside the class, self._audit()", repr(acct.self_dot_call()))
row(4, "no protected: acct == other / acct._balance", f"{acct == other} / {acct._balance}")
row(5, "no private constructor -- Account(\"x\", 0)",
    f"{Account('x', 0)!r}; Account.open works: {Account.open('x')!r}")
row(6, "getattr(acct, \"_audit\")() / no public_send",
    f"{getattr(acct, '_audit')()!r} / getattr reaches every name")
row(7, "names in vars(Account) that start with _",
    repr(sorted(k for k in vars(Account) if k.startswith("_") and not k.endswith("__"))))
row(8, "acct.__vault() / acct._Account__vault()",
    f"{failing(lambda: acct.__vault())} / {acct._Account__vault()!r}")
row(9, "a \"private\" attribute set as self._total = 1", repr(acct.set_through_self()))
row(10, "hasattr(acct, \"_audit\") / hasattr(acct, \"__vault\")",
    f"{hasattr(acct, '_audit')} / {hasattr(acct, '__vault')}")
