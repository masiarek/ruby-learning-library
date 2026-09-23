# common_error_messages_rb.rb -- the errors page: for each common exception class, the
# code that raises it and the message Ruby 4.0 prints. Ruby's messages are stable
# within a release, so they are printed in full; only SyntaxError's, which quotes the
# source with carets, is left out.

class Vault
  private def secret = 1
end

def two(a, b) = nil
def kw(k:) = nil
def kw2(k: 1) = nil
def needs_block = yield
def down = down

def show(n, code)
  yield
  puts "#{n.to_s.rjust(2)}. #{'(no error)'.ljust(26)} #{code}"
rescue Exception => e
  puts "#{n.to_s.rjust(2)}. #{e.class.to_s.ljust(26)} #{code}"
  puts "    #{e.is_a?(SyntaxError) ? '(message not printed: it quotes the source, with carets)' : e.message}"
end

show(1, "nil.length") { nil.length }
show(2, "Vault.new.secret") { Vault.new.secret }
show(3, '"s".zzz') { "s".zzz }
show(4, "nope") { nope }
show(5, "Nope") { Nope }
show(6, "two(1)") { two(1) }
show(7, "kw") { kw }
show(8, "kw2(z: 1)") { kw2(z: 1) }
show(9, "[3, nil].sort") { [3, nil].sort }
show(10, '"a" + 1') { "a" + 1 }
show(11, '1 + "a"') { 1 + "a" }
show(12, "1 / 0") { 1 / 0 }
show(13, "{a: 1}.fetch(:x)") { { a: 1 }.fetch(:x) }
show(14, "[1, 2, 3].fetch(5)") { [1, 2, 3].fetch(5) }
show(15, '"abc".freeze << "d"') { "abc".freeze << "d" }
show(16, "[].each.next") { [].each.next }
show(17, "needs_block  (def needs_block = yield)") { needs_block }
show(18, "down  (def down = down)") { down }
show(19, "case 5; in String then 1; end") { case 5; in String then 1; end }
show(20, "case {a: 1}; in {name:} then 1; end") { case { a: 1 }; in { name: } then 1; end }
show(21, "Float::NAN.to_i") { Float::NAN.to_i }
show(22, "Float::INFINITY.to_i") { Float::INFINITY.to_i }
show(23, 'require "nope_nothing"') { require "nope_nothing" }
show(24, 'File.read("missing.txt")') { File.read("missing.txt") }
show(25, "f.close; f.read") { File.open(__FILE__) { |f| f.close; f.read } }
show(26, "f.readline at end of file") { File.open(__FILE__) { |f| f.read; f.readline } }
show(27, "throw :x") { throw :x }
show(28, "raise NotImplementedError") { raise NotImplementedError }
show(29, 'RubyVM::InstructionSequence.compile("def")') { RubyVM::InstructionSequence.compile("def") }
