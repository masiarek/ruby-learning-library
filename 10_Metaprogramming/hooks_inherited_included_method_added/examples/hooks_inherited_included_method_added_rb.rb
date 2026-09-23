# hooks_inherited_included_method_added_rb.rb — Ruby calls you back while a class is being written.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

class Exporter
  def self.inherited(sub)                              # 1. called as each subclass appears
    (@registry ||= []) << sub.name                     #    name is nil for Class.new(Exporter)
    super
  end
  def self.registry = @registry
  def self.tag(value = nil) = value ? @tag = value : @tag   # 3. "options" are a class method call
end
class CsvExporter < Exporter
  tag "csv"
end
class JsonExporter < Exporter; end
row 1, "Exporter.registry after two `class X < Exporter`", Exporter.registry.inspect
anon = Class.new(Exporter)
row 2, "Class.new(Exporter): registry.last, anon.name", "#{Exporter.registry.last.inspect} / #{anon.name.inspect}"
XmlExporter = anon
row "", "XmlExporter = anon; anon.name", anon.name.inspect
row 3, "class CsvExporter < Exporter; tag \"csv\"; end", "CsvExporter.tag = #{CsvExporter.tag.inspect}"

LOG = []
module Persist
  def self.included(base)                              # 4. included + extend = class methods
    LOG << "included in #{base}, already in ancestors: #{base.ancestors.include?(self)}"
    base.extend(ClassMethods)
  end
  def self.append_features(base)                       # 5. runs before included
    LOG << "append_features #{base}"
    super
  end
  def self.extended(obj) = LOG << "extended a #{obj.class}"
  def self.prepended(base) = LOG << "prepended to #{base}"
  module ClassMethods
    def table_name = name.downcase + "s"
  end
  def save = "saved #{self.class.table_name}"
end

module Watch                                           # 8-10. per-definition hooks, kept out of the way
  def method_added(name) = (@added ||= []) << name
  def singleton_method_added(name) = (@sadded ||= []) << name
  def const_added(name) = (@consts ||= []) << name
  def added = @added
  def sadded = @sadded
  def consts = @consts
end

class Model
  extend Watch
  include Persist
  def load = 2
  attr_accessor :id
  alias_method :fetch, :load
  define_method(:touch) { }
  private def hidden = 4
  def self.create = 3
  VERSION = "1"
  class Inner; end
end
row 4, "include Persist: Model.table_name, .new.save", "#{Model.table_name.inspect}, #{Model.new.save.inspect}"
row 5, "LOG order during include", LOG.inspect
LOG.clear
Object.new.extend(Persist)
row 6, "Object.new.extend(Persist)", LOG.inspect
LOG.clear
class Audited
  prepend Persist
end
row 7, "class Audited; prepend Persist; end", "#{LOG.inspect}; ancestors.first(2) = #{Audited.ancestors.first(2).inspect}"
row 8, "method_added saw (def, attr_accessor, alias, define_method, private)", Model.added.inspect
row 9, "singleton_method_added saw", Model.sadded.inspect
row 10, "const_added saw", Model.consts.inspect
row 11, "Exporter.subclasses.map(&:name).sort", Exporter.subclasses.map(&:name).sort.inspect

class Base2
  def self.inherited(sub) = ((@@all ||= []) << sub.name; super)   # 12. super keeps the chain
  def self.all = @@all
end
class Mid < Base2
  def self.inherited(sub) = (LOG << "Mid saw #{sub.name}"; super)
end
LOG.clear
class Leaf < Mid; end
row 12, "class Leaf < Mid: Base2.all, and Mid's own hook", "#{Base2.all.inspect}, #{LOG.inspect}"
row 13, "the hooks are private: inherited/included/method_added",
    [Class.private_instance_methods.include?(:inherited),
     Module.private_instance_methods.include?(:included),
     Module.private_instance_methods.include?(:method_added)].inspect
