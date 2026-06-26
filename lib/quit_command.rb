# frozen_string_literal: true

require_relative "command"

class QuitCommand < Command
  def execute
    # アプリケーション側がループを終了できるよう，exit_flagをtrueにして返す。
    puts "システムを終了しました。"
    CommandResult.new(true, true, SUCCESS)
  end
end
