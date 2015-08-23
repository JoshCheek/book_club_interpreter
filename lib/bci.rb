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
                :nil_object,
                :classy_class,
                :classy_nil_class

  def initialize(ast:, stdout:)
    @ast, @stdout = ast, stdout

    self.classy_class = {
      human_name: "Class",
      superclass: nil, # should be Module
      constants:  {},
      methods:    {},

      class:      nil, # itself
      ivars:      {},
    }
    classy_class[:class] = classy_class

    self.object_class = {
      human_name: "Object",
      superclass: nil, # should be Kernel/BasicObject
      constants:  {},
      methods:    {},

      class:      classy_class,
      ivars:      {},

      # * instance methods
      # * pointer to its superclass
      # * instance variables
      # * pointer to its class
    }

    self.string_class = {
      human_name: "String",
      superclass: object_class, # should be Module
      constants:  {},
      methods:    {},

      ivars:      {},
      class:      classy_class,
    }

    self.classy_nil_class = {
      human_name: "NilClass",
      superclass: object_class, # should be Module
      constants:  {},
      methods:    {},

      ivars:      {},
      class:      classy_class,
    }

    self.nil_object = {
      human_name: "nil",
      class: classy_nil_class,
      ivars: {},
    }

    self.main_object = {
      human_name: "main",
      ivars: {},
      class: object_class,
    }

    toplevel_binding = {
      human_name: "toplevel binding",
      self:         main_object,
      locals:       {},
      return_value: nil_object,
    }

    self.stack = [toplevel_binding]
  end

  def current_value
    stack.last[:return_value]
  end

  def interpret
    interpret_ast @ast if @ast
  end

  private

  def current_value=(object)
    stack.last[:return_value] = object
  end

  def interpret_ast(ast)
    case ast.type
    when :str
      data = ast.to_a[0]
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
      self.current_value = nil_object
    when :class
      class_name = ast.children[0].children.last
      klass      = {
        human_name: class_name,
        class: classy_class,
        ivars: {},

        methods:    {},
        constants:  {},
        superclass: object_class,
      }

      self.object_class[:constants][class_name] = klass

      body = ast.to_a[2]

      binding = {
        human_name:   class_name,
        self:         klass,
        locals:       {},
        return_value: nil_object
      }
      stack.push(binding)
      interpret_ast(body) if body
      stack.pop
      stack.last[:return_value] = binding[:return_value]

    when :def

      method_name = ast.to_a.first
      method_body = ast.to_a.last
      stack.last[:self][:methods][method_name] = method_body

    else raise "Unknown AST: #{ast.inspect}"
    end
  end
end
