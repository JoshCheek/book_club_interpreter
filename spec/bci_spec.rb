require 'bci'

RSpec.describe BCI do
  def interpret(code)
    ast = BCI.parse(code)
    bci = BCI.new(ast: ast, stdout: "idk")
    bci.interpret
    bci
  end

  def assert_object(object, assertions)
    assertions.each do |assertion_type, value|
      case assertion_type
      when :class
        expect(object.fetch(:class).equal? value).to be_truthy
      when :data
        expect(object.fetch :data).to eq value
      when :methods
        expect(object.fetch :methods).to eq value
      when :superclass
        expect(object.fetch :superclass).to equal value
      when :method_names
        expect(object.fetch(:methods).keys).to eq value
      when :classname
        expect(object.fetch(:class).fetch(:human_name)).to eq value
      when :has_method
        expect(object.fetch(:methods).keys).to include value
      when :ivars
        expect(object.fetch(:ivars).keys).to eq value
      else
        raise "Unknown assertion type: #{assertion_type.inspect}"
      end
    end
  end

  describe 'setting up the world' do
    # come back to this if we need it
  end

  it 'interprets strings' do
    bci = interpret("'abc'")
    assert_object bci.current_value,
                  class: bci.string_class,
                  data:  "abc"
  end

  it 'interprets nil' do
    bci = interpret('nil')
    expect(bci.current_value).to equal bci.nil_object
  end

  it 'interprets multiple expressions' do
    bci = interpret("'a'; 'b'")
    assert_object bci.current_value,
                  class: bci.string_class,
                  data:  "b"
  end

  it 'sets and gets local variables' do
    bci = interpret("a = 'abc'; b = 'def'; a")
    assert_object bci.current_value, data: "abc"

    bci = interpret("a = 'abc'; b = 'def'; b")
    assert_object bci.current_value, data: "def"
  end

  describe 'class' do
    it 'defines classes as constants under Object' do
      bci = interpret("class User; end")
      user_class = bci.object_class[:constants][:User]
      assert_object user_class,
                    class:      bci.classy_class,
                    ivars:      [],
                    methods:    {},
                    superclass: bci.object_class
    end

    describe 'evaluating the body' do
      it 'defaults to nil' do
        bci = interpret("class User; end")
        expect(bci.current_value).to equal bci.nil_object
      end

      it 'returns the last line in the body' do
        bci = interpret("class User; 'abc'; end")
        assert_object bci.current_value,
                      class: bci.string_class,
                      data:  "abc"
      end

      it 'records method definitions' do
        bci = interpret("class User; end")
        user_class = bci.object_class[:constants][:User]
        assert_object user_class, method_names: []

        bci = interpret("class User; def zomg; end; end")
        user_class = bci.object_class[:constants][:User]
        assert_object user_class, method_names: [:zomg]
      end

      it 'evalutates in a binding for the class it is defining' do
        bci = interpret("class User; self; end")
        user_class = bci.object_class[:constants][:User]
        expect(bci.current_value).to equal user_class

        bci = interpret("class User; self; end; self")
        expect(bci.current_value).to equal bci.main_object
      end

      it 'sets the superclass to Object by default' do
        bci = interpret('class A; end; A')
        assert_object bci.current_value, superclass: bci.object_class
      end
    end
  end

  describe 'toplevel' do
    describe 'main' do
      it 'is an instance of Object with no instance variables' do
        bci = interpret 'self'
        assert_object bci.main_object,
                      class: bci.object_class,
                      ivars: []
      end
      it 'has to_s and inspect defined on its singleton class to return the string "main"'
    end

    it 'sets self to main' do
      bci = interpret("self")
      expect(bci.current_value).to equal bci.main_object
    end

    it 'has no local variables' do
      bci = interpret("")
      expect(bci.stack.last[:locals]).to be_empty
    end

    it 'defines methods in Object' do
      bci = interpret "def lol; end"
      assert_object bci.object_class, has_method: :lol
    end
  end

  describe 'invoking methods' do
    it 'invokes it on "self" if no target is provided' do
      bci = interpret("def a; self; end; a")
      expect(bci.current_value).to equal bci.main_object
    end

    it 'invokes it on the target, if the target is provided' do
      bci = interpret("class A; def b; self; end; end; A.new.b")
      assert_object bci.current_value, classname: :A
    end

    it 'has its own set of local variables' do
      skip
      bci = interpret("a = 1; def b; a = 2; a; end; a + b")
      assert_object bci.current_value, classname: :A
    end

    it 'has a return value' do
      bci = interpret("def a; 'whatev'; end; a")
      assert_object bci.current_value,
                    class: bci.string_class,
                    data:  "whatev"
    end

    it 'defaults the return value to nil' do
      bci = interpret("def a; end; a")
      expect(bci.current_value).to equal bci.nil_object
    end

    it 'evaluates one argument in the context of the caller' do
      bci = interpret("def a(b); b; end; b='Josh'; a(b);")
      assert_object bci.current_value,
                        class: bci.string_class,
                        data: "Josh"
    end

    it 'evaluates multiple arguments in the context of the caller' do
      bci = interpret("def a(b, c); b; c; end; b='Josh'; c='Lovisa'; a(b, c);")
      assert_object bci.current_value,
                        class: bci.string_class,
                        data: "Lovisa"
    end
  end

  describe 'instance variables', current: true do
    specify 'setting an ivar emits the ivar as the current value' do
      bci = interpret("@a = 'b'")
      assert_object bci.current_value,
                    class: bci.string_class,
                    data:  "b"
    end

    it 'getting an ivar sets it as the current value' do
      bci = interpret("@a = 'b'; 'c'; @a")
      assert_object bci.current_value,
                    class: bci.string_class,
                    data:  "b"
    end

    it 'stores the ivars on self' do
      bci = interpret("@a = 'b'")
      assert_object bci.main_object, ivars: [:@a]
    end
  end

  describe 'builtin methods' do
    describe 'Object (technically Kernel ;)' do
      it 'has a puts method, which sends strings to the stdout, with a trailing newline'
    end
  end
end
