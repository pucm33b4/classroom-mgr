# frozen_string_literal: true

require_relative "command"

class SelectCommand < Command
  DEFAULT_DIRECTORY_PATH = "data/管理対象講義室"

  attr_reader :managed_lecture_room_information_repository, :interactive_menu

  def initialize(managed_lecture_room_information_repository, interactive_menu)
    validate_class_if_defined(
      managed_lecture_room_information_repository,
      "ManagedLectureRoomInformationRepository",
      "managed_lecture_room_information_repository"
    )
    validate_class_if_defined(interactive_menu, "InteractiveMenu", "interactive_menu")

    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
  end

  def execute
    return dummy_result unless repository_ready_for_write?(@managed_lecture_room_information_repository)
    return dummy_result unless @interactive_menu.respond_to?(:ask_yes_or_no)
    return dummy_result unless implemented_classes?("ExcelDataLoader", "ManagedLectureRoomParser")

    workbook = load_managed_lecture_room_workbook
    return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND) if workbook.nil?

    informations = ManagedLectureRoomParser.new(workbook[0]).parse_managed_lecture_room_worksheet
    return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED) if informations.empty?

    puts "管理対象講義室データを読み込みました．"
    puts "----------"
    informations.each { |information| puts "- #{information.room_name}" }
    puts "----------"

    if @interactive_menu.ask_yes_or_no("表示されている講義室を管理対象としますか？")
      @managed_lecture_room_information_repository.replace_all(informations)
      puts "管理対象講義室の設定が完了しました．"
      return success_result
    end

    CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED)
  rescue StandardError
    CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED)
  end

  private

  def load_managed_lecture_room_workbook
    method = ExcelDataLoader.method(:load_managed_lecture_room_xlsx_file)
    return method.call if method.arity.zero?

    method.call(DEFAULT_DIRECTORY_PATH)
  rescue StandardError
    nil
  end
end
