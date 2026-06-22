# frozen_string_literal: true

require "optparse"
require "shellwords"

require_relative "parsed_input"

class InputParser
  COMMAND_NAMES = %w[read select create print write quit].freeze

  class << self
    def parse(input)
      raise TypeError, "input must be a String" unless input.is_a?(String)

      tokens = Shellwords.split(input)
      return nil if tokens.empty?

      command_name = tokens.shift
      return nil unless COMMAND_NAMES.include?(command_name)

      options = {}
      parser_for(command_name, options).parse!(tokens)
      validate_parsed_input(command_name, tokens, options)
      ParsedInput.new(command_name, tokens, options)
    end

    private

    def parser_for(command_name, options)
      OptionParser.new do |parser|
        case command_name
        when "create"
          parser.on("-t", "--term TERM") { |value| options[:term] = value }
        when "print"
          parser.on("-d", "--date MMDD") { |value| options[:finding_date] = value }
          parser.on("-s", "--subject SUBJECT") { |value| options[:finding_subject] = value }
        end
      end
    end

    def validate_parsed_input(command_name, arguments, options)
      case command_name
      when "read", "write"
        validate_argument_count(arguments, 0..1)
      when "create"
        validate_argument_count(arguments, 0..0)
        raise OptionParser::MissingArgument, "-t" unless options.key?(:term)

        Integer(options[:term])
      when "print", "select", "quit"
        validate_argument_count(arguments, 0..0)
      end
    rescue ArgumentError
      raise OptionParser::InvalidArgument, options[:term]
    end

    def validate_argument_count(arguments, range)
      return if range.cover?(arguments.length)

      raise OptionParser::InvalidArgument, arguments.join(" ")
    end
  end
end
