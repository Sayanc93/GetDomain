require_relative "../get_domain"

describe 'SearchHelper module tests' do
  before(:each) do
    stub_request(:get, GOOGLE_SEARCH_API).with(query: { key: GOOGLE_API_KEY,
                                                        q: "microsoft",
                                                        num: 7,
                                                        safe: "high",
                                                        cx: GOOGLE_CUSTOM_SEARCH_ID })
                                          .to_return(body: { "items"=>[{ "link" => "https://www.microsoft.com",
                                                                         "displayLink" => "microsoft.com" }] }.to_json)

    stub_request(:get, CLEARBIT_AUTOCOMPLETE_API).with(query: { query: "microsoft" })
                                                 .to_return(body: [{"domain" => "microsoft.com"}].to_json)

    stub_request(:get, FULLCONTACT_LOOKUP_API).with(query: { "domain" => "microsoft.com",
                                                             "apiKey" => FULLCONTACT_API_KEY })
                                              .to_return(body: { "organization" => { "name" => "Microsoft",
                                                                                     "keywords" => ["Global", "Services", "Office"] }
                                                               }.to_json)
  end

  it 'should print the one domain from if domains from Google API and Clearbit API call are same' do
    expected_output = "\n\nFetching domains: |=========================================================================================================================================|\n"\
                      "'Microsoft' results :\n"\
                      "Name: Microsoft, Domain: microsoft.com, Jaccard_index: 0.2, Levenstein Distance: 0\n"\
                      "==========================\n"
    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output(expected_output).to_stdout
  end

  it 'should print the correct domain after parsing through irrelevant links from API response for Google API' do
    stub_request(:get, GOOGLE_SEARCH_API).with(query: { key: GOOGLE_API_KEY,
                                                        q: "microsoft",
                                                        num: 7,
                                                        safe: "high",
                                                        cx: GOOGLE_CUSTOM_SEARCH_ID })
                                          .to_return(body: {"items"=>[{"link" => "https://www.nytimes.com/new-ceo-microsoft",
                                                                       "displayLink" => "nytimes.com"},
                                                                       {"link" => "https://www.microsoft.com",
                                                                       "displayLink" => "microsoft.com"}]}.to_json)

    expected_output = "'Microsoft' results :\n"\
                      "Name: Microsoft, Domain: microsoft.com, Jaccard_index: 0.2, Levenstein Distance: 0\n"\
                      "==========================\n"

    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output(expected_output).to_stdout
  end

  it "should give preference to companies with higher jaccard's index and sort accordingly" do
    stub_request(:get, CLEARBIT_AUTOCOMPLETE_API).with(query: { query: "microsoft" })
                                                 .to_return(body: [{"domain" => "microsoft-tech.io"}].to_json)

    stub_request(:get, FULLCONTACT_LOOKUP_API).with(query: { "domain" => "microsoft-tech.io",
                                                             "apiKey" => FULLCONTACT_API_KEY })
                                              .to_return(body: { "organization" => { "name" => "Microsoft IO",
                                                                                     "keywords" => ["Global", "ABC", "Office"] }
                                                               }.to_json)

    expected_output = "'Microsoft' results :\n"\
                      "Name: Microsoft, Domain: microsoft.com, Jaccard_index: 0.6666666666666666, Levenstein Distance: 0\n"\
                      "Name: Microsoft IO, Domain: microsoft-tech.io, Jaccard_index: 0.25, Levenstein Distance: 5\n"\
                      "==========================\n"

    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft -c Global Services))
    end.to output(expected_output).to_stdout
  end

  it "should give preference to companies with lower Levenstein distance if jaccard's index is not present and sort accordingly" do
    stub_request(:get, CLEARBIT_AUTOCOMPLETE_API).with(query: { query: "microsoft" })
                                                 .to_return(body: [{"domain" => "microsoft-tech.io"}].to_json)

    stub_request(:get, FULLCONTACT_LOOKUP_API).with(query: { "domain" => "microsoft.com",
                                                             "apiKey" => FULLCONTACT_API_KEY })
                                              .to_return(body: { "organization" => { "name" => "Microsoft",
                                                                                     "keywords" => [] }
                                                               }.to_json)
    stub_request(:get, FULLCONTACT_LOOKUP_API).with(query: { "domain" => "microsoft-tech.io",
                                                             "apiKey" => FULLCONTACT_API_KEY })
                                              .to_return(body: { "organization" => { "name" => "Microsoft IO",
                                                                                     "keywords" => [] }
                                                               }.to_json)

    expected_output = "'Microsoft' results :\n"\
                      "Name: Microsoft, Domain: microsoft.com, Jaccard_index: 0.0, Levenstein Distance: 0\n"\
                      "Name: Microsoft IO, Domain: microsoft-tech.io, Jaccard_index: 0.0, Levenstein Distance: 5\n"\
                      "==========================\n"

    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output(expected_output).to_stdout
  end

  it "should give preference to Google's SEO links if Levenstein distance is equal for all domains and there's no jaccard's index" do
    stub_request(:get, CLEARBIT_AUTOCOMPLETE_API).with(query: { query: "microsoft" })
                                                 .to_return(body: [{"domain" => "microsoft.io"}].to_json)

    stub_request(:get, FULLCONTACT_LOOKUP_API).with(query: { "domain" => "microsoft.com",
                                                             "apiKey" => FULLCONTACT_API_KEY })
                                              .to_return(body: { "organization" => { "name" => "Microsoft",
                                                                                     "keywords" => [] }
                                                               }.to_json)
    stub_request(:get, FULLCONTACT_LOOKUP_API).with(query: { "domain" => "microsoft.io",
                                                             "apiKey" => FULLCONTACT_API_KEY })
                                              .to_return(body: { "organization" => { "name" => "Microsoft IO",
                                                                                     "keywords" => [] }
                                                               }.to_json)

    expected_output = "'Microsoft' results :\n"\
                      "Name: Microsoft, Domain: microsoft.com, Jaccard_index: 0.0, Levenstein Distance: 0\n"\
                      "Name: Microsoft IO, Domain: microsoft.io, Jaccard_index: 0.0, Levenstein Distance: 0\n"\
                      "==========================\n"

    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output(expected_output).to_stdout
  end

  it 'should print a failed status message if both the APIs are unable to fetch the domain' do
    stub_request(:get, GOOGLE_SEARCH_API).with(query: { key: GOOGLE_API_KEY,
                                                        q: "microsoft",
                                                        num: 7,
                                                        safe: "high",
                                                        cx: GOOGLE_CUSTOM_SEARCH_ID })
                                          .to_return(status: 400)

    stub_request(:get, CLEARBIT_AUTOCOMPLETE_API).with(query: { query: "microsoft" })
                                                 .to_return(body: [].to_json)
    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to raise_error(RuntimeError, "No domains found from APIs, check rate limits")
  end
end
