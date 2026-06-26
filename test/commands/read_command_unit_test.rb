# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/read_command"

class ReadCommandTest < Minitest::Test
  def setup
    ExcelDataLoader.reset
    @academic_calendar_repository = AcademicCalendarInformationRepository.new
    @timetable_repository = TimetableInformationRepository.new
    @reservation_repository = ReservationInformationRepository.new
  end

  def test_initialize_with_invalid_directory_path
    assert_raises(TypeError) do
      ReadCommand.new(
        @academic_calendar_repository,
        @timetable_repository,
        @reservation_repository,
        nil
      )
    end
  end

  def test_execute_without_directory_path
    command = ReadCommand.new(
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      ""
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_DIRECTORY_NOT_SPECIFIED, result.error_number
  end

  def test_execute_when_academic_calendar_file_is_not_found
    command = ReadCommand.new(
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      "2026"
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND, result.error_number
  end

  def test_execute_reads_all_input_data
    academic_calendar_informations = [OpenStruct.new(date: Date.new(2026, 4, 1), term: 1)]
    timetable_informations = [OpenStruct.new(term: 1)]
    reservation_informations = [OpenStruct.new(date: Date.new(2026, 4, 1))]
    ExcelDataLoader.academic_calendar_workbook = [academic_calendar_informations]
    ExcelDataLoader.timetable_workbook = [timetable_informations]
    ExcelDataLoader.reservation_workbook = [reservation_informations]
    command = ReadCommand.new(
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      "2026"
    )

    capture_io do
      @result = command.execute
    end

    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    assert_equal academic_calendar_informations, @academic_calendar_repository.find_all
    assert_equal timetable_informations, @timetable_repository.find_all
    assert_equal reservation_informations, @reservation_repository.find_all
  end
end
