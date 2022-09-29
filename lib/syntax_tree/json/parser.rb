# frozen_string_literal: true

module SyntaxTree
  module JSON
    # This class is responsible for converting from a plain string input into
    # an AST.
    class Parser
      class ParseError < StandardError
      end

      attr_reader :source

      def initialize(source)
        @source = source
      end

      def parse
        if parse_item(make_tokens) in [value, []]
          location = AST::Location.new(0, source.length)
          AST::Root.new(value: value, location: location)
        else
          raise ParseError, "unexpected tokens after value"
        end
      end

      private

      # This represents a parsed token from the source.
      class Token
        attr_reader :type, :location, :value

        def initialize(type:, location:, value: nil)
          @type = type
          @location = location
          @value = value
        end

        def deconstruct_keys(keys)
          { type: type, location: location, value: value }
        end
      end

      def make_tokens
        buffer = source.dup.force_encoding("UTF-8")
        raise ParseError, "invalid UTF-8" unless buffer.valid_encoding?

        tokens = []
        offset = 0

        buffer.gsub!(/\A\s+/, "")
        offset += $&.length if $&

        until buffer.empty?
          tokens << case buffer
          in /\A[\{\}\[\],:]/
            location = AST::Location.new(offset, offset + $&.length)
            Token.new(type: $&.to_sym, location: location)
          in /\A-?(0|[1-9]\d*)(\.\d+)?([Ee][-+]?\d+)?/
            location = AST::Location.new(offset, offset + $&.length)
            Token.new(type: :number, location: location, value: $&)
          in %r{\A"[^"\\\t\n\x00]*(?:\\[bfnrtu\\/"][^"\\]*)*"}
            location = AST::Location.new(offset, offset + $&.length)
            Token.new(type: :string, location: location, value: $&)
          in /\Atrue/
            location = AST::Location.new(offset, offset + $&.length)
            Token.new(type: :true, location: location)
          in /\Afalse/
            location = AST::Location.new(offset, offset + $&.length)
            Token.new(type: :false, location: location)
          in /\Anull/
            location = AST::Location.new(offset, offset + $&.length)
            Token.new(type: :null, location: location)
          else
            raise ParseError, "unexpected token: #{buffer[0]}"
          end

          offset += $&.length
          buffer = $'.gsub(/\A\s+/, "")
          offset += $&.length if $&
        end

        tokens
      end

      def parse_array(tokens, start_location)
        values = []

        loop do
          value, tokens = parse_item(tokens)
          values << value

          case tokens
          in [Token[type: :"]", location: end_location], *rest]
            location = start_location.to(end_location)
            return AST::Array.new(values: values, location: location), rest
          in [Token[type: :","], *rest]
            tokens = rest
          else
            raise ParseError, "expected ',' or ']' after array value"
          end
        end
      end

      def parse_object(tokens, start_location)
        values = []

        loop do
          # stree-ignore
          if tokens in [{ type: :string, value: key_value, location: key_location }, { type: :":" }, *tokens]
            value, tokens = parse_item(tokens)
            values << [
              AST::String.new(value: key_value, location: key_location),
              value
            ]

            case tokens
            in [{ type: :"}", location: end_location }, *rest]
              location = start_location.to(end_location)
              return AST::Object.new(values: values, location: location), rest
            in [{ type: :"," }, *rest]
              tokens = rest
            else
              raise ParseError, "expected ',' or '}' after object value"
            end
          else
            raise ParseError, "expected key and ':' after opening '{'"
          end
        end
      end

      def parse_item(tokens)
        # stree-ignore
        case tokens
        in [{ type: :"[", location: start_location }, { type: :"]", location: end_location }, *rest]
          [
            AST::Array.new(
              values: [],
              location: start_location.to(end_location)
            ),
            rest
          ]
        in [{ type: :"[", location: start_location }, *rest]
          parse_array(rest, start_location)
        in [{ type: :"{", location: start_location }, { type: :"}", location: end_location }, *rest]
          [
            AST::Object.new(
              values: [],
              location: start_location.to(end_location)
            ),
            rest
          ]
        in [{ type: :"{", location: start_location }, *rest]
          parse_object(rest, start_location)
        in [{ type: :false, location: }, *rest]
          [AST::False.new(location: location), rest]
        in [{ type: :true, location: }, *rest]
          [AST::True.new(location: location), rest]
        in [{ type: :null, location: }, *rest]
          [AST::Null.new(location: location), rest]
        in [{ type: :string, value:, location: }, *rest]
          [AST::String.new(value: value, location:), rest]
        in [{ type: :number, value:, location: }, *rest]
          [AST::Number.new(value: value, location: location), rest]
        else
          raise ParseError, "unexpected token: #{tokens.first&.type}"
        end
      end
    end
  end
end
