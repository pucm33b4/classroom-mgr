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
    return dummy_result unless repositories_ready?
    return dummy_result unless implemented_classes?("ExcelDataLoader", "AcademicCalendarParser", "TimetableParser", "ReservationParser")

    academic_calendar_informations = load_academic_calendar_informations
    return academic_calendar_informations if academic_calendar_informations.is_a?(CommandResult)

    @academic_calendar_information_repository.replace_all(academic_calendar_informations)

    timetable_informations = load_timetable_informations
    return timetable_informations if timetable_informations.is_a?(CommandResult)

    @timetable_information_repository.replace_all(timetable_informations)

    reservation_informations = load_reservation_informations
    return reservation_informations if reservation_informations.is_a?(CommandResult)

    @reservation_information_repository.replace_all(reservation_informations)

    puts "入力データの読み込みが完了しました．"
    success_result
  end

  private

  def repositories_ready?
    [
      @academic_calendar_information_repository,
      @timetable_information_repository,
      @reservation_information_repository
    ].all? { |repository| repository_ready_for_write?(repository) }
  end

  def load_academic_calendar_informations
    workbook = load_workbook(:load_academic_calendar_xlsx_file)
    return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND) if workbook.nil?

    parse_workbook(workbook, AcademicCalendarParser, :parse_academic_calendar_worksheet, ErrorHandler::ERROR_ACADEMIC_CALENDAR_PARSE_FAILED)
  end

  def load_timetable_informations
    workbook = load_workbook(:load_timetable_calendar_xlsx_file, :load_timetable_xlsx_file)
    return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_FILE_NOT_FOUND) if workbook.nil?

    parse_workbook(workbook, TimetableParser, :parse_timetable_worksheet, ErrorHandler::ERROR_TIMETABLE_PARSE_FAILED)
  end

  def load_reservation_informations
    workbook = load_workbook(:load_reservation_calendar_xlsx_file, :load_reservation_xlsx_file)
    return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_FILE_NOT_FOUND) if workbook.nil?

    parse_workbook(workbook, ReservationParser, :parse_reservation_worksheet, ErrorHandler::ERROR_RESERVATION_PARSE_FAILED)
  end

  def load_workbook(*method_names)
    method_name = method_names.find { |candidate| ExcelDataLoader.respond_to?(candidate) }
    return nil if method_name.nil?

    ExcelDataLoader.public_send(method_name, @directory_path)
  rescue StandardError
    nil
  end

  def parse_workbook(workbook, parser_class, parser_method_name, error_number)
    informations = parser_class.new(workbook[0]).public_send(parser_method_name)
    return CommandResult.new(false, false, error_number) if informations.empty?

    informations
  rescue StandardError
    CommandResult.new(false, false, error_number)
  end
end
