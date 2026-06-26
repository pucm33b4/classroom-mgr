# frozen_string_literal: true

require_relative "command"
require_relative "read_command"
require_relative "select_command"
require_relative "create_command"
require_relative "print_command"
require_relative "write_command"
require_relative "quit_command"

class CommandFactory
  attr_reader :lecture_room_management_information_repository,
              :academic_calendar_information_repository,
              :timetable_information_repository,
              :reservation_information_repository,
              :managed_lecture_room_information_repository,
              :interactive_menu,
              :excel_data_exporter

  def initialize(
    lecture_room_management_information_repository = nil,
    academic_calendar_information_repository = nil,
    timetable_information_repository = nil,
    reservation_information_repository = nil,
    managed_lecture_room_information_repository = nil,
    interactive_menu = nil,
    excel_data_exporter = nil
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
    validate_class_if_defined(excel_data_exporter, "ExcelDataExporter", "excel_data_exporter")

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
    @excel_data_exporter = excel_data_exporter
  end

  def create(command_name, arguments = [], options = {})
    validate_string(command_name, "command_name")
    validate_array(arguments, "arguments")
    validate_hash(options, "options")

    case command_name.downcase
    when "read"
      ReadCommand.new(
        @academic_calendar_information_repository,
        @timetable_information_repository,
        @reservation_information_repository,
        arguments[0].to_s
      )
    when "select"
      SelectCommand.new(@managed_lecture_room_information_repository, @interactive_menu)
    when "create"
      CreateCommand.new(
        @lecture_room_management_information_repository,
        @academic_calendar_information_repository,
        @timetable_information_repository,
        @reservation_information_repository,
        @managed_lecture_room_information_repository,
        @interactive_menu,
        integer_option(options, :term)
      )
    when "print"
      PrintCommand.new(
        @lecture_room_management_information_repository,
        string_option(options, :finding_date, :date),
        string_option(options, :finding_subject, :subject)
      )
    when "write"
      WriteCommand.new(
        @lecture_room_management_information_repository,
        @academic_calendar_information_repository,
        @excel_data_exporter,
        arguments[0].to_s
      )
    when "quit"
      QuitCommand.new
    else
      nil
    end
  end

  private

  def validate_string(value, name)
    return if value.is_a?(String)

    raise TypeError, "#{name} must be a String"
  end

  def validate_array(value, name)
    return if value.is_a?(Array)

    raise TypeError, "#{name} must be an Array"
  end

  def validate_hash(value, name)
    return if value.is_a?(Hash)

    raise TypeError, "#{name} must be a Hash"
  end

  def validate_class_if_defined(value, class_name, name, allow_nil: true)
    return if allow_nil && value.nil?

    klass = Object.const_get(class_name)
    return if value.is_a?(klass)

    raise TypeError, "#{name} must be a #{class_name}"
  rescue NameError
    nil
  end

  def string_option(options, *names)
    names.each do |name|
      value = option_value(options, name)
      return value.to_s unless value.nil?
    end

    nil
  end

  def integer_option(options, name)
    value = option_value(options, name)
    integer_argument(value)
  end

  def option_value(options, name)
    options[name] || options[name.to_s]
  end

  def integer_argument(value)
    return nil if value.nil?

    Integer(value)
  rescue ArgumentError, TypeError
    nil
  end
end
