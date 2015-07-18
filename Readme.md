Interpreter
===========

Jobs of the interpreter:

1. parse the code:
   This takes Ruby code, and gives us back an AST (object we can work with, that represents the syntax)
   `Parser::Ruby22.parse("1+1")`
2. create the internal objects that allow Ruby to work (object model)
   * Objects   - instance variables, pointer to its class
   * Classes
     - Classy things
       * instance methods
       * pointer to its superclass
     - Objecty things (because classes are objects)
       * instance variables
       * pointer to its class
   * Bindings
     - self
     - local variables
     - return value
   * Stack
     - array of bindings
3. Evaluate the AST:
   manipulate the internal objects that allow Ruby to work (object model)
   how to manipulate it will depend on what kind of AST it is.
   eg, `"abc"` becomes (str "abc"), so we see that it has type str,
       and go create a new String object, then put it as the current return value in the current binding

Starting spot
=============

Given this code:

```ruby
class User
  def initialize(name)
    self.name = name
  end

  def name
    @name
  end

  def name=(name)
    @name = name
  end
end

user = User.new("Josh")
puts user.name
```

We need to Interpret it:

* From the outside:
  * `bin/bci print_username.rb` and it prints `Josh`
* From the inside:
  * We should see that there is now a class "User"
    * with instance methods "initialize", "name", "name="
      Our world should have an instance of User with @name="Josh"
  * "Josh\n" was printed
