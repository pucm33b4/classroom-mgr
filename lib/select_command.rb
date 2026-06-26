# frozen_string_literal: true

require_relative "command"

class SelectCommand < Command
  DEFAULT_DIRECTORY_PATH = "data/管理対象講義室"

  def initialize(managed_lecture_room_information_repository, interactive_menu)
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
    unless @managed_lecture_room_information_repository.respond_to?(:replace_all) &&
           @interactive_menu.respond_to?(:ask_yes_or_no)
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    unless Object.const_defined?("ExcelDataLoader") && Object.const_defined?("ManagedLectureRoomParser")
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    begin
      load_method = ExcelDataLoader.method(:load_managed_lecture_room_xlsx_file)
      workbook = load_method.arity.zero? ? load_method.call : load_method.call(DEFAULT_DIRECTORY_PATH)
    rescue StandardError
      workbook = nil
    end
    return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND) if workbook.nil?

    begin
      informations = ManagedLectureRoomParser.new(workbook[0]).parse_managed_lecture_room_worksheet
      return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED) if informations.empty?
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED)
    end

    puts "管理対象講義室データを読み込みました。"
    puts "----------"
    informations.each do |information|
      puts "- #{information.respond_to?(:room_name) ? information.room_name : information}"
    end
    puts "----------"

    if @interactive_menu.ask_yes_or_no("表示されている講義室を管理対象としますか。")
      begin
        @managed_lecture_room_information_repository.replace_all(informations)
      rescue StandardError
        return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED)
      end

      puts "管理対象講義室の設定が完了しました。"
      return CommandResult.new(false, true, SUCCESS)
    end

    CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED)
  end
end
