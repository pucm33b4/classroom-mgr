# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/create_command"

class CreateCommandTest < Minitest::Test
  def setup
    @lecture_room_management_repository = LectureRoomManagementInformationRepository.new
    @academic_calendar_repository = AcademicCalendarInformationRepository.new(
      [OpenStruct.new(date: Date.new(2026, 4, 1), term: 1)]
    )
    @timetable_repository = TimetableInformationRepository.new(
      [OpenStruct.new(term: 1, label: "timetable")]
    )
    @reservation_repository = ReservationInformationRepository.new(
      [OpenStruct.new(date: Date.new(2026, 4, 1), label: "reservation")]
    )
    @managed_lecture_room_repository = ManagedLectureRoomInformationRepository.new(
      [OpenStruct.new(room_name: "Room A")]
    )
    @interactive_menu = InteractiveMenu.new
  end

  def test_initialize_with_invalid_term
    assert_raises(TypeError) do
      CreateCommand.new(
        @lecture_room_management_repository,
        @academic_calendar_repository,
        @timetable_repository,
        @reservation_repository,
        @managed_lecture_room_repository,
        @interactive_menu,
        "1"
      )
    end
  end

  def test_execute_when_managed_lecture_room_is_not_loaded
    @managed_lecture_room_repository = ManagedLectureRoomInformationRepository.new
    command = CreateCommand.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      @managed_lecture_room_repository,
      @interactive_menu,
      nil
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED, result.error_number
  end

  def test_execute_when_academic_calendar_is_not_loaded
    @academic_calendar_repository = AcademicCalendarInformationRepository.new
    command = CreateCommand.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      @managed_lecture_room_repository,
      @interactive_menu,
      nil
    )

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED, result.error_number
  end

  def test_execute_creates_lecture_room_management_informations
    command = CreateCommand.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      @managed_lecture_room_repository,
      @interactive_menu,
      nil
    )

    capture_io do
      @result = command.execute
    end

    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    assert_equal(
      @timetable_repository.find_all + @reservation_repository.find_all,
      @lecture_room_management_repository.find_all
    )
  end

  def test_execute_filters_by_term
    other_date = Date.new(2026, 9, 1)
    @academic_calendar_repository = AcademicCalendarInformationRepository.new(
      [
        OpenStruct.new(date: Date.new(2026, 4, 1), term: 1),
        OpenStruct.new(date: other_date, term: 2)
      ]
    )
    @timetable_repository = TimetableInformationRepository.new(
      [
        OpenStruct.new(term: 1, label: "first term timetable"),
        OpenStruct.new(term: 2, label: "second term timetable")
      ]
    )
    @reservation_repository = ReservationInformationRepository.new(
      [
        OpenStruct.new(date: Date.new(2026, 4, 1), label: "first term reservation"),
        OpenStruct.new(date: other_date, label: "second term reservation")
      ]
    )
    command = CreateCommand.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      @managed_lecture_room_repository,
      @interactive_menu,
      1
    )

    capture_io do
      @result = command.execute
    end

    assert_equal true, @result.is_succeed
    assert_equal ["first term timetable", "first term reservation"],
                 @lecture_room_management_repository.find_all.map(&:label)
  end
end
