# frozen_string_literal: true

module SyntaxTree
  module JSON
    module Serialization
      # Returns the three integers corresponding to the version of this library.
      def self.version
        VERSION.split(".").map(&:to_i)
      end

      # When dumping out objects, we need an indicator of which object is coming
      # next. This module tracks those constants so they are consistent.
      module Directive
        ARRAY = "A"
        FALSE = "F"
        OBJECT = "O"
        NULL = "N"
        NUMBER = "#"
        ROOT = "R"
        STRING = "S"
        TRUE = "T"

        # This is the prefix that ensures it's quick to verify that this is a
        # validly serialized AST.
        MAGIC = "STJN"
      end

      # This class is a visitor responsible for serializing the AST to a binary
      # string.
      class Dump < Visitor
        attr_reader :output

        def initialize
          @output = StringIO.new
          @output.write([Directive::MAGIC, *Serialization.version].pack("A4 I_3"))
        end

        def dumped
          output.string
        end

        # Visit an AST::Location.
        def visit_location(location)
          output.write([location.start_offset, location.end_offset].pack("L_2"))
        end

        # Visit an AST::Array node.
        def visit_array(node)
          output.write(Directive::ARRAY)
          visit_location(node.location)

          output.write([node.values.length].pack("L_"))
          node.values.each { |value| visit(value) }
        end

        # Visit an AST::False node.
        def visit_false(node)
          output.write(Directive::FALSE)
          visit_location(node.location)
        end

        # Visit an AST::Null node.
        def visit_null(node)
          output.write(Directive::NULL)
          visit_location(node.location)
        end

        # Visit an AST::Number node.
        def visit_number(node)
          output.write(Directive::NUMBER)
          visit_location(node.location)
        end

        # Visit an AST::Object node.
        def visit_object(node)
          output.write(Directive::OBJECT)
          visit_location(node.location)

          output.write([node.values.length].pack("L_"))
          node.values.each do |key, value|
            visit(key)
            visit(value)
          end
        end

        # Visit an AST::Root node.
        def visit_root(node)
          output.write(Directive::ROOT)
          visit_location(node.location)

          visit(node.value)
        end

        # Visit an AST::String node.
        def visit_string(node)
          output.write(Directive::STRING)
          visit_location(node.location)
        end

        # Visit an AST::True node.
        def visit_true(node)
          output.write(Directive::TRUE)
          visit_location(node.location)
        end
      end

      # This class is responsible for taking a source string and the serialized
      # AST representation and reifying the AST.
      class Load
        attr_reader :source, :dumped

        def initialize(source, dumped)
          @source = source
          @dumped = StringIO.new(dumped)
        end

        def loaded
          major, minor, patch = Serialization.version
          dumped.read(16).unpack("A4 I_3") => [Directive::MAGIC, ^major, ^minor, ^patch]

          commands = [:unpack_root]
          values = []

          while (command = commands.pop)
            case command
            in :unpack_root
              dumped.read(17).unpack("A L_2") => [^(Directive::ROOT), start_offset, end_offset]
              location = AST::Location.new(start_offset, end_offset)
              commands += [[:pack_root, location], :unpack_value]
            in :unpack_value
              dumped.read(17).unpack("A L_2") => [type, start_offset, end_offset]
              location = AST::Location.new(start_offset, end_offset)

              case type
              in Directive::ARRAY
                dumped.read(8).unpack1("L_") => length
                commands << [:pack_array, length, location]
                commands += length.times.map { :unpack_value }
              in Directive::FALSE
                values << AST::False.new(location: location)
              in Directive::NULL
                values << AST::Null.new(location: location)
              in Directive::NUMBER
                values << AST::Number.new(value: source[location.to_range], location: location)
              in Directive::OBJECT
                dumped.read(8).unpack1("L_") => length
                commands << [:pack_object, length, location]
                commands += (length * 2).times.map { :unpack_value }
              in Directive::STRING
                values << AST::String.new(value: source[location.to_range], location: location)
              in Directive::TRUE
                values << AST::True.new(location: location)
              end
            in [:pack_array, length, location]
              values << AST::Array.new(values: values.pop(length), location: location)
            in [:pack_object, length, location]
              values << AST::Object.new(values: values.pop(length * 2).each_slice(2).to_a, location: location)
            in [:pack_root, location]
              values << AST::Root.new(value: values.pop, location: location)
            end
          end

          values => [AST::Root => value]
          value
        end
      end
    end
  end
end
