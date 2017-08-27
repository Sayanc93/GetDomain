require "thor"
require "httparty"

require_relative "search_helper"

class GetDomain < Thor
  include SearchHelper

  class Error < StandardError
  end

  desc "from_company_name <names>", "Fetch domain of the company from company names that are provided."
  long_desc <<-LONGDESC
    Fetch domain of the company from company name/names that is/are provided.

    With -f or --file option, get_domain:from_company_name -f <file_path> parses company
    names from the file and fetch/display domains of respective companies.
  LONGDESC
  option :file, :aliases => "-f", :desc => "Read company names from the file and fetch/display their respective domains."
  def from_company_name(*names)
    handle_inputs_from_file(options[:file]) if options[:file]
    company_names = *names
    handle_inputs_from_terminal company_names
  end

  private

    def handle_inputs_from_file file_path
      File.open(file_path) do |file|
        file.lazy.each_slice(500) do |company_names|
          process_input(company_names)
        end
      end
    end

    def handle_inputs_from_terminal(company_names)
      suggest_file_input_for_more_inputs if company_names.size > 20
      process_input(company_names)
    end

    def process_input(company_names)
      company_names.each do |name|
        domain_name = make_request_and_fetch_domain(name)
        puts domain_name
      end
    end

    def suggest_file_input_for_more_inputs
      puts "You have entered more than 20 names to fetch the domain names for. " \
           "Please consider passing a file with inputs as an argument.\n" \
           "get_domain:from_company_name -f <file_path> will yield the domains of the companies"
    end

end
