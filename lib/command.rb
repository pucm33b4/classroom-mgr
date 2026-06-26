# frozen_string_literal: true

require_relative "command_result"
require_relative "error_handler"

class Command
  # コマンドが正常終了したときに返す共通の成功コード。
  SUCCESS = 0

  def execute
    # 親クラスのまま実行された場合は，未実装コマンドとして扱う。
    CommandResult.new(false, false, ErrorHandler::ERROR_COMMAND_NOT_IMPLEMENTED)
  end
end
