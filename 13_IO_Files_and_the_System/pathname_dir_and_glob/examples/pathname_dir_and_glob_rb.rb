# Pathname, Dir.glob and the File path helpers, in a temporary directory that
# holds a small project tree. Only relative names are printed.
require "pathname"
require "tmpdir"
require "fileutils"

def row(n, text, value = "")
  puts format("%2d. %-56s %s", n, text, value)
end

row 1, "the runner's cwd is the example's folder: its basename", File.basename(Dir.pwd)
row 2, "__dir__ is this file's folder: its basename", File.basename(__dir__)

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    FileUtils.mkdir_p("lib/deep")
    FileUtils.mkdir_p("spec")
    File.write("lib/app.rb", "puts 1\n")
    File.write("lib/deep/util.rb", "")
    File.write("spec/app_spec.rb", "")
    File.write("README.md", "# hi\n")
    File.write("lib/notes.txt", "")

    app = Pathname("lib") / "app.rb"
    row 3, 'Pathname("lib") / "app.rb"; + is the same; join', "#{app.inspect}; #{(Pathname("lib") + "app.rb") == app}; #{Pathname("lib").join("deep", "util.rb")}"
    row 4, 'basename, extname, dirname, parent, basename(".rb")', [app.basename, app.extname, app.dirname, app.parent, app.basename(".rb")].map(&:to_s).inspect
    row 5, "exist?, file?, directory?, and a missing name", [app.exist?, app.file?, app.dirname.directory?, Pathname("nope").exist?].inspect
    row 6, "read and size", "#{app.read.inspect}, #{app.size}"
    row 7, "children of lib, sorted", Pathname("lib").children.map(&:to_s).sort.inspect
    row 8, "lib/deep/util.rb relative_path_from(spec)", Pathname("lib/deep/util.rb").relative_path_from(Pathname("spec")).to_s

    found = Dir.glob("**/*.rb")
    row 9, 'Dir.glob("**/*.rb") is sorted by default (since 3.0)', "#{found.inspect}; sorted=#{found == found.sort}"
    row 10, 'braces: Dir.glob("**/*.{rb,md}")', Dir.glob("**/*.{rb,md}").inspect
    row 11, "Dir[] is glob; Pathname.glob gives Pathnames", "#{Dir["*.md"].inspect}; #{Pathname.glob("lib/**/*.rb").map(&:to_s).inspect}"
    row 12, 'Dir.children(".") vs Dir.entries(".") (sorted)', "#{Dir.children(".").sort.inspect} vs #{Dir.entries(".").sort.inspect}"
    row 13, "a glob skips dotfiles unless File::FNM_DOTMATCH", "#{Dir.glob("*").sort.inspect}; #{Dir.glob("*", File::FNM_DOTMATCH).sort.inspect}"

    row 14, "File.join collapses the separators", "#{File.join("lib", "deep", "util.rb")}; #{File.join("a/", "/b")}"
    row 15, 'File.expand_path("../b", "/base/a")', File.expand_path("../b", "/base/a")
    row 16, 'Pathname("a//b/../c").cleanpath', Pathname("a//b/../c").cleanpath.to_s
    row 17, "File.basename(x, ext), extname, dirname, dirname of a bare", [File.basename("/a/b/c.rb", ".rb"), File.extname("c.tar.gz"), File.dirname("/a/b/c.rb"), File.dirname("c.rb")].inspect
    row 18, "sub_ext; absolute? of lib and /lib; relative?", [Pathname("x.tar.gz").sub_ext(".zip").to_s, Pathname("lib").absolute?, Pathname("/lib").absolute?, Pathname("lib").relative?].inspect
    row 19, "each_filename; descend; ascend", "#{app.each_filename.to_a.inspect}; #{app.descend.map(&:to_s).inspect}; #{app.ascend.map(&:to_s).inspect}"
    row 20, "File.fnmatch: * crosses / unless File::FNM_PATHNAME", [File.fnmatch("*.rb", "lib/app.rb"), File.fnmatch("*.rb", "lib/app.rb", File::FNM_PATHNAME)].inspect
    row 21, "File.ftype of a directory and a file", [File.ftype("lib"), File.ftype("lib/app.rb")].inspect

    File.rename("README.md", "README.txt")
    renamed = Dir["README*"]
    File.delete("README.txt")
    FileUtils.rm_rf("spec")
    row 22, "File.rename; File.delete; FileUtils.rm_rf (exist? after)", "#{renamed.inspect}; #{File.exist?("README.txt")}; #{Dir.exist?("spec")}"

    made = Dir.mktmpdir("prefix-")
    prefixed = File.basename(made).start_with?("prefix-")
    FileUtils.remove_entry(made)
    row 23, 'Dir.mktmpdir("prefix-") without a block: made, then removed', "prefixed=#{prefixed}; gone=#{!Dir.exist?(made)}"
  end
  $dir = dir
  row 24, "inside Dir.mktmpdir's block the directory exists", Dir.exist?(dir)
end
row 25, "after the block it is gone", Dir.exist?($dir)
