# frozen_string_literal: true

module SyntaxTree
  module JSON
    # This class is responsible for converting from a plain string input into
    # an AST.
    class Parser
      attr_reader :source

      def initialize(source)
        @source = source
      end

      def parse
        parse_item(make_tokens) => [value, []]
        AST::Root.new(value: value)
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
        buffer = source.dup
        tokens = []

        until buffer.empty?
          tokens <<
            case buffer.strip
            in /\A[\{\}\[\],:]/
              Token.new(type: $&.to_sym)
            in /\A-?(0|[1-9]\d*)(\.\d+)?([Ee][-+]?\d+)?/
              Token.new(type: :number, value: $&)
            in /\A"[^"]*?"/
              Token.new(type: :string, value: $&)
            in /\Atrue/
              Token.new(type: :true)
            in /\Afalse/
              Token.new(type: :false)
            in /\Anull/
              Token.new(type: :null)
            end

          buffer = $'
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
          end
        end
      end
      
      def parse_object(tokens)
        values = {}
      
        loop do
          tokens => [Token[type: :string, value: key], Token[type: :":"], *tokens]
          value, tokens = parse_item(tokens)
          values[key] = value
      
          case tokens
          in [Token[type: :"}"], *rest]
            return AST::Object.new(values: values), rest
          in [Token[type: :","], *rest]
            tokens = rest
          end
        end
      end

      def parse_item(tokens)
        case tokens
        in [Token[type: :"["], Token[type: :"]"], *rest]
          [AST::Array.new(values: []), rest]
        in [Token[type: :"["], *rest]
          parse_array(rest)
        in [Token[type: :"{"], Token[type: :"}"], *rest]
          [AST::Object.new(values: {}), rest]
        in [Token[type: :"{"], *rest]
          parse_object(rest)
        in [Token[type: :false], *rest]
          [AST::False.new, rest]
        in [Token[type: :true], *rest]
          [AST::True.new, rest]
        in [Token[type: :null], *rest]
          [AST::Null.new, rest]
        in [Token[type: :string, value: value], *rest]
          [AST::String.new(value: value), rest]
        in [Token[type: :number, value:], *rest]
          [AST::Number.new(value: value), rest]
        end
      end
    end
  end
end
