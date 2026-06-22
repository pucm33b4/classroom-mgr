# frozen_string_literal: true

require_relative "command"

class ReadCommand < Command
  attr_reader :academic_calendar_information_repository,
              :timetable_information_repository,
              :reservation_information_repository,
              :directory_path

  def initialize(
    academic_calendar_information_repository,
    timetable_information_repository,
    reservation_information_repository,
    directory_path
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
    validate_string(directory_path, "directory_path")

    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @directory_path = directory_path
  end

  def execute
    return CommandResult.new(false, false, ErrorHandler::ERROR_DIRECTORY_NOT_SPECIFIED) if @directory_path.empty?

    dummy_result
  end
end
