# frozen_string_literal: true

require_relative "command"

class WriteCommand < Command
  def initialize(
    lecture_room_management_information_repository,
    academic_calendar_information_repository,
    excel_data_exporter,
    file_name
  )
    if !lecture_room_management_information_repository.nil? &&
       Object.const_defined?("LectureRoomManagementInformationRepository") &&
       !lecture_room_management_information_repository.is_a?(Object.const_get("LectureRoomManagementInformationRepository"))
      raise TypeError, "lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository"
    end

    if !academic_calendar_information_repository.nil? &&
       Object.const_defined?("AcademicCalendarInformationRepository") &&
       !academic_calendar_information_repository.is_a?(Object.const_get("AcademicCalendarInformationRepository"))
      raise TypeError, "academic_calendar_information_repository must be an AcademicCalendarInformationRepository"
    end

    if !excel_data_exporter.nil? &&
       Object.const_defined?("ExcelDataExporter") &&
       !excel_data_exporter.is_a?(Object.const_get("ExcelDataExporter"))
      raise TypeError, "excel_data_exporter must be an ExcelDataExporter"
    end

    raise TypeError, "file_name must be a String" unless file_name.is_a?(String)

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @excel_data_exporter = excel_data_exporter
    @file_name = file_name
  end

  def execute
    return CommandResult.new(false, false, ErrorHandler::ERROR_OUTPUT_FILE_NOT_SPECIFIED) if @file_name.empty?

    unless @lecture_room_management_information_repository.respond_to?(:find_all) &&
           @academic_calendar_information_repository.respond_to?(:find_all) &&
           @excel_data_exporter.respond_to?(:export)
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    unless Object.const_defined?("LectureRoomManagementTableBuilder") &&
           Object.const_defined?("LectureRoomManagementTablePopulator")
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    lecture_room_management_informations = @lecture_room_management_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND) if lecture_room_management_informations.empty?

    academic_calendar_informations = @academic_calendar_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED) if academic_calendar_informations.empty?

    begin
      table =
        if LectureRoomManagementTableBuilder.respond_to?(:build)
          LectureRoomManagementTableBuilder.build(academic_calendar_informations)
        else
          LectureRoomManagementTableBuilder.new(academic_calendar_informations).build
        end

      populated_table = LectureRoomManagementTablePopulator.new(table).populate_entries(lecture_room_management_informations)
      workbook = populated_table || table
      workbook = workbook.workbook if workbook.respond_to?(:workbook)
      output_path = @excel_data_exporter.export(workbook, @file_name)
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    puts "講義室管理一覧表の作成が完了しました。"
    puts "出力先: #{output_path || @file_name}"
    CommandResult.new(false, true, SUCCESS)
  end
end
