# frozen_string_literal: true

module SyntaxTree
  module JSON
    module AST
      # This is the parent node of all of the nodes in the AST.
      class Node
        def format(q)
          accept(Format.new(q))
        end

        def pretty_print(q)
          accept(PrettyPrint.new(q))
        end
      end

      # This represents an array in the tree.
      class Array < Node
        attr_reader :values

        def initialize(values:)
          @values = values
        end

        def accept(visitor)
          visitor.visit_array(self)
        end

        def child_nodes
          values
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { values: values }
        end
      end

      # This represents a false in the tree.
      class False < Node
        def accept(visitor)
          visitor.visit_false(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          {}
        end
      end

      # This represents a null in the tree.
      class Null < Node
        def accept(visitor)
          visitor.visit_null(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          {}
        end
      end

      # This represents a number in the tree.
      class Number < Node
        attr_reader :value

        def initialize(value:)
          @value = value
        end

        def accept(visitor)
          visitor.visit_number(self)
        end

        def child_nodes
          []
        end

        alias deconstruct value

        def deconstruct_keys(keys)
          { value: value }
        end
      end

      # This represents an object in the tree.
      class Object < Node
        attr_reader :values

        def initialize(values:)
          @values = values
        end

        def accept(visitor)
          visitor.visit_object(self)
        end

        def child_nodes
          values.values
        end

        alias deconstruct values

        def deconstruct_keys(keys)
          { values: values }
        end
      end

      # This is the top of the JSON syntax tree.
      class Root < Node
        attr_reader :value

        def initialize(value:)
          @value = value
        end

        def accept(visitor)
          visitor.visit_root(self)
        end

        def child_nodes
          [value]
        end

        alias deconstruct value

        def deconstruct_keys(keys)
          { value: value }
        end
      end

      # This represents a string in the tree.
      class String < Node
        attr_reader :value

        def initialize(value:)
          @value = value
        end

        def accept(visitor)
          visitor.visit_string(self)
        end

        def child_nodes
          []
        end

        alias deconstruct value

        def deconstruct_keys(keys)
          { value: value }
        end
      end

      # This represents a true in the tree.
      class True < Node
        def accept(visitor)
          visitor.visit_true(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          {}
        end
      end
    end
  end
end
