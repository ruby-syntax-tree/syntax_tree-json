# frozen_string_literal: true

require_relative "lib/syntax_tree/json/version"

Gem::Specification.new do |spec|
  spec.name = "syntax_tree-json"
  spec.version = SyntaxTree::JSON::VERSION
  spec.authors = ["Kevin Newton"]
  spec.email = ["kddnewton@gmail.com"]

  spec.summary = "Syntax Tree support for JSON"
  spec.homepage = "https://github.com/ruby-syntax-tree/syntax_tree-json"
  spec.license = "MIT"
  spec.metadata = { "rubygems_mfa_required" => "true" }

  spec.files =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0")
        .reject { |f| f.match(%r{^(test|spec|features)/}) }
    end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "prettier_print"
  spec.add_dependency "syntax_tree", ">= 2.0.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
end
