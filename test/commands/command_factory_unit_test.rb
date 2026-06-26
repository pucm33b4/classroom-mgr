# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/command_factory"

class CommandFactoryTest < Minitest::Test
  def setup
    @lecture_room_management_repository = LectureRoomManagementInformationRepository.new
    @academic_calendar_repository = AcademicCalendarInformationRepository.new
    @timetable_repository = TimetableInformationRepository.new
    @reservation_repository = ReservationInformationRepository.new
    @managed_lecture_room_repository = ManagedLectureRoomInformationRepository.new
    @interactive_menu = InteractiveMenu.new
    @excel_data_exporter = ExcelDataExporter.new
    @factory = CommandFactory.new(
      @lecture_room_management_repository,
      @academic_calendar_repository,
      @timetable_repository,
      @reservation_repository,
      @managed_lecture_room_repository,
      @interactive_menu,
      @excel_data_exporter
    )
  end

  def test_create_read_command
    assert_instance_of ReadCommand, @factory.create("read", ["2026"])
  end

  def test_create_select_command
    assert_instance_of SelectCommand, @factory.create("select")
  end

  def test_create_create_command
    command = @factory.create("create", [], { term: "1" })

    assert_instance_of CreateCommand, command
    assert_equal 1, command.instance_variable_get(:@term)
  end

  def test_create_print_command_with_date_option
    command = @factory.create("print", [], { date: "0501" })

    assert_instance_of PrintCommand, command
    assert_equal "0501", command.instance_variable_get(:@finding_date)
  end

  def test_create_print_command_with_subject_option
    command = @factory.create("print", [], { subject: "Math" })

    assert_instance_of PrintCommand, command
    assert_equal "Math", command.instance_variable_get(:@finding_subject)
  end

  def test_create_write_command
    assert_instance_of WriteCommand, @factory.create("write", ["output.xlsx"])
  end

  def test_create_quit_command
    assert_instance_of QuitCommand, @factory.create("quit")
  end

  def test_create_unknown_command
    assert_nil @factory.create("unknown")
  end

  def test_invalid_command_name
    assert_raises(TypeError) do
      @factory.create(:read)
    end
  end

  def test_invalid_arguments
    assert_raises(TypeError) do
      @factory.create("read", "2026")
    end
  end

  def test_invalid_options
    assert_raises(TypeError) do
      @factory.create("print", [], "-d")
    end
  end
end
