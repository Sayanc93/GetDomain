#!/usr/bin/env ruby
require "thor"
require "httparty"

require_relative "lib/search_helper"

module DomainSearch
  class GetDomain < Thor
    namespace :get_domain

    include SearchHelper

    VERSION = "0.0.1".freeze

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
    option :file, :aliases => "-f", :desc => "Read company names from the file and fetch/display their respective domains."
    def from_company_name(*names)
      handle_inputs_from_file(options[:file]) if options[:file]
      company_names = *names
      handle_inputs_from_terminal(company_names)
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
          file.lazy.each_slice(500) do |company_names|
            print_domain_names(company_names)
          end
        end
      end

      # Parse company name arguments upto 20 through terminal.
      # Suggest the User to pass file as argument and make them aware of -f or --file
      # option.
      #
      def handle_inputs_from_terminal(company_names)
        return suggest_file_input_for_more_inputs if company_names.size > 20
        print_domain_names(company_names)
      end

      # Process array of company names as input and yield result to STDOUT.
      #
      def print_domain_names(company_names)
        company_names.each do |name|
          domain_name = make_request_and_fetch_domain(name)
          puts domain_name
        end
      end

      def suggest_file_input_for_more_inputs
        "You have entered more than 20 names to fetch the domain names for. " \
        "Please consider passing a file with inputs as an argument.\n" \
        "get_domain:from_company_name -f <file_path> will yield the domains of the companies."
      end
  end
end

DomainSearch::GetDomain.start
