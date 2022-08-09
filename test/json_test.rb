# frozen_string_literal: true

require "test_helper"

# Here to make sure the thread-local variable gets set up correctly for 2.7.
PP.pp(nil, +"")

module SyntaxTree
  class JSONTest < Minitest::Test
    def test_format
      assert_equal("true\n", JSON.format("true"))
    end

    def test_visitor
      JSON.parse("[true, false, null]").accept(JSON::Visitor.new)
    end

    def test_objects
      assert_format(<<~JSON)
        {
          "foo": "bar",
          "baz": "qux",
          "quux": "corge",
          "grault": "garply",
          "waldo": "fred",
          "plugh": "xyzzy",
          "thud": "thud"
        }
      JSON
    end

    def test_arrays
      assert_format(<<~JSON)
        [
          "foo",
          "bar",
          "baz",
          "qux",
          "quux",
          "corge",
          "grault",
          "garply",
          "waldo",
          "fred",
          "plugh",
          "xyzzy",
          "thud",
          "thud"
        ]
      JSON
    end

    def test_literals
      assert_format("null\n")
      assert_format("true\n")
      assert_format("false\n")
      assert_format("\"foo\"\n")
      assert_format("1\n")
    end

    pattern = "JSONTestSuite/test_parsing/y_*.json"
    Dir[File.expand_path(pattern, __dir__)].each do |filepath|
      define_method(:"test_#{filepath}") { parse(JSON.read(filepath)) }
    end

    KNOWN_N_FAILURES = %w[
      n_string_1_surrogate_then_escape_u.json
      n_string_1_surrogate_then_escape_u1.json
      n_string_1_surrogate_then_escape_u1x.json
      n_string_1_surrogate_then_escape.json
      n_string_incomplete_escaped_character.json
      n_string_incomplete_surrogate_escape_invalid.json
      n_string_incomplete_surrogate.json
      n_string_invalid_unicode_escape.json
      n_structure_100000_opening_arrays.json
      n_structure_open_array_object.json
      n_structure_whitespace_formfeed.json
    ]

    pattern = "JSONTestSuite/test_parsing/n_*.json"
    Dir[File.expand_path(pattern, __dir__)].each do |filepath|
      define_method(:"test_#{filepath}") do
        skip if KNOWN_N_FAILURES.include?(File.basename(filepath))

        assert_raises(JSON::Parser::ParseError) do
          JSON.parse(JSON.read(filepath))
        end
      end
    end

    private

    def parse(source)
      # Test that is parses correctly
      parsed = JSON.parse(source)

      # Test that it can be formatted and pretty-printed
      PrettierPrint.format(+"") { |q| parsed.format(q) }
      parsed.accept(JSON::PrettyPrint.new(PP.new(+"", 80)))

      # Test that it can be pattern matched
      parsed in { value: { foo: :bar } }
      parsed in { value: [:foo, :bar] }

      # Return the tree so that it can be formatted
      parsed
    end

    def assert_format(source)
      parsed = parse(source)
      formatted =
        PrettierPrint.format(+"") { |q| parsed.accept(JSON::Format.new(q)) }

      assert_equal(source, formatted)
    end
  end
end
