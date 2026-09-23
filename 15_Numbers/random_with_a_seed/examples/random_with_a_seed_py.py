# The same rows, asked of Python: random.Random(42) repeats its sequence
# too, but it is a different sequence — both are Mersenne Twisters, seeded
# differently — and the module-level functions share one hidden instance.
import os
import random
import secrets
import uuid


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<44} -> {value:<30} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except (ValueError, AttributeError) as e:
        return type(e).__name__  # the message is reworded between releases


r = random.Random(42)
ints = [r.randrange(100) for _ in range(5)]
r = random.Random(42)
floats = [r.random() for _ in range(3)]
r = random.Random(42)
dice = [r.randint(1, 6) for _ in range(10)]

random.seed(42)
first = [random.randrange(10), random.randrange(10)]
previous = random.seed(42)
second = [random.randrange(10), random.randrange(10)]

xs = [1, 2, 3, 4, 5]
random.Random(1).shuffle(xs)

row(1,  "random.Random(42).randrange(100)",            repr(random.Random(42).randrange(100)), "an int in range(100) from a seeded generator")
row(2,  "Random(42), then 5 x randrange(100)",         repr(ints),                          "the same seed always starts the same stream")
row(3,  "Random(42), then 3 x random()",               repr(floats),                        "random() is a float in [0, 1)")
row(4,  "Random(42), then 10 x randint(1, 6)",         repr(dice),                          "randint is inclusive: dice; randrange(1, 7) is the half-open spelling")
row(5,  "random.seed(42); [randrange(10), randrange(10)]", repr(first),                     "seed() seeds the hidden module-level Random behind random.randrange")
row(6,  "random.seed(42) again; the same two",         repr(second),                        f"reseeding restarts the stream; seed() returned {previous!r}, not the old seed")
row(7,  "xs = [1, 2, 3, 4, 5]; Random(1).shuffle(xs)", repr(xs),                            "shuffle is in place and returns None; the generator is the receiver")
row(8,  "Random(1).sample([1, 2, 3, 4, 5], 2)",        repr(random.Random(1).sample([1, 2, 3, 4, 5], 2)), "sample never repeats an element")
row(9,  "Random(42).getstate() == Random(42).getstate()", repr(random.Random(42).getstate() == random.Random(42).getstate()), "no == on Random objects; compare their states")
row(10, "Random(42).getrandbits(70)",                  repr(random.Random(42).getrandbits(70)), "any size of int")
row(11, "Random(42).randrange(0)",                     caught(lambda: random.Random(42).randrange(0)), "an empty range raises here too; random() takes no bound at all")
row(12, "random.DEFAULT",                              caught(lambda: random.DEFAULT),      f"no such name; the module functions are methods of one hidden {random.random.__self__.__class__.__name__}")
row(13, "type(os.urandom(4)).__name__",                repr(type(os.urandom(4)).__name__),  f"fresh bytes from the OS on each call: os.urandom(4) != os.urandom(4) is {os.urandom(4) != os.urandom(4)}")
row(14, "len(secrets.token_hex(8))",                   repr(len(secrets.token_hex(8))),     f"unpredictable and unseedable, so only its shape is printed; len(str(uuid.uuid4())) is {len(str(uuid.uuid4()))}")
row(15, "Random(2 ** 70).getrandbits(32), and .random()", f"{random.Random(2 ** 70).getrandbits(32)}, {random.Random(2 ** 70).random()!r}", "the same two numbers as Ruby: a seed wider than 32 bits loads MT19937 identically, and 42 does not")
