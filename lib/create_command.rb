# frozen_string_literal: true

require_relative "command"

class CreateCommand < Command
  attr_reader :lecture_room_management_information_repository,
              :academic_calendar_information_repository,
              :timetable_information_repository,
              :reservation_information_repository,
              :managed_lecture_room_information_repository,
              :interactive_menu,
              :term

  def initialize(
    lecture_room_management_information_repository,
    academic_calendar_information_repository,
    timetable_information_repository,
    reservation_information_repository,
    managed_lecture_room_information_repository,
    interactive_menu,
    term
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
    validate_class_if_defined(
      timetable_information_repository,
      "TimetableInformationRepository",
      "timetable_information_repository"
    )
    validate_class_if_defined(
      reservation_information_repository,
      "ReservationInformationRepository",
      "reservation_information_repository"
    )
    validate_class_if_defined(
      managed_lecture_room_information_repository,
      "ManagedLectureRoomInformationRepository",
      "managed_lecture_room_information_repository"
    )
    validate_class_if_defined(interactive_menu, "InteractiveMenu", "interactive_menu")
    validate_integer(term, "term")

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
    @term = term
  end

  def execute
    dummy_result
  end
end
