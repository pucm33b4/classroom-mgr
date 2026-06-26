# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/error_handler"

class ErrorHandlerTest < Minitest::Test
  def test_find_error_returns_message
    assert_instance_of String, ErrorHandler.find_error(ErrorHandler::ERROR_UNKNOWN_COMMAND)
  end

  def test_find_error_with_invalid_error_number
    assert_raises(TypeError) do
      ErrorHandler.find_error("1")
    end
  end

  def test_print_error_outputs_message
    message = ErrorHandler.find_error(ErrorHandler::ERROR_UNKNOWN_COMMAND)

    output, = capture_io do
      ErrorHandler.print_error(ErrorHandler::ERROR_UNKNOWN_COMMAND)
    end

    assert_equal "#{message}\n", output
  end

  def test_print_error_with_unknown_error_number
    assert_raises(KeyError) do
      ErrorHandler.print_error(999_999)
    end
  end
end
