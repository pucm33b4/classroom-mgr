# frozen_string_literal: true

require_relative "command"

class ReadCommand < Command
  def initialize(
    academic_calendar_information_repository,
    timetable_information_repository,
    reservation_information_repository,
    directory_path
  )
    if !academic_calendar_information_repository.nil? &&
       Object.const_defined?("AcademicCalendarInformationRepository") &&
       !academic_calendar_information_repository.is_a?(Object.const_get("AcademicCalendarInformationRepository"))
      raise TypeError, "academic_calendar_information_repository must be an AcademicCalendarInformationRepository"
    end

    if !timetable_information_repository.nil? &&
       Object.const_defined?("TimetableInformationRepository") &&
       !timetable_information_repository.is_a?(Object.const_get("TimetableInformationRepository"))
      raise TypeError, "timetable_information_repository must be a TimetableInformationRepository"
    end

    if !reservation_information_repository.nil? &&
       Object.const_defined?("ReservationInformationRepository") &&
       !reservation_information_repository.is_a?(Object.const_get("ReservationInformationRepository"))
      raise TypeError, "reservation_information_repository must be a ReservationInformationRepository"
    end

    raise TypeError, "directory_path must be a String" unless directory_path.is_a?(String)

    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @directory_path = directory_path
  end

  def execute
    return CommandResult.new(false, false, ErrorHandler::ERROR_DIRECTORY_NOT_SPECIFIED) if @directory_path.empty?

    unless @academic_calendar_information_repository.respond_to?(:replace_all) &&
           @timetable_information_repository.respond_to?(:replace_all) &&
           @reservation_information_repository.respond_to?(:replace_all)
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    unless Object.const_defined?("ExcelDataLoader") &&
           Object.const_defined?("AcademicCalendarParser") &&
           Object.const_defined?("TimetableParser") &&
           Object.const_defined?("ReservationParser")
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    begin
      academic_calendar_workbook = ExcelDataLoader.load_academic_calendar_xlsx_file(@directory_path)
    rescue StandardError
      academic_calendar_workbook = nil
    end
    return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND) if academic_calendar_workbook.nil?

    begin
      academic_calendar_informations =
        AcademicCalendarParser.new(academic_calendar_workbook[0]).parse_academic_calendar_worksheet
      return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_PARSE_FAILED) if academic_calendar_informations.empty?

      @academic_calendar_information_repository.replace_all(academic_calendar_informations)
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_PARSE_FAILED)
    end

    begin
      timetable_workbook =
        if ExcelDataLoader.respond_to?(:load_timetable_calendar_xlsx_file)
          ExcelDataLoader.load_timetable_calendar_xlsx_file(@directory_path)
        else
          ExcelDataLoader.load_timetable_xlsx_file(@directory_path)
        end
    rescue StandardError
      timetable_workbook = nil
    end
    return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_FILE_NOT_FOUND) if timetable_workbook.nil?

    begin
      timetable_informations = TimetableParser.new(timetable_workbook[0]).parse_timetable_worksheet
      return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_PARSE_FAILED) if timetable_informations.empty?

      @timetable_information_repository.replace_all(timetable_informations)
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_PARSE_FAILED)
    end

    begin
      reservation_workbook =
        if ExcelDataLoader.respond_to?(:load_reservation_calendar_xlsx_file)
          ExcelDataLoader.load_reservation_calendar_xlsx_file(@directory_path)
        else
          ExcelDataLoader.load_reservation_xlsx_file(@directory_path)
        end
    rescue StandardError
      reservation_workbook = nil
    end
    return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_FILE_NOT_FOUND) if reservation_workbook.nil?

    begin
      reservation_informations = ReservationParser.new(reservation_workbook[0]).parse_reservation_worksheet
      return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_PARSE_FAILED) if reservation_informations.empty?

      @reservation_information_repository.replace_all(reservation_informations)
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_PARSE_FAILED)
    end

    puts "入力データの読み込みが完了しました。"
    CommandResult.new(false, true, SUCCESS)
  end
end
