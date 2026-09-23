# The garbage collector and ObjectSpace: what you can ask Ruby's heap, and which
# answers are promises. Every value printed here is a comparison or a boolean --
# a count of live objects, or the moment a WeakRef dies, is not one.

require "weakref"
require "objspace"

class Widget; end

def row(n, label, value)
  puts format("%2d. %-52s %s", n, label, value.inspect)
end

before = GC.count
GC.start
row 1, "GC.count grows after GC.start", GC.count > before

allocated_before = GC.stat(:total_allocated_objects)
kept = Array.new(1000) { |i| "string #{i}" }
row 2, "GC.stat(:total_allocated_objects) grew by >= 1000", GC.stat(:total_allocated_objects) - allocated_before >= kept.size

row 3, "[GC.disable, GC.disable, GC.enable] (previous state)", [GC.disable, GC.disable, GC.enable]

before_any = ObjectSpace.each_object(Widget).any?
w = Widget.new
row 4, "each_object(Widget).any? before / after Widget.new", [before_any, ObjectSpace.each_object(Widget).any?]

wm = ObjectSpace::WeakMap.new
key = Object.new
wm[key] = "value"
row 5, "ObjectSpace::WeakMap: wm.key?(key), wm[key]", [wm.key?(key), wm[key]]

wr = WeakRef.new(w)
row 6, "WeakRef while w is referenced: alive?, __getobj__", [wr.weakref_alive?, wr.__getobj__.equal?(w)]
w = nil
GC.start
row 7, "after w = nil; GC.start: alive? is nil or true", [nil, true].include?(wr.weakref_alive?)

KEPT = Widget.new
fin = ObjectSpace.define_finalizer(KEPT, proc { puts "finalizer ran for KEPT (after the last row: at exit)" })
row 8, "define_finalizer(KEPT, proc) returned [Integer, Proc]", fin.map(&:class)

row 9, "count_objects keys :TOTAL, :FREE, :T_STRING (no refcounts)", [:TOTAL, :FREE, :T_STRING].map { |k| ObjectSpace.count_objects.key?(k) }
row 10, "GC.stat keys :minor_gc_count, :major_gc_count", [GC.stat.key?(:minor_gc_count), GC.stat.key?(:major_gc_count)]
row 11, "1.object_id == 1.object_id, \"a\".object_id == \"a\".object_id", [1.object_id == 1.object_id, "a".object_id == "a".object_id]
row 12, "GC.latest_gc_info keys :major_by, :gc_by", [GC.latest_gc_info.key?(:major_by), GC.latest_gc_info.key?(:gc_by)]
row 13, "ObjectSpace.memsize_of(\"x\" * 1000) > 1000", ObjectSpace.memsize_of("x" * 1000) > 1000
