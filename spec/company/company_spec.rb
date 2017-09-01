require_relative "../../lib/company/company"

describe 'Company class tests' do

  it 'should not raise error when attributes is nil or empty' do
    company_name = "Test Company"
    domain = "test.com"
    attributes = nil

    company_object = Company.new(company_name, domain, attributes)

    expect(company_object.name).to eq("Test Company")
    expect(company_object.fetched_domain).to eq("test.com")
    expect(company_object.attributes).to eq([])

    attributes = []
    company_object = Company.new(company_name, domain, attributes)
    expect(company_object.attributes).to eq([])
  end

  it "should assign jaccard's index and levenstein distance correctly" do
    company_name = "Test Company"
    domain = "test.com"
    attributes = ["test", "spec", "example"]

    company_object = Company.new(company_name, domain, attributes)
    company_object.assign_category_jaccard_index(["test", "internet", "random"])
    company_object.calculate_levenstein_distance("piratetesting")

    expect(company_object.jaccard_index).to eq(0.2)
    expect(company_object.levenstein_distance).to eq(9)
  end

end
