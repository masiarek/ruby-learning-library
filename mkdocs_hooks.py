"""Build-time fixes that would otherwise cost a pinned plugin dependency.

Three jobs, all about the sidebar. This file is the Ruby text learning library's
with its own reading order:

1. **Clean chapter labels.** MkDocs derives a section label from the folder name
   on disk, so `01_Objects_and_Values/` reads as "01 Objects And
   Values". The numeric prefix exists to set reading order in a file listing;
   it should not be visible in the nav. Only *prefixed* folders are relabelled
   from their name — a lesson folder takes its README's own H1 (job 3).

2. **Order the sections.** `NAV_ORDER` states the intended reading order per
   folder, keyed by folder path, listing children by their on-disk name.

3. **Label lessons from their H1.** Left alone, MkDocs titles a lesson folder
   from its name, so `w_is_ascii_b_is_not` reads "W is ascii b is not" — and
   `mkdocs build --strict` passes either way. A lesson folder takes its README's
   H1 instead, backticks dropped. `LABEL_OVERRIDES` holds the exceptions: an H1
   too long for a sidebar.

Why order here rather than by renaming files: a filename is a permanent URL.
Renumbering `03_` to `04_` to insert a chapter would move every page after it
and break any link anyone saved. Ordering is presentation, so it belongs in the
presentation layer. Unlisted pages keep their alphabetical slot at the bottom.

One structural note that is easy to get wrong: the top-level object MkDocs hands
`on_nav` is a `Navigation`, whose children live on `.items`. Only `Section` has
`.children`. A hook that reaches for `.children` at the top level silently does
nothing at all — the build still succeeds, and the sidebar is simply never
touched.
"""

from __future__ import annotations

import re

PREFIX = re.compile(r"^(\d+)[_-]")

# Words the naive title-caser gets wrong.
FIXUPS = {
    "Vs": "vs",
    "And": "and",
    "Or": "or",
    "The": "the",
    "To": "to",
    "A": "a",
    "An": "an",
    "In": "in",
    "Of": "of",
}

# Lesson folders whose sidebar label is deliberately not their H1. Keyed by
# on-disk folder name. An entry naming a folder that no longer exists is a
# silent no-op, which tools/check_nav_chain.py reports.
LABEL_OVERRIDES: dict[str, str] = {}

# Reading order per folder path. Children named by on-disk name; anything not
# listed sorts alphabetically after the listed ones.
NAV_ORDER: dict[str, list[str]] = {
    "": [
        "index.md",
        "00_Start_Here",
        "01_Objects_and_Values",
        "02_Methods_and_Arguments",
        "03_Blocks_Procs_and_Lambdas",
        "04_Collections",
        "05_Enumerable_and_Iteration",
        "06_Classes_and_Modules",
        "07_The_Object_Model",
        "08_Errors_and_Exceptions",
        "09_Control_Flow_and_Pattern_Matching",
        "10_Metaprogramming",
        "11_Under_the_Hood",
        "12_Concurrency_and_Parallelism",
        "13_IO_Files_and_the_System",
        "14_Tooling_Testing_and_Gems",
        "15_Numbers",
        "16_Idioms_and_Gotchas",
        "17_Resources",
        "CROSSWALK.md",
        "TOPICS.md",
    ],
    "01_Objects_and_Values": [
        "README.md",
        "everything_is_an_object",
        "nil_false_and_truthiness",
        "symbols_are_names",
        "four_kinds_of_equality",
        "variables_are_references",
        "freeze_and_frozen_error",
        "strings_are_mutable",
        "duck_typing_and_respond_to",
    ],
    "02_Methods_and_Arguments": [
        "README.md",
        "parentheses_are_optional",
        "the_last_expression_is_the_value",
        "arguments_positional_keyword_and_splat",
        "default_arguments_are_evaluated_each_call",
        "bang_and_question_methods",
        "operators_are_methods",
        "self_is_implicit",
        "safe_navigation",
        "setters_return_the_argument",
    ],
    "03_Blocks_Procs_and_Lambdas": [
        "README.md",
        "blocks_are_not_objects",
        "procs_and_lambdas_differ",
        "closures_capture_variables",
        "symbol_to_proc",
        "it_and_numbered_parameters",
        "next_break_and_return_in_blocks",
        "writing_an_iterator",
        "curry_and_composition",
    ],
    "04_Collections": [
        "README.md",
        "arrays_and_negative_indexes",
        "hashes_and_default_values",
        "ranges_two_dots_and_three",
        "set_is_a_core_class",
        "destructuring_assignment",
        "struct_and_data",
        "comparable_and_spaceship",
    ],
    "05_Enumerable_and_Iteration": [
        "README.md",
        "enumerable_is_a_mixin",
        "the_enumerable_toolbox",
        "inject_and_each_with_object",
        "lazy_enumerators",
        "external_enumerators",
        "sort_stability_and_sort_by",
    ],
    "06_Classes_and_Modules": [
        "README.md",
        "instance_variables_are_private",
        "private_means_no_receiver",
        "classes_are_open",
        "mixins_include_extend_prepend",
        "method_lookup_and_super",
        "constants_and_lexical_scope",
        "class_variables_are_shared",
        "modules_as_namespaces",
    ],
    "07_The_Object_Model": [
        "README.md",
        "singleton_classes",
        "new_allocate_and_initialize",
        "to_s_inspect_and_p",
        "eql_and_hash_for_hash_keys",
        "refinements",
        "basic_object_and_kernel",
        "dup_clone_and_frozen_state",
    ],
    "08_Errors_and_Exceptions": [
        "README.md",
        "rescue_ensure_else_and_retry",
        "standard_error_is_the_default",
        "raise_has_four_forms",
        "custom_exception_classes",
        "exceptions_have_a_cause",
        "rescue_as_a_modifier",
        "throw_and_catch",
        "exit_at_exit_and_system_exit",
        "warnings_and_dash_w",
        "common_error_messages",
    ],
    "09_Control_Flow_and_Pattern_Matching": [
        "README.md",
        "everything_is_an_expression",
        "unless_until_and_modifiers",
        "and_or_precedence",
        "case_when_uses_threequals",
        "case_in_pattern_matching",
        "pin_guards_and_alternatives",
        "deconstruct_and_deconstruct_keys",
        "no_matching_pattern_error",
        "for_loops_do_not_scope",
    ],
    "10_Metaprogramming": [
        "README.md",
        "send_and_public_send",
        "define_method",
        "method_missing_and_respond_to_missing",
        "instance_eval_and_class_eval",
        "hooks_inherited_included_method_added",
        "building_a_dsl",
        "classes_at_runtime",
        "introspection",
    ],
    "11_Under_the_Hood": [
        "README.md",
        "method_objects_and_unbound_methods",
        "binding_and_eval",
        "tracepoint",
        "object_space_and_gc",
        "the_bytecode_you_can_see",
        "jits_and_the_interpreter",
    ],
    "12_Concurrency_and_Parallelism": [
        "README.md",
        "threads_and_the_gvl",
        "mutex_queue_and_condition_variable",
        "fibers_are_coroutines",
        "enumerators_run_on_fibers",
        "thread_locals_are_fiber_locals",
        "ractors_share_nothing",
        "processes_fork_and_wait",
        "timeouts_and_killing_threads",
    ],
    "13_IO_Files_and_the_System": [
        "README.md",
        "file_open_with_a_block",
        "puts_print_p_and_pp",
        "argv_env_and_exit_status",
        "running_other_programs",
        "stdin_gets_and_argf",
        "pathname_dir_and_glob",
        "json_yaml_and_marshal",
        "time_and_date",
        "string_formatting_and_interpolation",
        "text_lives_in_the_text_library",
    ],
    "14_Tooling_Testing_and_Gems": [
        "README.md",
        "require_require_relative_and_load",
        "gems_bundler_and_gemfile",
        "minitest_and_unittest",
        "the_command_line_flags",
        "irb_and_the_repl",
        "ruby_versions_what_changed",
        "backtraces_and_caller",
        "no_docstrings",
    ],
    "15_Numbers": [
        "README.md",
        "integer_division_floors",
        "integers_are_unbounded",
        "floats_and_rounding",
        "rational_and_bigdecimal",
        "comparing_int_and_float",
        "numeric_coercion",
        "random_with_a_seed",
        "number_formatting",
    ],
    "16_Idioms_and_Gotchas": [
        "README.md",
        "the_ruby_way_and_the_pythonic_way",
        "or_equals_and_nil_guards",
        "tap_then_and_chaining",
        "multiple_return_values",
        "string_and_symbol_keys",
        "style_and_naming",
        "comments_and_documentation",
        "gotchas_for_python_programmers",
        "gotchas_for_ruby_programmers_in_python",
    ],
    "17_Resources": [
        "README.md",
    ],
}


def _label(name: str) -> str:
    """Folder name on disk -> sidebar label."""
    words = PREFIX.sub("", name).replace("_", " ").replace("-", " ").split()
    out = [FIXUPS.get(w.capitalize(), w.capitalize()) for w in words]
    if out:
        out[0] = out[0][0].upper() + out[0][1:]
    return " ".join(out)


def _is_section(item) -> bool:
    return getattr(item, "children", None) is not None


def _first_src(item) -> str:
    """Source path of `item`, or of the first page anywhere beneath it."""
    page_file = getattr(item, "file", None)
    if page_file is not None:
        return page_file.src_uri
    for child in getattr(item, "children", None) or []:
        found = _first_src(child)
        if found:
            return found
    return ""


def _on_disk_name(item, depth: int) -> str:
    """The name NAV_ORDER lists this child by: a filename, or a folder segment."""
    src = _first_src(item)
    if not src:
        return (getattr(item, "title", "") or "").lower()
    parts = src.split("/")
    if not _is_section(item):
        return parts[-1]
    return parts[depth] if depth < len(parts) - 1 else parts[-1]


def _order_key(path: str, name: str) -> tuple[int, str]:
    listed = NAV_ORDER.get(path, [])
    if name in listed:
        return (listed.index(name), "")
    return (len(listed), name.lower())


def _readme_h1(section) -> str:
    """The H1 of a section's own README.md, read from disk ("" if it has none).

    Read from disk because MkDocs fills in a page's title only when it renders
    the page, long after `on_nav`. Backticks are dropped: the sidebar prints
    them as literal characters.
    """
    for child in section.children:
        page_file = getattr(child, "file", None)
        if page_file is None or page_file.src_uri.rsplit("/", 1)[-1] != "README.md":
            continue
        with open(page_file.abs_src_path, encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("# "):
                    return line[2:].strip().replace("`", "")
    return ""


def _visit(items: list, path: str, depth: int) -> None:
    for child in items:
        if not _is_section(child):
            continue
        name = _on_disk_name(child, depth)
        if name in LABEL_OVERRIDES:
            child.title = LABEL_OVERRIDES[name]
        elif PREFIX.match(name):
            child.title = _label(name)
        else:
            child.title = _readme_h1(child) or child.title

    items.sort(key=lambda c: _order_key(path, _on_disk_name(c, depth)))

    for child in items:
        if not _is_section(child):
            continue
        name = _on_disk_name(child, depth)
        _visit(child.children, f"{path}/{name}".lstrip("/"), depth + 1)


def _pages_in_nav_order(items: list) -> list:
    """Every page under `items`, depth-first, in the order the sidebar shows."""
    out = []
    for item in items:
        if item.is_page:
            out.append(item)
        elif item.is_section:
            out.extend(_pages_in_nav_order(item.children))
    return out


def on_nav(nav, config, files):
    """Relabel numbered chapters, apply NAV_ORDER, and re-chain prev/next."""
    _visit(nav.items, "", 0)

    # Sorting nav.items fixes the sidebar and nothing else. MkDocs computes every
    # page's previous_page/next_page inside get_navigation(), which runs BEFORE
    # this hook -- so without the re-chain below, the arrows at the foot of a
    # lesson walk the reader alphabetically while the sidebar beside them reads
    # in order. For a library with a reading order, the arrow IS the order.
    ordered = _pages_in_nav_order(nav.items)
    # Compared by source path, not by identity: MkDocs' Page defines __eq__
    # without __hash__, so a Page cannot go in a set.
    walked = {page.file.src_uri for page in ordered}
    known = {page.file.src_uri for page in nav.pages}
    assert walked == known, (
        "_pages_in_nav_order is out of step with mkdocs.structure.nav: "
        f"missed {sorted(known - walked)}, invented {sorted(walked - known)}"
    )
    for i, page in enumerate(ordered):
        page.previous_page = ordered[i - 1] if i else None
        page.next_page = ordered[i + 1] if i + 1 < len(ordered) else None
    nav.pages[:] = ordered

    return nav
