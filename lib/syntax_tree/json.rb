# frozen_string_literal: true

require "prettier_print"
require "syntax_tree"

require_relative "json/ast"
require_relative "json/parser"
require_relative "json/version"
require_relative "json/visitor"

require_relative "json/format"
require_relative "json/pretty_print"

module SyntaxTree
  module JSON
    class << self
      def format(source, maxwidth = 80)
        PrettierPrint.format(+"", maxwidth) do |q|
          parse(source).accept(Format.new(q))
        end
      end

      def parse(source)
        Parser.new(source).parse
      end

      def read(filepath)
        File.read(filepath)
      end
    end
  end

  register_handler(".json", JSON)
end
