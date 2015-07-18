lib_root = File.expand_path('..', __dir__)

RSpec.describe 'the binary, bci' do
  it 'runs the binary' do
    Dir.chdir lib_root do
      # first run against Ruby
      ruby_output = `ruby examples/print_username.rb`
      expect($?).to be_success

      # then against our executable
      bci_output = `bin/bci examples/print_username.rb`
      expect($?).to be_success

      # they should have the same output
      expect(bci_output).to eq ruby_output
    end
  end
end
