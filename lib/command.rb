# frozen_string_literal: true

require_relative "command_result"
require_relative "error_handler"

class Command
  SUCCESS = 0

  def execute
    CommandResult.new(false, false, ErrorHandler::ERROR_COMMAND_NOT_IMPLEMENTED)
  end

  private

  def validate_string(value, name, allow_nil: false)
    return if allow_nil && value.nil?
    return if value.is_a?(String)

    raise TypeError, "#{name} must be a String"
  end

  def validate_integer(value, name, allow_nil: false)
    return if allow_nil && value.nil?
    return if value.is_a?(Integer)

    raise TypeError, "#{name} must be an Integer"
  end

  def validate_array(value, name, allow_nil: false)
    return if allow_nil && value.nil?
    return if value.is_a?(Array)

    raise TypeError, "#{name} must be an Array"
  end

  def validate_hash(value, name, allow_nil: false)
    return if allow_nil && value.nil?
    return if value.is_a?(Hash)

    raise TypeError, "#{name} must be a Hash"
  end

  def validate_class_if_defined(value, class_name, name, allow_nil: true)
    return if allow_nil && value.nil?

    klass = Object.const_get(class_name)
    return if value.is_a?(klass)

    raise TypeError, "#{name} must be a #{class_name}"
  rescue NameError
    nil
  end

  def dummy_result
    CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
  end
end
