# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/quit_command"

class QuitCommandTest < Minitest::Test
  def test_execute_returns_exit_result
    output, = capture_io do
      @result = QuitCommand.new.execute
    end

    assert_equal true, @result.exit_flag
    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    refute_empty output
  end
end
