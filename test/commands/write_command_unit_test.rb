# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/write_command"

class WriteCommandTest < Minitest::Test
  def setup
    @lecture_room_management_repository = LectureRoomManagementInformationRepository.new(
      [OpenStruct.new(label: "entry")]
    )
    @academic_calendar_repository = AcademicCalendarInformationRepository.new(
      [OpenStruct.new(date: Date.new(2026, 4, 1))]
    )
    @excel_data_exporter = ExcelDataExporter.new
  end

  def test_initialize_with_invalid_file_name
    assert_raises(TypeError) do
      WriteCommand.new(
        @lecture_room_management_repository,
        @academic_calendar_repository,
        @excel_data_exporter,
        nil
      )
    end
  end

  def test_execute_without_file_name
    command = WriteCommand.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @excel_data_exporter,
      ""
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_OUTPUT_FILE_NOT_SPECIFIED, result.error_number
  end

  def test_execute_when_lecture_room_management_information_is_not_found
    command = WriteCommand.new(
      LectureRoomManagementInformationRepository.new,
      @academic_calendar_repository,
      @excel_data_exporter,
      "output.xlsx"
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND, result.error_number
  end

  def test_execute_when_academic_calendar_is_not_loaded
    command = WriteCommand.new(
      @lecture_room_management_repository,
      AcademicCalendarInformationRepository.new,
      @excel_data_exporter,
      "output.xlsx"
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED, result.error_number
  end

  def test_execute_exports_workbook
    command = WriteCommand.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @excel_data_exporter,
      "output.xlsx"
    )

    capture_io do
      @result = command.execute
    end

    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    assert_equal "output.xlsx", @excel_data_exporter.file_name
    assert_equal @lecture_room_management_repository.find_all,
                 @excel_data_exporter.workbook[:lecture_room_management_informations]
  end
end
