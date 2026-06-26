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
    validate_integer(term, "term", allow_nil: true)

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
    @term = term
  end

  def execute
    return dummy_result unless repositories_ready?
    return dummy_result unless implemented_classes?("LectureRoomManagementInformationFactory", "InteractiveConflictResolutionService")

    managed_lecture_room_informations = @managed_lecture_room_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED) if managed_lecture_room_informations.empty?

    academic_calendar_informations = @academic_calendar_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED) if academic_calendar_informations.empty?

    timetable_informations = @timetable_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_NOT_LOADED) if timetable_informations.empty?

    reservation_informations = @reservation_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_NOT_LOADED) if reservation_informations.empty?

    if @term
      academic_calendar_informations, timetable_informations, reservation_informations =
        filter_by_term(academic_calendar_informations, timetable_informations, reservation_informations)
    end

    factory = LectureRoomManagementInformationFactory.new(academic_calendar_informations, managed_lecture_room_informations)
    created = factory.create_from_timetable_informations(timetable_informations) +
              factory.create_from_reservation_informations(reservation_informations)
    service = InteractiveConflictResolutionService.new(@interactive_menu)
    resolved = service.execute(created)
    @lecture_room_management_information_repository.replace_all(resolved)

    conflict_count = conflicts_count(service)
    if conflict_count.positive?
      puts "#{conflict_count}件の競合を解消しました．"
      puts "講義室管理情報を作成が完了しました．"
    else
      puts "講義室管理情報の作成が完了しました．"
    end
    success_result
  rescue StandardError
    dummy_result
  end

  private

  def repositories_ready?
    [
      @managed_lecture_room_information_repository,
      @academic_calendar_information_repository,
      @timetable_information_repository,
      @reservation_information_repository
    ].all? { |repository| repository_ready_for_read?(repository) } &&
      repository_ready_for_write?(@lecture_room_management_information_repository)
  end

  def filter_by_term(academic_calendar_informations, timetable_informations, reservation_informations)
    term_by_date = academic_calendar_informations.to_h { |information| [information.date, information.term] }
    [
      academic_calendar_informations.select { |information| information.term == @term },
      timetable_informations.select { |information| information.term == @term },
      reservation_informations.select { |information| term_by_date[information.date] == @term }
    ]
  end

  def conflicts_count(service)
    return 0 unless service.respond_to?(:conflicts)

    service.conflicts.size
  end
end
