# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/command"

class CommandTest < Minitest::Test
  def test_execute_returns_not_implemented_result
    result = Command.new.execute

    assert_equal false, result.exit_flag
    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_COMMAND_NOT_IMPLEMENTED, result.error_number
  end
end
