# frozen_string_literal: true

module SyntaxTree
  module JSON
    module AST
      # This is the location of the AST node in the source string.
      class Location
        attr_reader :start_offset, :end_offset

        def initialize(start_offset, end_offset)
          @start_offset = start_offset
          @end_offset = end_offset
        end

        def deconstruct_keys(keys)
          { start_offset: start_offset, end_offset: end_offset }
        end

        def to(other)
          Location.new(start_offset, other.end_offset)
        end

        def to_range
          start_offset...end_offset
        end

        def ==(other)
          other in Location[
            start_offset: ^(start_offset), end_offset: ^(end_offset)
          ]
        end
      end

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
        attr_reader :values, :location

        def initialize(values:, location:)
          @values = values
          @location = location
        end

        def accept(visitor)
          visitor.visit_array(self)
        end

        def child_nodes
          values
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { values: values, location: location }
        end

        def ==(other)
          other in Array[values: ^(values), location: ^(location)]
        end
      end

      # This represents a false in the tree.
      class False < Node
        attr_reader :location

        def initialize(location:)
          @location = location
        end

        def accept(visitor)
          visitor.visit_false(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { location: location }
        end

        def ==(other)
          other in False[location: ^(location)]
        end
      end

      # This represents a null in the tree.
      class Null < Node
        attr_reader :location

        def initialize(location:)
          @location = location
        end

        def accept(visitor)
          visitor.visit_null(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { location: location }
        end

        def ==(other)
          other in Null[location: ^(location)]
        end
      end

      # This represents a number in the tree.
      class Number < Node
        attr_reader :value, :location

        def initialize(value:, location:)
          @value = value
          @location = location
        end

        def accept(visitor)
          visitor.visit_number(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { value: value, location: location }
        end

        def ==(other)
          other in Number[value: ^(value), location: ^(location)]
        end
      end

      # This represents an object in the tree.
      class Object < Node
        attr_reader :values, :location

        def initialize(values:, location:)
          @values = values
          @location = location
        end

        def accept(visitor)
          visitor.visit_object(self)
        end

        def child_nodes
          values.map(&:last)
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { values: values, location: location }
        end

        def ==(other)
          other in Object[values: ^(values), location: ^(location)]
        end
      end

      # This is the top of the JSON syntax tree.
      class Root < Node
        attr_reader :value, :location

        def initialize(value:, location:)
          @value = value
          @location = location
        end

        def accept(visitor)
          visitor.visit_root(self)
        end

        def child_nodes
          [value]
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { value: value, location: location }
        end

        def ==(other)
          other in Root[value: ^(value), location: ^(location)]
        end
      end

      # This represents a string in the tree.
      class String < Node
        attr_reader :value, :location

        def initialize(value:, location:)
          @value = value
          @location = location
        end

        def accept(visitor)
          visitor.visit_string(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { value: value, location: location }
        end

        def ==(other)
          other in String[value: ^(value), location: ^(location)]
        end
      end

      # This represents a true in the tree.
      class True < Node
        attr_reader :location

        def initialize(location:)
          @location = location
        end

        def accept(visitor)
          visitor.visit_true(self)
        end

        def child_nodes
          []
        end

        alias deconstruct child_nodes

        def deconstruct_keys(keys)
          { location: location }
        end

        def ==(other)
          other in True[location: ^(location)]
        end
      end
    end
  end
end
