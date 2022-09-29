# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "syntax_tree/rake_tasks"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

SOURCE_FILES =
  FileList[
    %w[Gemfile Rakefile syntax_tree-json.gemspec lib/**/*.rb test/*.rb]
  ] - ["lib/syntax_tree/json/serialization.rb"]

SyntaxTree::Rake::CheckTask.new { |t| t.source_files = SOURCE_FILES }
SyntaxTree::Rake::WriteTask.new { |t| t.source_files = SOURCE_FILES }

task default: :test
