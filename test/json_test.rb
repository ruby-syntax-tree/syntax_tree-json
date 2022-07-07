# frozen_string_literal: true

require "test_helper"

# Here to make sure the thread-local variable gets set up correctly for 2.7.
PP.pp(nil, +"")

class JSONTest < Minitest::Test
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

  private

  def assert_format(source)
    visitor = SyntaxTree::JSON::PrettyPrint.new(PP.new(+"", 80))
    SyntaxTree::JSON.parse(source).accept(visitor)

    assert_equal(source, SyntaxTree::JSON.format(source))
  end
end
