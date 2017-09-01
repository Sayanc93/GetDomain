#!/usr/bin/env ruby
require "thor"
require "httparty"

require_relative "lib/search_helper"

module DomainSearch
  class GetDomain < Thor
    namespace :get_domain

    include SearchHelper

    VERSION = "0.0.2".freeze

    # Print current version of the CLI tool.
    # Map --version and -v to print_version without exposing the method.
    #
    map %w[--version -v] => :print_version

    desc "--version, -v", "Print the version."
    def print_version
      puts VERSION
    end

    # Takes company names as an argument with variable arity.
    # desc, long_desc and option are decorators to from_company_name method,
    # that are delegated to Thor.
    #
    desc "from_company_name <names>", "Fetch domain of the company from company names that are provided."
    long_desc <<-LONGDESC
      Fetch domain of the company from company name/names that is/are provided.

      With -f or --file option, get_domain:from_company_name -f <file_path> parses company
      names from the file and fetch/display domains of respective companies.
    LONGDESC
    option :file, type: :string, :aliases => "-f", :desc => "Read company names from the file and fetch/display their respective domains."
    option :category, type: :array, :aliases => "-c", :desc => "Company category of the company to be searched on. Eg: 'Recruiting', 'Startups', etc."
    def from_company_name(*names)
      handle_inputs_from_file(options[:file]) if options[:file]
      company_names = *names
      categories = options[:category] ? options[:category] : ["internet", "web", "services"]  # Common tags on every website, so the Jaccard's index remains same
      handle_inputs_from_terminal(company_names, categories)
    end

    private
      # Process input from file in batches of 500 lazily.
      #
      # http://patshaughnessy.net/2013/4/3/ruby-2-0-works-hard-so-you-can-be-lazy
      #
      # With the help of lazy enumeration we will load into memory company names in
      # only batches of 500 at a time, keeping in mind if the file has 1 million
      # input and we load all of it in the memory, the process might crash.
      #
      # We explored parallel processing with batches of 500 but realized threads/processes
      # shouldn't wait for IO. It defeats its purpose.
      #
      def handle_inputs_from_file file_path
        File.open(file_path) do |file|
          file.lazy.each_slice(500) do |input_lines|
            input_lines = input_lines.delete_if { |line| line == "\n" } # There can be empty lines
            iterate_over_lines_and_fetch_domain(input_lines)
          end
        end
      end

      def iterate_over_lines_and_fetch_domain(input_lines)
        input_lines.each do |input_line|
          handle_each_company_with_separate_category(input_line)
        end
      end

      def handle_each_company_with_separate_category(input_line)
        input = input_line.chomp.split(" ")
        company_name = input[0]
        categories = input[1..-1]
        request_handler = SearchHelper::Request.new(company_name)
        company_objects = request_handler.fetch_domain(categories)
        sort_and_print_results(company_name, company_objects)
      end

      # Parse company name arguments upto 20 through terminal.
      # Suggest the User to pass file as argument and make them aware of -f or --file
      # option.
      #
      def handle_inputs_from_terminal(company_names, categories)
        return suggest_file_input_for_more_inputs if company_names.size > 20
        print_domain_names(company_names, categories)
      end

      # Process array of company names as input and yield result to STDOUT.
      #
      def print_domain_names(company_names, categories)
        company_names.each do |name|
          request_handler = SearchHelper::Request.new(name)
          company_objects = request_handler.fetch_domain(categories)
          sort_and_print_results(name, company_objects)
        end
      end

      def sort_and_print_results(search_term, company_objects)
        sorted_companies = sort_companies(company_objects)

        puts "'#{search_term}' results :"
        sorted_companies.each do |company|
          puts "Name: #{company.name}, Domain: #{company.fetched_domain}, Jaccard_index: #{company.jaccard_index}, Levenstein Distance: #{company.levenstein_distance}"
        end
        puts "=========================="
      end

      # We give preference to companies with higher jaccard's index if its present.
      # If jaccard's index is not present i.e no category was supplied by user
      # we display companies with least levenstein distance with search term/company name.
      #
      def sort_companies(companies)
        companies_with_jaccard_index, companies_with_only_levenstein_percent = [], []
        companies.each do |company|
          if company.jaccard_index > 0.0
            companies_with_jaccard_index << company
          else
            companies_with_only_levenstein_percent << company
          end
        end
        sort_by_jaccard_index(companies_with_jaccard_index) + sort_by_levenstein_percent(companies_with_only_levenstein_percent)
      end

      # We sort in descending order for jaccard's index
      #
      def sort_by_jaccard_index(companies)
        companies.sort_by { |company| company.jaccard_index }.reverse
      end

      def sort_by_levenstein_percent(companies)
        companies.sort_by { |company| company.levenstein_percent }
      end

      def suggest_file_input_for_more_inputs
        "You have entered more than 20 names to fetch the domain names for. " \
        "Please consider passing a file with inputs as an argument.\n" \
        "get_domain:from_company_name -f <file_path> will yield the domains of the companies."
      end
  end
end

DomainSearch::GetDomain.start
