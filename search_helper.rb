require_relative 'google'

module SearchHelper

  def make_request_and_fetch_domain(name = "")
    name = name.chomp.gsub(/\s+/, '')
    query_params = { key: GOOGLE_API_KEY, q: name, num: 7, safe: "high", cx: GOOGLE_CUSTOM_SEARCH_ID }

    response = HTTParty.get(GOOGLE_SEARCH_API, query: query_params)

    domain = response.success? ? format_google_response(name, response.body) : fallback_to_clearbit_api(name)
    domain
  end

  def format_google_response(name, response_body = {})
    response = JSON(response_body)
    return response["items"].first["link"] if response["items"].first["displayLink"].include?(name.downcase)
    response = response["items"].find do |item|
                item["link"] if item["displayLink"].include?(name)
               end
    response["link"]
  end

  def fallback_to_clearbit_api(name = "")
    response = HTTParty.get(CLEARBIT_AUTOCOMPLETE_API, query: { query: name })

    response.success? && !response.empty? ? response.first["domain"] : "Could not find domain."
  end
end
