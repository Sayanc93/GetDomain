require_relative "../../lib/algorithms/jaccard_index"

describe 'Jaccard Index module tests' do
  before(:each) do
    @set1 = [1, 2, 3, 1, 1, 45, 23, 22, 12, 44]
    @set2 = [2, 2, 2, 45]
  end

  it "should print the correct jaccard index for test set" do
    expect(Jaccard::Index.generate(@set1, @set2)).to eq(0.25)
  end

  it "should print correct jaccard's index when one of the set is empty" do
    set2 = []

    expect(Jaccard::Index.generate(@set1, set2)).to eq(0.0)
  end

  it "should print correct jaccard's index when both of the set is equal" do
    expect(Jaccard::Index.generate(@set1, @set1)).to eq(1.0)
  end

end
