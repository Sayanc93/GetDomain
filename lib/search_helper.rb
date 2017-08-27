require_relative 'google'

module SearchHelper
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
  def make_request_and_fetch_domain(name = "")
    name = name.chomp.gsub(/\s+/, '').downcase
    query_params = { key: GOOGLE_API_KEY, q: name, num: 7, safe: "high", cx: GOOGLE_CUSTOM_SEARCH_ID }

    response = HTTParty.get(GOOGLE_SEARCH_API, query: query_params)

    domain = response.success? ? format_google_response(name, response.body) : fallback_to_clearbit_api(name)
    domain
  end

  # We have chosen 7 as the default number of results to fetch from the API
  # because in some cases News articles take precedence when the brand name is colloquial.
  # We usually return the first link but in those rare cases, we have to parse through
  # first few items before we stumble upon the correct domain.
  #
  def format_google_response(name, response_body = {})
    response = JSON(response_body)

    return response["items"].first["link"] if response["items"].first["displayLink"].include?(name)

    response = response["items"].find do |item|
                 item["link"] if item["displayLink"].include?(name)
               end
    response["link"]
  end

  # Since Google's APIs are heavily throttled and very limited in the free plan.
  # It's very likely that the API will give up when parsing though a file of huge input.
  #
  # We fallback to Clearbit's Autocomplete API which require no keys and not t
  # throttled heavily.
  #
  def fallback_to_clearbit_api(name = "")
    response = HTTParty.get(CLEARBIT_AUTOCOMPLETE_API, query: { query: name })
    info = JSON(response.body)
    response.success? && !info.empty? ? info.first["domain"] : "Could not find domain."
  end
end
