# frozen_string_literal: true

require "test_helper"

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
    assert_equal(SyntaxTree::JSON.format(source), source)
  end
end
