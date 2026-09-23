# A gem is a versioned package; RubyGems (Gem) resolves and activates it;
# Bundler reads a Gemfile. Everything here is measured without installing anything.
require "tmpdir"

def row(n, label, value = nil)
  puts format("%2d. %-38s %s", n, label, value)
end

def default_gem?(name)
  Gem::Specification.find_by_name(name).default_gem?
rescue Gem::LoadError => e
  "no gem at all (#{e.class})"
end

row 1, "json: part of the standard install?", "default gem: #{default_gem?("json")}"
row 2, "csv: part of the standard install?",
    "default gem: #{default_gem?("csv")}   bundled gem since #{Gem::BUNDLED_GEMS::SINCE["csv"]}"
row 3, "minitest:", "default gem: #{default_gem?("minitest")}   in the since-list: " \
    "#{Gem::BUNDLED_GEMS::SINCE.key?("minitest")} (bundled since before 3.0)"
row 4, "set:", default_gem?("set").to_s + " -- a core class in 4.0"

require "json"
row 5, 'what require "json" activated', "Gem.loaded_specs[\"json\"].name = #{Gem.loaded_specs["json"].name}; " \
    "a default gem has a spec too"

first  = gem "minitest"
second = gem "minitest"
row 6, 'gem "minitest" in code (activate)', "first: #{first}   second: #{second}"

begin
  gem "nope"
rescue Gem::LoadError => e
  row 7, 'gem "nope"', "#{e.class}   is a LoadError: #{e.is_a?(LoadError)}   e.name: #{e.name.inspect}"
end

v = ->(s) { Gem::Version.new(s) }
row 8, "versions compare as numbers",
    "Gem::Version 1.10 > 1.9: #{v["1.10"] > v["1.9"]}   as strings: #{"1.10" > "1.9"}   " \
    "2.0.0.pre < 2.0.0: #{v["2.0.0.pre"] < v["2.0.0"]}"
req = Gem::Requirement.new("~> 1.2")
row 9, "a requirement, #{req}", "satisfied by 1.9: #{req.satisfied_by?(v["1.9"])}   " \
    "by 2.0: #{req.satisfied_by?(v["2.0"])}"

require "bundler"
Dir.mktmpdir do |dir|
  gemfile = File.join(dir, "Gemfile")
  File.write(gemfile, <<~GEMFILE)
    source "https://rubygems.org"

    gem "minitest", "~> 5.0"
    gem "csv"
    gem "rake", group: :development
  GEMFILE
  definition = Bundler::Dsl.evaluate(gemfile, nil, {})
  deps = definition.dependencies.map { |d| "#{d.name} (#{d.requirement}) #{d.groups.inspect}" }
  row 10, "a Gemfile, evaluated by Bundler", deps.join(", ")
end

spec = Gem::Specification.new do |s|
  s.name    = "demo"
  s.version = "0.1.0"
  s.summary = "A demo gem"
  s.authors = ["A. Reader"]
  s.files   = ["lib/demo.rb"]
  s.add_dependency "json", "~> 2.0"
  s.add_development_dependency "minitest", ">= 5"
end
row 11, "a gemspec object", "#{spec.full_name}   runtime: #{spec.runtime_dependencies.map(&:to_s).join(", ")}" \
    "   development: #{spec.development_dependencies.map(&:to_s).join(", ")}"
