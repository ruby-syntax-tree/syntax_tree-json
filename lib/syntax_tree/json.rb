# frozen_string_literal: true

require "json"
require "prettier_print"
require "syntax_tree"

require_relative "json/version"

module SyntaxTree
  module JSON
    # This is always the root of the syntax tree.
    class RootNode < Struct.new(:object)
      def format(q)
        object.format(q)
        q.breakable(force: true)
      end

      def pretty_print(q)
        q.group(2, "(root", ")") do
          q.breakable
          q.text("object=")
          q.pp(object)
        end
      end
    end

    # This contains an object node. The values argument to the struct is a hash.
    class ObjectNode < Struct.new(:values)
      def format(q)
        q.group do
          q.text("{")

          q.indent do
            q.breakable
            q.seplist(values, nil, :each_pair) do |key, value|
              q.group do
                q.text(key.to_json)
                q.text(": ")
                value.format(q)
              end
            end
          end

          q.breakable
          q.text("}")
        end
      end

      def pretty_print(q)
        q.group(2, "(object", ")") do
          q.breakable
          q.text("values=")
          q.pp(values)
        end
      end
    end

    # This contains an array node. The values argument to the struct is an
    # array.
    class ArrayNode < Struct.new(:values)
      def format(q)
        q.group do
          q.text("[")

          q.indent do
            q.breakable("")
            q.seplist(values) { |value| value.format(q) }
          end

          q.breakable("")
          q.text("]")
        end
      end

      def pretty_print(q)
        q.group(2, "(array", ")") do
          q.breakable
          q.text("values=")
          q.pp(values)
        end
      end
    end

    # This contains a literal node. The value argument to the struct is a
    # literal value like a string, number, or boolean.
    class LiteralNode < Struct.new(:value)
      def format(q)
        q.text(value.to_json)
      end

      def pretty_print(q)
        q.group(2, "(literal", ")") do
          q.breakable
          q.text("value=")
          q.text(value.inspect)
        end
      end
    end

    class << self
      def format(source, maxwidth = 80)
        formatter = PrettierPrint.new([], maxwidth)
        parse(source).format(formatter)

        formatter.flush
        formatter.output.join
      end

      def parse(source)
        RootNode.new(translate(::JSON.parse(source)))
      end

      def read(filepath)
        File.read(filepath)
      end

      private

      def translate(object)
        case object
        when Hash
          ObjectNode.new(object.to_h { |key, value| [key, translate(value)] })
        when Array
          ArrayNode.new(object.map { |value| translate(value) })
        else
          LiteralNode.new(object)
        end
      end
    end
  end

  register_handler(".json", JSON)
end
