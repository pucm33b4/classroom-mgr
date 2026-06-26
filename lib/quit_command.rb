# frozen_string_literal: true

require_relative "command"

class QuitCommand < Command
  def execute
    puts "システムが終了しました．"
    CommandResult.new(true, true, SUCCESS)
  end
end
