# Kata: run!(*argv) runs a command with Open3.capture3 and returns its stdout,
# or raises CommandFailed carrying the exit status and the child's stderr.
require "rbconfig"
require "open3"

class CommandFailed < StandardError
  attr_reader :status, :stderr

  def initialize(argv, status, stderr)
    @status = status
    @stderr = stderr
    super("#{File.basename(argv.first)} exited #{status}")
  end
end

def run!(*argv)
  out, err, status = Open3.capture3(*argv)
  raise CommandFailed.new(argv, status.exitstatus, err) unless status.success?
  out
end

puts run!(RbConfig.ruby, "-e", "puts 'fine'")
begin
  run!(RbConfig.ruby, "-e", "warn 'disk on fire'; exit 3")
rescue CommandFailed => e
  puts "#{e.class}: #{e.message} -- status=#{e.status} stderr=#{e.stderr.inspect}"
end
