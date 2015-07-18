require 'bci'

RSpec.describe 'parsing' do
  it 'parses the code into an ast' do
    ast = BCI.parse("1+2")

    # (send (int 1) :+ (int 2))
    expect(ast.type).to eq :send
    one, plus, two = ast.children

    expect(one.type).to eq :int
    expect(one.children[0]).to eq 1

    expect(plus).to eq :+

    expect(two.type).to eq :int
    expect(two.children[0]).to eq 2
  end
end
