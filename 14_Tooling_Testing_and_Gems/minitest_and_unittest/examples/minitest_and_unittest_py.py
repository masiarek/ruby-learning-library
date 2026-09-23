# unittest is in the stdlib: a TestCase class, assert* methods, mock beside it.
# The run happens in-process with a StringIO stream; timing and traceback
# internals are dropped.
import io
import re
import unittest
from unittest import mock


class Calc:
    def add(self, a, b):
        return a + b

    def div(self, a, b):
        return a / b


class TestCalc(unittest.TestCase):
    def setUp(self):
        self.calc = Calc()

    def test_add(self):
        self.assertEqual(self.calc.add(2, 2), 4)
        self.assertAlmostEqual(self.calc.add(0.1, 0.2), 0.3)

    def test_div_by_zero(self):
        with self.assertRaises(ZeroDivisionError) as cm:
            self.calc.div(1, 0)
        self.assertEqual(type(cm.exception).__name__, "ZeroDivisionError")

    def test_deliberate_failure(self):
        self.assertEqual({"name": "a", "n": 1}, {"name": "b", "n": 1})

    @unittest.skip("not today")
    def test_skipped(self):
        pass

    def test_double_with_mock(self):
        with mock.patch.object(Calc, "add", return_value=42) as fake:
            self.assertEqual(self.calc.add(1, 2), 42)
            fake.assert_called_once_with(1, 2)

    def test_subtests(self):
        for a, b, want in [(1, 1, 2), (2, 3, 5)]:
            with self.subTest(a=a, b=b):
                self.assertEqual(self.calc.add(a, b), want)


print("1. the report of TextTestRunner(verbosity=2), timing and traceback lines removed:")
buffer = io.StringIO()
suite = unittest.defaultTestLoader.loadTestsFromTestCase(TestCalc)
result = unittest.TextTestRunner(stream=buffer, verbosity=2).run(suite)
for line in buffer.getvalue().splitlines():
    if line.startswith(" "):
        continue  # the File/source/caret lines of the traceback: paths and line numbers
    print("   " + re.sub(r"in [\d.]+s", "in (time removed)", line) if line.strip() else "")
print(f"2. result.wasSuccessful() is {result.wasSuccessful()} (one failure): "
      f"ran {result.testsRun}, failures {len(result.failures)}, errors {len(result.errors)}, "
      f"skipped {len(result.skipped)}")
print(f"3. import unittest.mock: loaded -- Mock, patch and MagicMock are in the stdlib: "
      f"{all(hasattr(mock, n) for n in ('Mock', 'patch', 'MagicMock'))}")
