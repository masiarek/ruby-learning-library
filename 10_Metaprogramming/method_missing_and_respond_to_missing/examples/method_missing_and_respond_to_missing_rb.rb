# method_missing_and_respond_to_missing_rb.rb — ghost methods, and how to make them honest.
# Each row is one measurement; the Python twin prints the same rows.

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

class Db
  def initialize(rows) = @rows = rows
  def rows = @rows                                     # a real method
  def hook_calls = @hook_calls || 0

  private

  def method_missing(name, *args, &blk)                # runs only when lookup failed
    @hook_calls = hook_calls + 1
    if name.start_with?("find_by_")
      field = name.to_s.delete_prefix("find_by_").to_sym
      @rows.find { |r| r[field] == args.first }
    else
      super                                            # keep the NoMethodError for the rest
    end
  end
end

class ListedDb < Db                                    # the honest version
  def respond_to_missing?(name, include_private = false)
    name.start_with?("find_by_") || super
  end
end

class Record                                           # attribute-style ghosts
  def initialize(attrs) = @attrs = attrs
  def method_missing(name, *args) = @attrs.key?(name) && args.empty? ? @attrs[name] : super
  def respond_to_missing?(name, include_private = false) = @attrs.key?(name) || super
end

class Probe                                            # what the hook receives
  def method_missing(name, *args) = [name.class, name, args]
end

class Swallow                                          # the bug: no super
  def method_missing(*) = nil
end

class Memo                                             # a ghost that becomes real
  attr_reader :hits
  def initialize = @hits = 0
  def method_missing(name, *args)
    return super unless name.start_with?("say_")
    @hits += 1
    word = name.to_s.delete_prefix("say_")
    self.class.define_method(name) { word.upcase }     # next call is a normal call
    send(name)
  end
  def respond_to_missing?(name, include_private = false) = name.start_with?("say_") || super
end

rows = [{ name: "Ada", lang: "Ruby" }, { name: "Guido", lang: "Python" }]
db = Db.new(rows)
listed = ListedDb.new(rows)

row 1, 'db.find_by_name("Ada") -- a ghost method', db.find_by_name("Ada").inspect
row 2, "Record.new(name: \"Ada\").name -- attribute ghost", Record.new(name: "Ada").name.inspect
begin
  db.nope
rescue NoMethodError => e
  row 3, "db.nope -- super keeps the error", "#{e.class}: #{e.message}"
  missing = e
end
row 4, 'Probe.new.find_by_x("Ada") receives', Probe.new.find_by_x("Ada").inspect
row 5, "db.respond_to?(:find_by_name) -- no respond_to_missing?", db.respond_to?(:find_by_name)
begin
  db.method(:find_by_name)
rescue NameError => e
  row "", "db.method(:find_by_name)", "#{e.class}: #{e.message}"
end
row 6, "listed.respond_to?(:find_by_name)", listed.respond_to?(:find_by_name)
row "", 'listed.method(:find_by_lang).call("Python")', listed.method(:find_by_lang).call("Python").inspect
row 7, "listed.methods.include?(:find_by_name)", listed.methods.include?(:find_by_name)
db.rows
db.rows
row 8, "hook_calls: 2 ghosts (rows 1, 3), then rows, rows", "#{db.hook_calls} (real methods never reach the hook)"
row 9, "Swallow.new.typo -- method_missing without super", Swallow.new.typo.inspect
row "", "Swallow.new.respond_to?(:typo)", Swallow.new.respond_to?(:typo)
memo = Memo.new
row 10, "memo.say_hello twice -> value, hits", "#{memo.say_hello.inspect} #{memo.say_hello.inspect}, hits = #{memo.hits}"
row "", "Memo.instance_methods(false).include?(:say_hello)", Memo.instance_methods(false).include?(:say_hello)
begin
  db.method_missing(:find_by_name, "Ada")
rescue NoMethodError => e
  row 11, "db.method_missing(:find_by_name, \"Ada\") explicitly", "#{e.class}: #{e.message}"
end
row 12, "from row 3: e.name / e.receiver.equal?(db)", "#{missing.name.inspect} / #{missing.receiver.equal?(db)}"
