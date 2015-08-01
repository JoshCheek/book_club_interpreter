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
        expect(object.fetch :class).to equal value
      when :data
        expect(object.fetch :data).to eq value
      when :ivars
        expect(object.fetch :ivars).to eq value
      when :methods
        expect(object.fetch :methods).to eq value
      when :superclass
        expect(object.fetch :superclass).to equal value
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
                    class:   bci.classy_class,
                    ivars:   {},
                    methods: {},
                    superclass: bci.object_class
    end

    describe 'evaluating the body' do
      it 'records method definitions'
      it 'returns the last line in the body'
    end
  end

  describe 'toplevel' do
    it 'sets self to main' do
      bci = interpret("self")
      expect(bci.current_value).to equal bci.main_object
      assert_object bci.main_object,
                    class: bci.object_class,
                    ivars: {}
    end

    it 'has no local variables' do
      bci = interpret("")
      expect(bci.stack.last[:locals]).to be_empty
    end
  end

  describe 'invoking methods' do
    it 'invokes it on "self" if no target is provided'
    it 'invokes it on the target, if the target is provided'
    it 'has its own set of local variables'
    it 'has a return value'
    it 'defaults the return value to nil'
  end

  describe 'instance variables' do
    it 'sets and gets these variables from self'
  end

  describe 'builtin methods' do
    describe 'Object (technically Kernel ;)' do
      it 'has a puts method, which sends strings to the stdout, with a trailing newline'
    end
  end
end
