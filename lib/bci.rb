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
                :classy_nil_class,
                :deftargets

  def initialize(ast:, stdout:)
    @ast, @stdout = ast, stdout

    new_method = lambda do
      klass    = stack.last[:self]
      instance = { class: klass, instance_variables: {} }
      args     = [] # FIXME: need to forward them
      invoke_method instance, :initialize, args
      stack.last[:return_value] = instance
    end

    self.classy_class = {
      human_name: "Class",
      superclass: nil, # should be Module
      constants:  {},
      methods:    {
        new: { type: :internal, body: new_method },
      },

      class:      nil, # itself
      ivars:      {},
    }
    classy_class[:class] = classy_class

    self.object_class = {
      human_name: "Object",
      superclass: nil, # should be Kernel/BasicObject
      constants:  {},
      methods:    {
        initialize: {
          type: :internal,
          body: lambda { }, # FIXME: should emit nil?
        }
      },

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

    self.stack      = [toplevel_binding]
    self.deftargets = [object_class]
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
      deftargets.push(klass)

      interpret_ast(body) if body
      deftargets.pop
      stack.pop
      stack.last[:return_value] = binding[:return_value]

    when :def
      method_name = ast.to_a.first
      method_body = ast.to_a.last
      deftargets.last[:methods][method_name] = {type: :ast, body: method_body}

    when :send
      target_ast, method_name, *arg_asts = ast.to_a
      if target_ast
        target = interpret_ast(target_ast)
      else
        target = stack.last.fetch(:self)
      end
      raise 'test arg passing' if arg_asts.any?
      invoke_method target, method_name, []

    when :const
      namespace_ast, name = ast.to_a
      if namespace_ast
        namespace = interpret_ast namespace_ast
      else
        namespace = object_class
      end
      stack.last[:return_value] = namespace[:constants].fetch(name)

    else raise "Unknown AST: #{ast.inspect}"
    end
  end

  def invoke_method(target, method_name, args)
    method  = find_method(target, method_name)
    binding = {
      human_name:   method_name.to_s,
      self:         target,
      locals:       {},
      return_value: nil_object,
    }
    stack.push(binding)
    case method[:type]
    when :internal then method[:body].call
    when :ast
      if method[:body]
        interpret_ast(method[:body])
      else
        stack.last[:return_value] = nil_object
      end
    else raise "WHAT KIND OF METHOD IS THIS? #{method.inspect}"
    end
    stack.pop
    stack.last[:return_value] = binding[:return_value]
  end

  def find_method(object, method_name)
    klass = object[:class]
    loop do
      break unless klass
      break if klass[:methods].include?(method_name)
      klass = klass[:superclass]
    end

    if klass && klass[:methods][method_name]
      klass[:methods][method_name]
    else
      raise("This interpreter can't yet handle NoMethodErros :P `#{method_name.inspect}`")
    end
  end
end
