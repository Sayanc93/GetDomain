require_relative "../../lib/algorithms/levenstein_distance"

describe 'Levenstein Distance module tests' do
  before(:each) do
    @string1 = "guru-tech"
    @string2 = "guru"
  end

  it 'should print the correct levenstein distance for test strings' do
    expect(Levenstein::Distance.generate(@string1, @string2)).to eq([5, 1.25])
  end

  it 'should print the correct levenstein distance when 2 strings are equal' do
    string3 = "guru"

    expect(Levenstein::Distance.generate(@string2, string3)).to eq([0, 0.0])
  end

  it 'should print the correct levenstein distance when one of the string is empty' do
    string3 = ""

    expect(Levenstein::Distance.generate(@string2, string3)).to eq([4, 0.0])
  end

end
