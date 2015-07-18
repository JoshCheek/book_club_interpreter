class BCI
  def self.parse(code)
  end

  def initialize(ast:, stdout:)
    @ast, @stdout = ast, stdout
  end

  def interpret
    @stdout.puts "Josh"
  end
end
