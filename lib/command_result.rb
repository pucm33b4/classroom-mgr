# frozen_string_literal: true

class CommandResult
  attr_reader :exit_flag, :is_succeed, :error_number

  def initialize(exit_flag, is_succeed, error_number)
    validate_boolean(exit_flag, "exit_flag")
    validate_boolean(is_succeed, "is_succeed")
    validate_integer(error_number, "error_number")

    @exit_flag = exit_flag
    @is_succeed = is_succeed
    @error_number = error_number
  end

  private

  def validate_boolean(value, name)
    return if value == true || value == false

    raise TypeError, "#{name} must be true or false"
  end

  def validate_integer(value, name)
    return if value.is_a?(Integer)

    raise TypeError, "#{name} must be an Integer"
  end
end
