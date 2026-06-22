# frozen_string_literal: true

class ParsedInput
  attr_reader :command_name, :arguments, :options

  def initialize(command_name, arguments, options)
    raise TypeError, "command_name must be a String" unless command_name.is_a?(String)
    raise TypeError, "arguments must be an Array" unless arguments.is_a?(Array)
    raise TypeError, "options must be a Hash" unless options.is_a?(Hash)

    @command_name = command_name
    @arguments = arguments
    @options = options
  end
end
