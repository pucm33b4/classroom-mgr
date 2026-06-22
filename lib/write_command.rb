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
    dummy_result
  end
end
