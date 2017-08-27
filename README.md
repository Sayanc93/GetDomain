# GetDomain CLI

## Tools Used:

* **Language**: Ruby v2.3.1p112

*Depedent Gems*
* **Thor**: Thor is a simple and efficient tool for building self-documenting command line utilities

    Run `gem install thor` to install it before running the tool.

* **Rspec (optional)**: Behaviour Driven Development for Ruby. It is only needed if you wish to the run the tests.

    Run `gem install rspec` to install it before running the tests.

* **Webmock (optional)**: Library for stubbing and setting expectations on HTTP requests in Ruby. HTTParty is supported. It is only needed if you wish to the run the tests.

    Run `gem install webmock` to install it before running the tests.

## Execution:

There are two ways to execute the program:

* Execute `ruby get_domain.rb` or `./get_domain.rb -f file_inputs.txt`; if the file is denied permission for the latter, grant permission by executing `chmod +x get_domain.rb`

## Inputs:

1) It provides an interactive command prompt based shell where
commands can be typed in.

![List commands](https://monosnap.com/file/hoC8RTUFyhDlcPCbMMg1fSL9hYWfw1.png)

2) It accepts company names as arguments and outputs the resultant domain names on the terminal. Company name should not have spaces between them. 

    Split an Atom => invalid
    
    SplitanAtom => valid

![Terminal command](https://monosnap.com/file/vNfzFoVp4KKn7Qxflgk4Nk8hvdDgnY.png)

3) Use `help` to explore further on the options of a command. `get_domain_name` also takes `File` as parameter to parse through it and output domains.

![File option](https://monosnap.com/file/eUA9weqlJG5MdhLenkFoeXn7WMcsJB.png)

![File option usage](https://monosnap.com/file/J3isNmbtE1juZuPTHVODS8BzoO62Fx.png)
