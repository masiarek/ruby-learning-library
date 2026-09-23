# Python keeps the stack as frame objects: traceback.extract_stack and
# inspect.stack read the live stack, e.__traceback__ the one an exception
# carries. Names only are printed; no full traceback (its text is per-release).
import inspect
import sys
import traceback


class Worker:
    def outer(self):
        return self.inner()

    def inner(self):
        names = [f.name for f in traceback.extract_stack()]
        print(f" 1. extract_stack names (outermost first): {names}")
        print(f" 2. inspect.stack names (innermost first): {[f.function for f in inspect.stack()][:3]}")
        code = sys._getframe().f_code
        print(f" 3. co_qualname and co_name:                {code.co_qualname!r}, {code.co_name!r}")
        print(f" 4. f_code.co_name of the current frame:    {sys._getframe().f_code.co_name!r}")
        here = traceback.extract_stack()[-1]
        print(f" 5. a frame has a filename and a line:      {here.filename.rsplit('/', 1)[-1]}, lineno is {type(here.lineno).__name__}")
        raise ValueError("bad input")


try:
    Worker().outer()
except ValueError as e:
    tb = e.__traceback__
    print(f" 6. e.__traceback__ is a {type(tb).__name__}; its names: {[f.name for f in traceback.extract_tb(tb)]}")
    print(f" 7. extract_tb gives frames with .name:      {[f.name for f in traceback.extract_tb(tb)]}")
    print(f" 8. format_exception_only:                   {traceback.format_exception_only(e)}   (no location at all)")
    e.add_note("checked by the twin")
    print(f" 9. after add_note (3.11+):                  {traceback.format_exception_only(e)}")
    e = e.with_traceback(None)
    print(f"10. after with_traceback(None):             e.__traceback__ is {e.__traceback__}")

print(f"11. an exception never raised:              ValueError('x').__traceback__ is {ValueError('x').__traceback__}")
print(f"12. extract_stack at module level:          {[f.name for f in traceback.extract_stack()]}")


def top_level_function():
    return sys._getframe().f_code.co_qualname


lambda_name = (lambda: sys._getframe().f_code.co_qualname)()
print(f"13. names elsewhere:                        top-level def: {top_level_function()!r}   lambda: {lambda_name!r}   module: {sys._getframe().f_code.co_name!r}")
