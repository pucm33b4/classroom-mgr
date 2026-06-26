# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/command_result"

class CommandResultTest < Minitest::Test
  def test_valid_initialization
    result = CommandResult.new(false, true, 0)

    assert_equal false, result.exit_flag
    assert_equal true, result.is_succeed
    assert_equal 0, result.error_number
  end

  def test_invalid_exit_flag
    assert_raises(TypeError) do
      CommandResult.new(nil, true, 0)
    end
  end

  def test_invalid_is_succeed
    assert_raises(TypeError) do
      CommandResult.new(false, nil, 0)
    end
  end

  def test_invalid_error_number
    assert_raises(TypeError) do
      CommandResult.new(false, true, "0")
    end
  end
end
