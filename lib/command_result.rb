# frozen_string_literal: true

class CommandResult
  attr_reader :exit_flag, :is_succeed, :error_number

  def initialize(exit_flag, is_succeed, error_number)
    raise TypeError, "exit_flag must be true or false" unless exit_flag == true || exit_flag == false
    raise TypeError, "is_succeed must be true or false" unless is_succeed == true || is_succeed == false
    raise TypeError, "error_number must be an Integer" unless error_number.is_a?(Integer)

    @exit_flag = exit_flag
    @is_succeed = is_succeed
    @error_number = error_number
  end
end
