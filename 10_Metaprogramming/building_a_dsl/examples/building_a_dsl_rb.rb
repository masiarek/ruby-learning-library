# building_a_dsl_rb.rb — a configuration DSL, a routing DSL, and what a DSL block can see.
# Each row is one measurement; the Python twin prints the same rows.

require "stringio"

def row(n, label, value)
  head = n.to_s.empty? ? "   " : format("%2d.", n)
  puts format("%s %-46s %s", head, label, value)
end

class Config
  class Error < StandardError; end

  def initialize = @settings = {}

  def self.build(&blk)
    cfg = new
    blk.arity == 1 ? blk.call(cfg) : cfg.instance_eval(&blk)   # 8. arity picks the style
    cfg.validate!
    cfg
  end

  def host(value = nil) = value.nil? ? @settings[:host] : @settings[:host] = value
  def port(value = nil) = value.nil? ? @settings[:port] : @settings[:port] = value
  def database(&blk) = @settings[:database] = Config.build(&blk)   # 4. nesting

  def method_missing(name, *args)                              # 3. any other key
    args.size == 1 ? @settings[name] = args.first : super
  end

  def validate! = @settings.key?(:port) || raise(Error, "port is required")
  def to_h = @settings.transform_values { |v| v.is_a?(Config) ? v.to_h : v }
  def inspect = "Config(#{@settings.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")})"
end

class Router
  attr_reader :routes
  def initialize = @routes = {}
  def self.draw(&blk) = new.tap { |r| r.instance_eval(&blk) }
  def get(path, &handler) = @routes[path] = handler            # 6. blocks stored for later
  def call(path) = instance_exec(path, &@routes.fetch(path))   # 7. run as the router
  def redirect_to(path) = "redirect to #{path}"
end

class Site                                                     # 5. the caller's world
  def initialize = @env = "prod"
  def helper = "helper"

  def configure
    default_port = 8080
    Config.build do
      host "example.org"
      port default_port
      sees_local default_port
      sees_ivar @env.inspect
      sees_method (helper rescue "NameError")
    end
  end

  def configure_yielded
    Config.build do |c|
      c.host "example.org"
      c.port 80
      c.sees_ivar @env
      c.sees_method helper
    end
  end
end

class Kw                                                       # 9. keyword arguments, no DSL
  def initialize(host:, port: 80) = (@host, @port = host, port)
  def inspect = "Kw(host: #{@host.inspect}, port: #{@port})"
end

class Html                                                     # 13. the Kernel#p trap
  def initialize = @out = +""
  def self.build(&blk) = new.tap { |h| h.instance_eval(&blk) }.to_s
  def method_missing(tag, text = nil, &blk)
    @out << "<#{tag}>"
    text ? @out << text : instance_eval(&blk)
    @out << "</#{tag}>"
  end
  def to_s = @out
end

cfg = Config.build do
  host "example.org"
  port 80
  timeout 30
  database do
    adapter "pg"
    port 5432
  end
end
row 1, "Config.build do host ...; port 80 end", cfg.inspect
row 2, "cfg.host", cfg.host.inspect
row 3, "timeout 30 -- an open-ended key (method_missing)", cfg.to_h[:timeout]
row 4, "database do adapter \"pg\" end -- nested", cfg.to_h[:database][:adapter].inspect
seen = Site.new.configure.to_h
row 5, "instance_eval block sees: local / @ivar / method",
    "#{seen[:sees_local]} / #{seen[:sees_ivar]} / #{seen[:sees_method]}"

router = Router.draw do
  get("/") { redirect_to("/home") }
  get("/about") { |path| "about page (#{path})" }
end
row 6, 'router.call("/about") -- a stored block', router.call("/about").inspect
row 7, 'router.call("/") -- the block runs as the router', router.call("/").inspect
seen = Site.new.configure_yielded.to_h
row 8, "Config.build { |c| ... } sees @ivar / method", "#{seen[:sees_ivar].inspect} / #{seen[:sees_method].inspect}"
row 9, "Kw.new(host: \"x\") -- keywords, no DSL", Kw.new(host: "x").inspect
begin
  Config.build { host "x" }
rescue Config::Error => e
  row 10, "Config.build { host \"x\" } -- validation", "#{e.class}: #{e.message}"
end
row 11, "router.routes.keys -- insertion order", router.routes.keys.inspect
row 12, "cfg.to_h", cfg.to_h.inspect

captured = StringIO.new
$stdout = captured
html = Html.build { div { p "text" } }
$stdout = STDOUT
row 13, 'Html.build { div { p "text" } } -- p is Kernel#p', "Kernel#p printed #{captured.string.chomp}, built #{html.inspect}"
row "", 'Html.build { div { span "text" } }', Html.build { div { span "text" } }.inspect
