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
          AST::Root.new(value: value)
        else
          raise ParseError, "unexpected tokens after value"
        end
      end

      private

      # This represents a parsed token from the source.
      class Token
        attr_reader :type, :value

        def initialize(type:, value: nil)
          @type = type
          @value = value
        end

        def deconstruct_keys(keys)
          { type: type, value: value }
        end
      end

      def make_tokens
        buffer = source.dup.force_encoding("UTF-8")
        raise ParseError, "invalid UTF-8" unless buffer.valid_encoding?

        tokens = []
        buffer.gsub!(/\A\s+/, "")

        until buffer.empty?
          tokens <<
            case buffer
            in /\A[\{\}\[\],:]/
              Token.new(type: $&.to_sym)
            in %r{\A-?(0|[1-9]\d*)(\.\d+)?([Ee][-+]?\d+)?}
              Token.new(type: :number, value: $&)
            in %r{\A"[^"\\\t\n\x00]*(?:\\[bfnrtu\\/"][^"\\]*)*"}
              Token.new(type: :string, value: $&)
            in /\Atrue/
              Token.new(type: :true)
            in /\Afalse/
              Token.new(type: :false)
            in /\Anull/
              Token.new(type: :null)
            else
              raise ParseError, "unexpected token: #{buffer[0]}"
            end

          buffer = $'.gsub(/\A\s+/, "")
        end

        tokens
      end

      def parse_array(tokens)
        values = []
      
        loop do
          value, tokens = parse_item(tokens)
          values << value
      
          case tokens
          in [Token[type: :"]"], *rest]
            return AST::Array.new(values: values), rest
          in [Token[type: :","], *rest]
            tokens = rest
          else
            raise ParseError, "expected ',' or ']' after array value"
          end
        end
      end
      
      def parse_object(tokens)
        values = {}
      
        loop do
          if tokens in [{ type: :string, value: key }, { type: :":" }, *tokens]
            value, tokens = parse_item(tokens)
            values[key] = value
        
            case tokens
            in [{ type: :"}" }, *rest]
              return AST::Object.new(values: values), rest
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
        case tokens
        in [{ type: :"[" }, { type: :"]" }, *rest]
          [AST::Array.new(values: []), rest]
        in [{ type: :"[" }, *rest]
          parse_array(rest)
        in [{ type: :"{" }, { type: :"}" }, *rest]
          [AST::Object.new(values: {}), rest]
        in [{ type: :"{" }, *rest]
          parse_object(rest)
        in [{ type: :false }, *rest]
          [AST::False.new, rest]
        in [{ type: :true }, *rest]
          [AST::True.new, rest]
        in [{ type: :null }, *rest]
          [AST::Null.new, rest]
        in [{ type: :string, value: value }, *rest]
          [AST::String.new(value: value), rest]
        in [{ type: :number, value: }, *rest]
          [AST::Number.new(value: value), rest]
        else
          raise ParseError, "unexpected token: #{tokens.first&.type}"
        end
      end
    end
  end
end
