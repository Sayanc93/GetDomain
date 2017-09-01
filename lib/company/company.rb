require_relative '../algorithms/jaccard_index'
require_relative '../algorithms/levenstein_distance'

class Company

  attr_reader :name, :fetched_domain, :attributes, :jaccard_index,
              :levenstein_distance, :levenstein_percent

  def initialize(name = "", fetched_domain = "", attributes)
    @name = name
    @fetched_domain = fetched_domain
    @attributes = parse_attributes(attributes)
    @jaccard_index = 0.0
    @levenstein_percent = 0.0
  end

  # Calculates Jaccard's index from the User's search categories and the company tags fetched from API
  #
  def assign_category_jaccard_index(user_categories = [])
    @jaccard_index = Jaccard::Index.generate(attributes, user_categories)
  end

  # Calculates Levenstein Distance from the User's company and the domain name fetched from API.
  # Making sure a least Levenstein distance for each company object.
  # So guru-technologies.com will have larger LD than guru.com or getguru.com.
  # As such websites closer to the search term will be preferrred.
  # If LD is same for domains, google's SEO is already preferred
  #
  def calculate_levenstein_distance(user_search_term = "")
    domain = fetched_domain.downcase.split(".")[0]
    @levenstein_distance, @levenstein_percent = Levenstein::Distance.generate(user_search_term, domain)
  end

  private

    def parse_attributes(attributes)
      return [] if attributes.nil? || attributes.empty?   # Tags can be nil for certain companies
      tags = attributes.flat_map {|x| x.split(" ") }
      tags.map(&:downcase)
    end
end
