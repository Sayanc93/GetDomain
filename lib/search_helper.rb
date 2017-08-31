require_relative 'secret'
require_relative 'company/company'
require 'parallel'

module SearchHelper
  # Take company name given by user as parameter and category as attributes
  # Fetches all similar domains from APIs and retrieves tags on them, compares their relevance
  # and outputs the company objects with all relevant information.
  #
  def make_request_and_fetch_domain(name = "", attributes)
    name = name.chomp.gsub(/\s+/, '').downcase # remove space in search term and downcase.
    attributes = attributes.map(&:downcase)

    companies = get_domains_from_name(name, attributes)
    companies
  end

  # Fetches all similar domain from Google and Clearbit in parallel processes.
  # Creates company profile with jaccard index to calculate similarity with respect to tags & category
  #
  def get_domains_from_name(name = "", attributes)
    all_domains = fetch_domains_in_parallel(name).flatten
    all_similar_domains = (all_domains).uniq
    company_objects = create_company_profiles(all_similar_domains)
    calculate_similarity(company_objects, name, attributes)
    company_objects
  end

  def fetch_domains_in_parallel(name = "")
    Parallel.map(1..2, in_processes: 2, progress: "Fetching domains", isolated: true) do |_|
      from_google = fetch_domain_names_from_google(name)
      from_clearbit = fetch_domain_names_from_clearbit(name)
      from_google + from_clearbit
    end
  end

  def calculate_similarity(company_objects, name, attributes)
    company_objects.each do |company|
      company.assign_category_jaccard_index(attributes)
      company.calculate_levenstein_distance(name)
    end
    company_objects
  end

  # Since popular companies optimize for SEO, it made sense to use Google's Search API.
  # Although, Clearbit's API is more suited for the job, it depended on if Clearbit
  # had a record of the company in their database.
  #
  # Google Search API provides 100 search queries per day for free, so we fallback
  # to Clearbit's Autocomplete API which doesn't require any keys and is not heavily
  # throttled.
  # We are using Google's Custom Search API v7 with the tweak of searching the entire web.
  #
  # cx => Custom search ID
  # safe => Safe search moderation
  # num => number of results to fetch
  #
  # We have chosen 7 as the default number of results to fetch from the API
  # because in some cases News articles take precedence when the brand name is colloquial.
  # We usually return the first link but in those rare cases, we have to parse through
  # first few items before we stumble upon the correct domain.
  #
  def fetch_domain_names_from_google(name = "")
    query_params = { key: GOOGLE_API_KEY, q: name, num: 7, safe: "high", cx: GOOGLE_CUSTOM_SEARCH_ID }
    response = HTTParty.get(GOOGLE_SEARCH_API, query: query_params)
    if response.success?
      response = JSON(response.body)
      response = response["items"].select do |item|
                   item["link"] if item["displayLink"].include?(name)
                 end
      response.map { |item| convert_link_to_domain(item["link"]) }
    else
      [] # return empty array, so that this block doesn't fail and we fallback to Clearbit API for domains.
    end
  end

  # Since Google's APIs are heavily throttled and very limited in the free plan.
  # It's very likely that the API will give up when parsing though a file of huge input.
  #
  # We fallback to Clearbit's Autocomplete API which require no keys and not t
  # throttled heavily.
  #
  def fetch_domain_names_from_clearbit(name = "")
    response = HTTParty.get(CLEARBIT_AUTOCOMPLETE_API, query: { query: name })
    info = JSON(response.body)
    if response.success? && !info.empty?
      domains = info.map { |item| item["domain"] }
    end
    domains
  end

  private

    def create_company_profiles(domains)
      company_objects = []
      domains.each do |domain|
        company_information = get_company_info_from_fullcontact(domain)
        organization_info = company_information["organization"]   # Organization name
        attributes = organization_info["keywords"]                # Tags about company from FullContact.
        company_objects << Company.new(organization_info["name"], domain, attributes)
      end
      company_objects
    end

    def get_company_info_from_fullcontact(domain = "")
      response = HTTParty.get(FULLCONTACT_LOOKUP_API, query: { "domain" => domain,
                                                               "apiKey" => FULLCONTACT_API_KEY })
      response.success? ? JSON(response.body) : raise("Could not get information from FullContact.")
    end

    # Remove www. from google links to resemble clearbit output and have congruency in dataset.
    #
    def convert_link_to_domain(link = "")
      URI.parse(link).host.sub("www.", "")
    end
end
