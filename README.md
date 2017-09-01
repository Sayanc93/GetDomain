# GetDomain CLI [![Code Climate](https://codeclimate.com/github/Sayanc93/GetDomain/badges/gpa.svg)](https://codeclimate.com/github/Sayanc93/GetDomain)

A Simple Ruby CLI built on top of Thor to fetch domains accurately from company names.

## Tools Used:

* **Language**: Ruby v2.3.1p112

*Depedent Gems*
* **Thor**: Thor is a simple and efficient tool for building self-documenting command line utilities

    Run `gem install thor` to install it before running the tool.

* **Parallel**: Parallel processing made simple and fast

    Run `gem install parallel` to install it before running the tool.

* **HTTParty**: HTTparty is a simple and efficient tool to handle HTTP requests.

    Run `gem install httparty` to install it before running the tool.

* **Rspec (optional)**: Behaviour Driven Development for Ruby. It is only needed if you wish to the run the tests.

    Run `gem install rspec` to install it before running the tests.

* **Webmock (optional)**: Library for stubbing and setting expectations on HTTP requests in Ruby. HTTParty is supported. It is only needed if you wish to the run the tests.

    Run `gem install webmock` to install it before running the tests.

## Execution:

There are two ways to execute the program:

* Execute `ruby get_domain.rb` or `./get_domain.rb`; if the file is denied permission for the latter, grant permission by executing `chmod +x get_domain.rb`

## Inputs:

1) It provides an interactive command prompt based shell where
commands can be typed in.

![List commands](https://monosnap.com/file/XCq84SBK5OHoqCr2biYNi3YNf2q5xW.png)

2) It accepts company names as arguments and outputs the resultant domain names on the terminal. Company name should not have spaces between them.

    Split an Atom => `invalid`

    SplitanAtom => `valid`

```ruby
./get_domain.rb from_company_name Guru -c startups saas 
```
![Terminal command](https://monosnap.com/file/NQ0YZhPi3Yjy8sNKRifXhvlGDevXLH.png)

3) Use `help` to explore further on the options of a command. `get_domain_name` also takes `File` as parameter to parse through it and output domains.

![File option](https://monosnap.com/file/eUA9weqlJG5MdhLenkFoeXn7WMcsJB.png)

![File option usage](https://monosnap.com/file/Uy88h14YFjHhr4DRAS1bNVNSNe7ls8.png)

# Note: 
`./get_domain.rb from_company_name Guru Microsoft -c startups saas ` yields both companies with similarity index based on the common categories provided.
However, if you want different category search for each company name. Use the file input.
First argument `company-name` and rest of the arguments can be `categories`. Check companies.txt for example.
