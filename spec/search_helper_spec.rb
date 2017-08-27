require_relative "../get_domain"

describe 'SearchHelper module tests' do
  before(:each) do
    stub_request(:get, GOOGLE_SEARCH_API).with(query: { key: GOOGLE_API_KEY,
                                                        q: "microsoft",
                                                        num: 7,
                                                        safe: "high",
                                                        cx: GOOGLE_CUSTOM_SEARCH_ID })
                                          .to_return(body: {"items"=>[{"link" => "microsoft.com",
                                                                       "displayLink" => "microsoft.com"}]}.to_json)
  end

  it 'should print the correct domain from the response of Google API call for Microsoft domain' do
    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output("microsoft.com\n").to_stdout
  end

  it 'should print the correct domain after parsing through irrelevant links from API response' do
    stub_request(:get, GOOGLE_SEARCH_API).with(query: { key: GOOGLE_API_KEY,
                                                        q: "microsoft",
                                                        num: 7,
                                                        safe: "high",
                                                        cx: GOOGLE_CUSTOM_SEARCH_ID })
                                          .to_return(body: {"items"=>[{"link" => "nytimes.com/new-ceo-microsoft",
                                                                       "displayLink" => "nytimes.com"},
                                                                       {"link" => "microsoft.com",
                                                                       "displayLink" => "microsoft.com"}]}.to_json)

    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output("microsoft.com\n").to_stdout
  end

  it 'should print the correct domain from clearbit API respons after Google API fails' do
    stub_request(:get, GOOGLE_SEARCH_API).with(query: { key: GOOGLE_API_KEY,
                                                        q: "microsoft",
                                                        num: 7,
                                                        safe: "high",
                                                        cx: GOOGLE_CUSTOM_SEARCH_ID })
                                          .to_return(status: 400)

    stub_request(:get, CLEARBIT_AUTOCOMPLETE_API).with(query: { query: "microsoft" })
                                                 .to_return(body: [{"domain" => "microsoft.com"}].to_json)
    expect do
      DomainSearch::GetDomain.start(%w(from_company_name Microsoft))
    end.to output("microsoft.com\n").to_stdout
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
    end.to output("Could not find domain.\n").to_stdout
  end
end
