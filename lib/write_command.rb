# frozen_string_literal: true

require_relative "command"

class WriteCommand < Command
  attr_reader :lecture_room_management_information_repository,
              :academic_calendar_information_repository,
              :excel_data_exporter,
              :file_name

  def initialize(
    lecture_room_management_information_repository,
    academic_calendar_information_repository,
    excel_data_exporter,
    file_name
  )
    validate_class_if_defined(
      lecture_room_management_information_repository,
      "LectureRoomManagementInformationRepository",
      "lecture_room_management_information_repository"
    )
    validate_class_if_defined(
      academic_calendar_information_repository,
      "AcademicCalendarInformationRepository",
      "academic_calendar_information_repository"
    )
    validate_class_if_defined(excel_data_exporter, "ExcelDataExporter", "excel_data_exporter")
    validate_string(file_name, "file_name")

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @excel_data_exporter = excel_data_exporter
    @file_name = file_name
  end

  def execute
    return CommandResult.new(false, false, ErrorHandler::ERROR_OUTPUT_FILE_NOT_SPECIFIED) if @file_name.empty?
    return dummy_result unless repository_ready_for_read?(@lecture_room_management_information_repository)
    return dummy_result unless repository_ready_for_read?(@academic_calendar_information_repository)
    return dummy_result unless @excel_data_exporter.respond_to?(:export)
    return dummy_result unless implemented_classes?("LectureRoomManagementTableBuilder", "LectureRoomManagementTablePopulator")

    lecture_room_management_informations = @lecture_room_management_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND) if lecture_room_management_informations.empty?

    academic_calendar_informations = @academic_calendar_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED) if academic_calendar_informations.empty?

    table = build_table(academic_calendar_informations)
    return table if table.is_a?(CommandResult)

    populated_workbook = populate_table(table, lecture_room_management_informations)
    output_path = @excel_data_exporter.export(extract_workbook(populated_workbook || table), @file_name)
    puts "講義室管理一覧表の作成が完了しました．"
    puts "出力先: #{output_path || @file_name}"
    success_result
  rescue StandardError
    dummy_result
  end

  private

  def build_table(academic_calendar_informations)
    if LectureRoomManagementTableBuilder.respond_to?(:build)
      return LectureRoomManagementTableBuilder.build(academic_calendar_informations)
    end

    LectureRoomManagementTableBuilder.new(academic_calendar_informations).build
  rescue ArgumentError
    dummy_result
  end

  def populate_table(table, lecture_room_management_informations)
    LectureRoomManagementTablePopulator.new(table).populate_entries(lecture_room_management_informations)
  end

  def extract_workbook(table)
    return table.workbook if table.respond_to?(:workbook)

    table
  end
end
