# frozen_string_literal: true

module SyntaxTree
  module JSON
    # This is the parent class of any visitors for this AST.
    class Visitor
      def visit(node)
        node&.accept(self)
      end

      def visit_all(nodes)
        nodes.map { |node| visit(node) }
      end

      def visit_child_nodes(node)
        visit_all(node.child_nodes)
      end

      # Visit an AST::Array node.
      alias visit_array visit_child_nodes

      # Visit an AST::False node.
      alias visit_false visit_child_nodes

      # Visit an AST::Null node.
      alias visit_null visit_child_nodes

      # Visit an AST::Number node.
      alias visit_number visit_child_nodes

      # Visit an AST::Object node.
      alias visit_object visit_child_nodes

      # Visit an AST::Root node.
      alias visit_root visit_child_nodes

      # Visit an AST::String node.
      alias visit_string visit_child_nodes

      # Visit an AST::True node.
      alias visit_true visit_child_nodes
    end
  end
end
