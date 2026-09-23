# The Python twin: attributes are public, and privacy is a naming convention.
# Each numbered row is printed by the Ruby program too, in the same order.


def row(n, label, value):
    print(f"{n:2d}. {label:<50} {value}")


def failing(thunk):
    try:
        return thunk()
    except AttributeError as e:
        return type(e).__name__          # the message is reworded between Python releases


class Account:
    def __init__(self, owner):
        self._owner = owner              # _ is a convention; nothing stops a caller

    def __repr__(self):
        return f"<Account owner={self._owner!r}>"

    @property
    def owner(self):                     # a reader, added when the class wants control
        return self._owner

    def hide(self):
        self.__secret = 42               # __ triggers name mangling inside a class body


acct = Account("ann")

row(1, "acct._owner with no reader defined", repr(failing(lambda: acct._owner)))

row(2, "the reader: @property owner, acct.owner", repr(acct.owner))

acct.balance = 10                        # no declaration: any attribute may be assigned
row(3, "no declaration needed, acct.balance = 10", repr(acct.balance))


def assign_owner():
    acct.owner = "bob"


row(4, "acct.owner = \"bob\" on a property with no setter", failing(assign_owner))

row(5, "the back door: vars(acct)[\"_owner\"]", repr(vars(acct)["_owner"]))

row(6, "list(vars(acct))", repr(list(vars(acct))))

row(7, "unset acct.nickname read from outside",
    f"{failing(lambda: acct.nickname)} (hasattr {hasattr(acct, 'nickname')})")


acct.hide()
row(8, "self.__secret is stored under a mangled name", repr(list(vars(acct))[-1]))


class Slotted:
    __slots__ = ("owner",)

    def __init__(self, owner):
        self.owner = owner


slotted = Slotted("ann")


def add_extra():
    slotted.extra = 1


row(9, "a new attribute added after the fact", f"True on Account; {failing(add_extra)} on a __slots__ class")

other = Account("bob")
row(10, "two instances, two sets of attributes",
    f"{acct.owner} / {other.owner} (balance of other: {failing(lambda: other.balance)})")
