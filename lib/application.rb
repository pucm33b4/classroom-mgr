# frozen_string_literal: true

require_relative "command_factory"
require_relative "error_handler"
require_relative "input_parser"

class Application
  PARSE_ERROR = Object.new

  def initialize(command_factory = CommandFactory.new)
    @command_factory = command_factory
  end

  def start_system_loop
    loop do
      input = wait_input
      break if input.nil?

      parsed_input = parse_input(input)
      next if parsed_input.equal?(PARSE_ERROR)

      unless parsed_input
        ErrorHandler.print_error(ErrorHandler::ERROR_UNKNOWN_COMMAND)
        next
      end

      command = @command_factory.create(
        parsed_input.command_name,
        parsed_input.arguments,
        parsed_input.options
      )
      unless command
        ErrorHandler.print_error(ErrorHandler::ERROR_UNKNOWN_COMMAND)
        next
      end

      result = command.execute
      ErrorHandler.print_error(result.error_number) unless result.is_succeed
      stop_system if result.exit_flag
    end
  end

  def wait_input
    print ">"
    input = $stdin.gets
    return nil if input.nil?

    input.chomp
  end

  def stop_system
    exit
  end

  private

  def parse_input(input)
    InputParser.parse(input)
  rescue OptionParser::ParseError
    ErrorHandler.print_error(ErrorHandler::ERROR_UNKNOWN_OPTION)
    PARSE_ERROR
  rescue TypeError => e
    warn e.message
    PARSE_ERROR
  end
end
