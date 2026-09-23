# 02 — Methods and arguments

**One line:** A Ruby method call needs no parentheses, no `return`, no `self`, and its argument list can carry positionals, defaults, splats, keywords and a block — and each of those is a place where a Python reader's model needs one adjustment.

This chapter is about the shape of a call and of a definition. Ruby drops the parentheses, returns whatever the last expression produced, evaluates a default argument fresh on every call, marks dangerous methods with `!` and predicates with `?`, makes `+` and `[]` and `!` ordinary methods you can define, sends a receiverless call to an implicit `self`, skips a call on `nil` with `&.`, and makes an assignment `obj.x = v` evaluate to `v` no matter what the setter's body returns.

A Python programmer arrives with most of the right ideas: functions take positional and keyword arguments, `*args` and `**kwargs` collect the rest, and operators are dunder methods underneath. What breaks is the details — Python needs parentheses to call, returns `None` unless you say `return`, evaluates a default once at `def` time (the mutable-default trap), has no `?` or `!` in a name, and treats assignment as a statement with no value. Every page here prints both behaviours side by side.

| Lesson | Level | The one thing |
|---|---|---|
| [Parentheses are optional, but the space is not](parentheses_are_optional/README.md) | 101 | a bare name is a call, and `puts (1+2)*3` is not `puts(1+2)*3` |
| [The last expression is the return value](the_last_expression_is_the_value/README.md) | 101 | no `return` needed; a method that ends in `puts` returns nil |
| [Arguments: positional, keyword, splat and block](arguments_positional_keyword_and_splat/README.md) | 201 | the eight kinds of parameter, `...` forwarding and the three `ArgumentError` messages |
| [Default arguments are evaluated on every call](default_arguments_are_evaluated_each_call/README.md) | 201 | `def f(a = [])` is fresh each call; Python's `def f(a=[])` is not |
| [Bang means dangerous, question mark means predicate](bang_and_question_methods/README.md) | 101 | `sort!` mutates, `strip!` returns nil when nothing changed, `empty?` answers |
| [Operators are methods, except the ones that are not](operators_are_methods/README.md) | 201 | `+`, `[]`, `<=>`, `!` are methods you define; `&&`, `||`, `=` are syntax |
| [`self` is the implicit receiver](self_is_implicit/README.md) | 201 | a receiverless call goes to `self`; a setter needs `self.x =` |
| [`&.` skips the call when the receiver is nil](safe_navigation/README.md) | 101 | `nil&.length` is nil and the arguments are not even evaluated |
| [A setter returns its argument, not its body](setters_return_the_argument/README.md) | 201 | `obj.x = 5` evaluates to 5 whatever `def x=` returns |

## Read more

- [Ruby docs: Methods ↗](https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html) — parameter kinds, `return`, and the `def` forms
- [Ruby docs: Calling methods ↗](https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html) — receivers, arguments, splats, keywords, blocks and `&.`
- [Python tutorial: Defining functions ↗](https://docs.python.org/3/tutorial/controlflow.html#defining-functions) — defaults, keyword arguments, `/` and `*` markers
- [Python reference: Calls ↗](https://docs.python.org/3/reference/expressions.html#calls) — how a Python call binds its arguments
