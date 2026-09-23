# The Python twin: compile() gives a code object whose names and variables are
# stable, whose constants show folding, and whose instruction names change
# between releases (so only membership tests are printed); ast walks the tree.

import ast
import dis
import marshal


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


def opnames(code):
    return [ins.opname for ins in dis.get_instructions(code)]


def tree_lines(node, depth=0, out=None):
    out = [] if out is None else out
    out.append("  " * depth + type(node).__name__)
    for child in ast.iter_child_nodes(node):
        tree_lines(child, depth + 1, out)
    return out


def foo(x):
    return x + 1


code = compile("(a := 1 + 2) * 3", "", "eval")
row(1, 'compile("(a := 1 + 2) * 3"): co_names, co_varnames', [code.co_names, code.co_varnames])
row(2, '1 + 2 is folded: BINARY_OP in "1 + 2" / in "a + 2"', ["BINARY_OP" in opnames(compile("1 + 2", "", "eval")), "BINARY_OP" in opnames(compile("a + 2", "", "eval"))])
row(3, "eval(code)", eval(code))
row(4, "type(code).__name__, co_name, type(co_code).__name__", [type(code).__name__, code.co_name, type(code.co_code).__name__])

fc = foo.__code__
row(5, "foo.__code__: co_name, co_varnames, co_argcount, BINARY_OP", [fc.co_name, fc.co_varnames, fc.co_argcount, "BINARY_OP" in opnames(fc)])

ns0, ns2 = {}, {}
exec(compile('def f():\n    "doc"\n', "", "exec", optimize=0), ns0)
exec(compile('def f():\n    "doc"\n', "", "exec", optimize=2), ns2)
row(6, "optimize=2 drops docstrings: f.__doc__ at 0 / at 2", [ns0["f"].__doc__, ns2["f"].__doc__])
blob = marshal.dumps(code)
row(7, "marshal.dumps(code).__class__, eval(marshal.loads(...))", [type(blob).__name__, eval(marshal.loads(blob))])

tree = ast.parse("1 + 2")
row(8, 'ast.parse("1 + 2"): type, body length, the nodes:', [type(tree).__name__, len(tree.body)])
print("\n".join("      " + line for line in tree_lines(tree)))
binop = tree.body[0].value
row(9, "the BinOp: op, left.value, right.value, ast.unparse", [type(binop.op).__name__, binop.left.value, binop.right.value, ast.unparse(binop)])
row(10, 'ast.parse("a = 1 + 2; a * 3") nodes:', isinstance(ast.parse("a = 1 + 2; a * 3"), ast.Module))
print("\n".join("      " + line for line in tree_lines(ast.parse("a = 1 + 2; a * 3"))))
row(11, 'ast.parse("1 + 2", mode="eval") root (one ast, two modes)', type(ast.parse("1 + 2", mode="eval")).__name__)
