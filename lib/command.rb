# frozen_string_literal: true

require_relative "command_result"
require_relative "error_handler"

class Command
  SUCCESS = 0

  def execute
    CommandResult.new(false, false, ErrorHandler::ERROR_COMMAND_NOT_IMPLEMENTED)
  end
end
