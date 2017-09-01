require_relative "../get_domain"

describe 'GetDomain CLI class Tests' do

  it 'should print the correct version of the CLI' do
    expected_version_number = "0.0.2\n"

    expect do
      DomainSearch::GetDomain.start(['-v'])
    end.to output(expected_version_number).to_stdout
  end

  it 'should print suggestion to use file input when passed more than 20 arguments' do
    expected_message = "You have entered more than 20 names to fetch the domain names for. "\
                       "Please consider passing a file with inputs as an argument.\n"\
                       "get_domain:from_company_name -f <file_path> will yield the domains of "\
                       "the companies."

    overloaded_arguments = ["Microsoft"] * 21
    modified_arguments = overloaded_arguments.unshift("from_company_name")

    expect(DomainSearch::GetDomain.start(modified_arguments)).to eq(expected_message)
  end
end
