# Kata: save settings to JSON and to Marshal in a temporary directory, load
# both back, and report which values survived each round trip unchanged.
require "json"
require "tmpdir"

settings = {name: "demo", retries: 3, mode: :fast, since: Time.utc(2024, 1, 1), tags: ["a", "b"]}

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write("settings.json", JSON.generate(settings))
    File.binwrite("settings.marshal", Marshal.dump(settings))
    from_json = JSON.parse(File.read("settings.json"), symbolize_names: true)
    from_marshal = Marshal.load(File.binread("settings.marshal"))
    settings.each_key do |key|
      puts format("%-8s json: %-5s marshal: %-5s (json gave %s)", key, from_json[key] == settings[key], from_marshal[key] == settings[key], from_json[key].inspect)
    end
  end
end
