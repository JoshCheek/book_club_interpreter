require 'parser/ruby22'
require 'pry'

# * Objects - instance variables, pointer to its class
# * Classes
#   - Classy things
#     * instance methods
#     * pointer to its superclass
#   - Objecty things (because classes are objects)
#     * instance variables
#     * pointer to its class
# * Stack
#   - array of bindings

class BCI
  def self.parse(code)
    Parser::Ruby22.parse(code)
  end

  attr_accessor :stack,
                :object_class,
                :string_class,
                :main_object,
                :nil_object

  def initialize(ast:, stdout:)
    @ast, @stdout = ast, stdout

    self.object_class = {
      # * instance methods
      # * pointer to its superclass
      # * instance variables
      # * pointer to its class
    }

    self.string_class = {
    }

    self.main_object = {
      ivars:        {},
      class:        object_class,
      nil:          nil_object
    }

    toplevel_binding = {
      self:         main_object,
      locals:       {},
      return_value: ??,
    }

    self.stack = [toplevel_binding]
  end

  def current_value
    stack.last[:return_value]
  end

  def interpret
    interpret_ast @ast
  end

  private

  def current_value=(object)
    stack.last[:return_value] = object
  end

  def interpret_ast(ast)
    case ast.type
    when :str
      data = ast.children[0]
      self.current_value = {
        class: string_class,
        data:  data
      }
    when :begin
      ast.children.each do |child|
        interpret_ast child
      end
    when :lvasgn
      name = ast.children[0]
      interpret_ast(ast.children[1])
      stack.last[:locals][name] = current_value
    when :lvar
      name = ast.children[0]
      self.current_value = stack.last[:locals][name]
    when :self
      self.current_value = stack.last[:self]
    when :nil
      self.current_value = stack.last[:nil]
    else raise "Unknown AST: #{ast.inspect}"
    end
  end
end
