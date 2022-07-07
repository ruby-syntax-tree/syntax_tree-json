# frozen_string_literal: true

module SyntaxTree
  module JSON
    # This class is a visitor responsible for pretty-printing the AST.
    class PrettyPrint < Visitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      # Visit an AST::Array node.
      def visit_array(node)
        group("array") { field("values", node.values) }
      end

      # Visit an AST::False node.
      def visit_false(node)
        q.text("false")
      end

      # Visit an AST::Null node.
      def visit_null(node)
        q.text("null")
      end

      # Visit an AST::Number node.
      def visit_number(node)
        group("number") { field("value", node.value) }
      end

      # Visit an AST::Object node.
      def visit_object(node)
        group("object") { field("values", node.values) }
      end

      # Visit an AST::Root node.
      def visit_root(node)
        group("root") { field("value", node.value) }
      end

      # Visit an AST::String node.
      def visit_string(node)
        group("string") { field("value", node.value) }
      end

      # Visit an AST::True node.
      def visit_true(node)
        q.text("true")
      end

      private

      def field(name, value)
        q.breakable
        q.text("#{name}=")
        q.pp(value)
      end

      def group(name)
        q.group do
          q.text("(#{name}")
          q.nest(2) { yield }
          q.breakable("")
          q.text(")")
        end
      end
    end
  end
end
