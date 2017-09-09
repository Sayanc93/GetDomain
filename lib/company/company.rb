require_relative '../algorithms/jaccard_index'
require_relative '../algorithms/levenstein_distance'
require_relative '../secret'

require 'mechanize'
require 'koala'

class Company

  attr_reader :name, :fetched_domain, :attributes, :jaccard_index,
              :levenstein_distance, :user_categories,
              :score

  # Scores for the domain if it has associated official social networks pages
  SCORE = { facebook: 10, twitter: 10, google: 25, linkedin: 60, jobs: 30, blog: 40 }

  def initialize(domain = "", user_categories = nil)
    @fetched_domain = domain
    @user_categories = parse_attributes(user_categories)
    @jaccard_index = 0.0
    @score = 0.0
    @pages = {}
  end

  # Assigns similarity values like levenstein distance and jaccard's index in this block
  #
  def calculate_similarity(user_search_term = nil)
    assign_category_jaccard_score unless user_categories.empty?
    assign_score_for_relevant_work_links
    assign_levenstein_score(user_search_term)
  end

  # Assigns cumulative scores based on how many official pages it has + the number of followers it garners.
  #
  def assign_score_for_relevant_work_links
    agent = Mechanize.new { |mech_agent|
              mech_agent.open_timeout   = 5
              mech_agent.read_timeout   = 5
             }
    page = agent.get("http://" + fetched_domain)
    network_score = analyze_domain_network(page)
    social_score = analyze_social_metrics(agent)
    @score += network_score + social_score
  end

  # Assign scores for each page with respect to the SCORE hash for each social network. Returns integer.
  #
  def analyze_domain_network(page)
    get_relevant_pages(page)
    @pages.inject(0) { |score, (key, _value)| score + @pages[key].nil? ? 0 : SCORE[key] }
  end

  # Assign score for the number of followers it garners on its linked social accounts. TO DO: LinkedIn scraping.
  #
  def analyze_social_metrics(agent)
    twitter_followers = @pages[:twitter].nil? ? 0 : get_twitter_follower_count(agent)
    google_followers = @pages[:google].nil? ? 0 : get_google_follower_count(agent)
    facebook_likes = @pages[:facebook].nil? ? 0 : get_facebook_likes_count
    twitter_score(twitter_followers) + google_score(google_followers) + facebook_score(facebook_likes)
  end

  # Calculates Levenstein Distance from the User's company and the domain name fetched from API.
  # Making sure a least Levenstein distance for each company object.
  # So guru-technologies.com will have larger LD than guru.com or getguru.com.
  # As such websites closer to the search term will be preferrred.
  # If LD is same for domains, google's SEO is already preferred
  #
  def assign_levenstein_score(user_search_term = "")
    domain = fetched_domain.downcase.split(".")[0]
    levenstein_distance = Levenstein::Distance.generate(user_search_term, domain)
    @score -= levenstein_distance
  end

  # Calculates Jaccard's index from the User's search categories and the company tags fetched from API
  #
  def assign_category_jaccard_score
    company_information = get_company_info_from_fullcontact
    organization_info = company_information["organization"]
    @attributes = parse_attributes(organization_info["keywords"])
    @name = organization_info["name"]
    jaccard_index = Jaccard::Index.generate(attributes, user_categories)
    @score += jaccard_index * 10
  end

  private

    def parse_attributes(attributes)
      return [] if attributes.nil? || attributes.empty?   # Tags can be nil for certain companies
      tags = attributes.flat_map {|x| x.split(" ") }
      tags.map(&:downcase)
    end

    # Gets information from FullContact's lookup by domain API for companies.
    #
    def get_company_info_from_fullcontact
      response = HTTParty.get(FULLCONTACT_LOOKUP_API, query: { "domain" => fetched_domain,
                                                               "apiKey" => FULLCONTACT_API_KEY })
      response = response.success? ? JSON(response.body) : raise("Could not get information from FullContact, check rate limit.")
      raise "FullContact retry error" if response["status"] == 202 # FullContact queues for search sometimes.
      response
    end

    def get_relevant_pages(page)
      @pages[:twitter] = page.link_with(href: /twitter.com/)
      @pages[:google] = page.link_with(href: /plus.google.com/i)
      @pages[:facebook] = page.link_with(href: /facebook.com/i)
      @pages[:linkedin] = page.link_with(href: /www.linkedin.com/i)
      @pages[:blog] = page.link_with(href: /blog/i)
      @pages[:jobs] = page.link_with(href: /jobs/i)
      @pages
    end

    def get_twitter_follower_count(agent)
      twitter_page = agent.get(@pages[:twitter].href)
      followers = twitter_page.link_with(text: /followers/i).text
      follower_count = followers.scan(/\d/).join
      follower_count.to_i
    end

    def get_google_follower_count(agent)
      google_page = agent.get(@pages[:google].href)
      followers = google_page.search("div.IGqcid").children[1].text
      follower_count = followers.scan(/\d/).join
      follower_count.to_i
    end

    # Fetched facebook likes with respect to facebook page fetched with Graph API.
    def get_facebook_likes_count
      graph = Koala::Facebook::API.new(FACEBOOK_OAUTH_TOKEN)
      fb_page_id = @pages[:facebook].href.split('/').last
      number_of_likes = begin
                          id = graph.get_object(fb_page_id)["id"]
                          graph.get_object(id + "?fields=likes")["likes"]
                        rescue
                          0
                        end
      number_of_likes
    end

    def twitter_score(followers)
      return 0 if followers == 0

      if followers.between?(1, 500)
        2
      elsif followers.between?(500, 2000)
        20
      elsif followers.between?(2000, 6000)
        30
      elsif followers > 6000
        50
      end
    end

    def google_score(followers)
      return 0 if followers == 0

      if followers.between?(1, 300)
        4
      elsif followers.between?(300, 600)
        20
      elsif followers.between?(600, 2000)
        40
      elsif followers > 2000
        50
      end
    end

    def facebook_score(likes)
      return 0 if likes == 0

      if likes.between?(1, 700)
        4
      elsif likes.between?(700, 1500)
        20
      elsif likes.between?(1500,3000)
        40
      elsif likes > 3000
        50
      end
    end
end
