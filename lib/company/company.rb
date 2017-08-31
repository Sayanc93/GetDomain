require_relative '../algorithms/jaccard_index'
require_relative '../algorithms/levenstein_distance'

class Company

  attr_reader :name, :fetched_domain, :attributes, :jaccard_index,
              :levenstein_distance, :percent_difference

  def initialize(name = "", fetched_domain = "", attributes)
    @name = name
    @fetched_domain = fetched_domain
    @attributes = parse_attributes(attributes)
    @jaccard_index = 0.0
    @percent_difference = 0.0
  end

  # Calculates Jaccard's index from the User's search categories and the company tags fetched from API
  #
  def assign_category_jaccard_index(user_categories = [])
    @jaccard_index = Jaccard::Index.generate(attributes, user_categories)
  end

  # Calculates Levenstein Distance from the User's search term and the domain name fetched from API
  # Removes . from eg: guru-technologies.com => guru-technologiescom
  # Making sure a least Levenstein distance for each company object.
  #
  def calculate_levenstein_distance(user_search_term = "")
    domain = fetched_domain.downcase.gsub(".","")
    @levenstein_distance, @percent_difference = Levenstein::Distance.generate(domain, user_search_term)
  end

  private

    def parse_attributes(attributes)
      return [] if attributes.nil? || attributes.empty?
      tags = attributes.flat_map {|x| x.split(" ") }
      tags.map(&:downcase)
    end
end
