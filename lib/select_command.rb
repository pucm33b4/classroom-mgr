# frozen_string_literal: true

require_relative "command"

class SelectCommand < Command
  DEFAULT_DIRECTORY_PATH = "data/管理対象講義室"

  def initialize(managed_lecture_room_information_repository, interactive_menu)
    # 管理対象講義室リポジトリと対話メニューが，他担当クラスとして定義済みなら型を確認する。
    if !managed_lecture_room_information_repository.nil? &&
       Object.const_defined?("ManagedLectureRoomInformationRepository") &&
       !managed_lecture_room_information_repository.is_a?(Object.const_get("ManagedLectureRoomInformationRepository"))
      raise TypeError, "managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository"
    end

    if !interactive_menu.nil? &&
       Object.const_defined?("InteractiveMenu") &&
       !interactive_menu.is_a?(Object.const_get("InteractiveMenu"))
      raise TypeError, "interactive_menu must be an InteractiveMenu"
    end

    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
  end

  def execute
    # 管理対象講義室の保存先と，利用者へ確認するためのメニューが使えるか確認する。
    unless @managed_lecture_room_information_repository.respond_to?(:replace_all) &&
           @interactive_menu.respond_to?(:ask_yes_or_no)
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    # XLSX読込と管理対象講義室Parserは他担当のため，未定義ならここで止める。
    unless Object.const_defined?("ExcelDataLoader") && Object.const_defined?("ManagedLectureRoomParser")
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    # 管理対象講義室XLSXを読み込む。
    begin
      load_method = ExcelDataLoader.method(:load_managed_lecture_room_xlsx_file)
      workbook = load_method.arity.zero? ? load_method.call : load_method.call(DEFAULT_DIRECTORY_PATH)
    rescue StandardError
      workbook = nil
    end
    return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND) if workbook.nil?

    # 読み込んだワークシートから管理対象講義室一覧を作る。
    begin
      informations = ManagedLectureRoomParser.new(workbook[0]).parse_managed_lecture_room_worksheet
      return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED) if informations.empty?
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED)
    end

    # 利用者が確認できるよう，読み込んだ講義室を表示する。
    puts "管理対象講義室データを読み込みました。"
    puts "----------"
    informations.each do |information|
      puts "- #{information.respond_to?(:room_name) ? information.room_name : information}"
    end
    puts "----------"

    # 表示内容を管理対象として採用するか，利用者に確認する。
    if @interactive_menu.ask_yes_or_no("表示されている講義室を管理対象としますか。")
      begin
        @managed_lecture_room_information_repository.replace_all(informations)
      rescue StandardError
        return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED)
      end

      puts "管理対象講義室の設定が完了しました。"
      return CommandResult.new(false, true, SUCCESS)
    end

    # 利用者が拒否した場合は，管理対象講義室を更新しない。
    CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED)
  end
end
