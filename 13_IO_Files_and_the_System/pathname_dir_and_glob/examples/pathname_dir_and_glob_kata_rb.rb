# Kata: print a directory as an indented tree, directories marked with a
# trailing slash, entries sorted, using Pathname#children recursively.
require "pathname"
require "tmpdir"
require "fileutils"

def tree(path, indent)
  path.children.sort.each do |child|
    puts "#{indent}#{child.basename}#{child.directory? ? "/" : ""}"
    tree(child, indent + "  ") if child.directory?
  end
end

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    FileUtils.mkdir_p("lib/deep")
    FileUtils.mkdir_p("spec")
    %w[lib/app.rb lib/deep/util.rb spec/app_spec.rb README.md Rakefile].each { |f| FileUtils.touch(f) }
    puts "./"
    tree(Pathname("."), "  ")
  end
end
