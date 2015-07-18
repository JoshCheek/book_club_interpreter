require 'bci'

RSpec.describe BCI do
  describe 'setting up the world' do
    # come back to this if we need it
  end

  it 'interprets strings'
  it 'sets and gets local variables'

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
    it 'sets self to main'
    it 'has no local variables'
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
