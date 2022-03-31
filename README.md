# SyntaxTree::JSON

[![Build Status](https://github.com/ruby-syntax-tree/syntax_tree-json/actions/workflows/main.yml/badge.svg)](https://github.com/ruby-syntax-tree/syntax_tree-json/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/syntax_tree-json.svg)](https://rubygems.org/gems/syntax_tree-json)

[Syntax Tree](https://github.com/ruby-syntax-tree/syntax_tree) support for JSON.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "syntax_tree-json"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install syntax_tree-json

## Usage

From code:

```ruby
require "syntax_tree/json"

pp SyntaxTree::JSON.parse(source) # print out the AST
puts SyntaxTree::JSON.format(source) # format the AST
```

From the CLI:

```sh
$ stree ast --plugins=json file.json
(root object=(object values={"Hello"=>(literal value="world!")}))
```

or

```sh
$ stree format --plugins=json file.json
{ "Hello": "world!" }
```

or

```sh
$ stree write --plugins=json file.json
file.json 1ms
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby-syntax-tree/syntax_tree-json.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
