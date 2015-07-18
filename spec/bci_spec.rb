require 'bci'

RSpec.describe BCI do
  describe 'setting up the world' do
    # come back to this if we need it
  end

  it 'interprets strings' do
    bci = interpret("'abc'")
    assert_object bci.current_value,
                  class: bci.stringClass,
                  data:  "abc"
  end

  it 'sets and gets local variables' do
    bci = interpret("a = 'abc'; b = 'def'; a")
    assert_object bci.current_value, data: "abc"

    bci = interpret("a = 'abc'; b = 'def'; b")
    assert_object bci.current_value, data: "def"
  end

  describe 'class' do
    it 'defines classes the class as a constant under User'
    it 'starts them with no instance variables'
    it 'sets the class to Class'
    it 'has no intance methods by default'
    it 'sets the superclass to Object by default'

    describe 'evaluating the body' do
      it 'records method definitions'
      it 'returns the last line in the body'
    end
  end

  describe 'toplevel' do
    it 'sets self to main' do
      bci = interpret("self")
      expect(bci.current_value).to equal bci.mainObject
    end

    it 'has no local variables' do
      bci = interpret("")
      expect(bci.stack.last.locals).to be_empty
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
