require 'parser/ruby22'
require 'pry'

class BCI
  def self.parse(code)
    Parser::Ruby22.parse(code)
  end

  def initialize(ast:, stdout:)
    @ast, @stdout = ast, stdout
  end

  def interpret
    @stdout.puts "Josh"
  end
end
