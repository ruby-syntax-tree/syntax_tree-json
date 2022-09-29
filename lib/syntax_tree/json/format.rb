# frozen_string_literal: true

module SyntaxTree
  module JSON
    # This class is a visitor responsible for formatting the AST.
    class Format < Visitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      # Visit an AST::Array node.
      def visit_array(node)
        q.group do
          q.text("[")

          q.indent do
            q.breakable("")
            q.seplist(node.values) { |value| visit(value) }
          end

          q.breakable("")
          q.text("]")
        end
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
        q.text(node.value)
      end

      # Visit an AST::Object node.
      def visit_object(node)
        q.group do
          q.text("{")

          q.indent do
            q.breakable
            q.seplist(node.values) do |(key, value)|
              q.group do
                visit(key)
                q.text(": ")
                visit(value)
              end
            end
          end

          q.breakable
          q.text("}")
        end
      end

      # Visit an AST::Root node.
      def visit_root(node)
        visit(node.value)
        q.breakable(force: true)
      end

      # Visit an AST::String node.
      def visit_string(node)
        q.text(node.value)
      end

      # Visit an AST::True node.
      def visit_true(node)
        q.text("true")
      end
    end
  end
end
