# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/select_command"

class SelectCommandTest < Minitest::Test
  def setup
    ExcelDataLoader.reset
    @managed_lecture_room_repository = ManagedLectureRoomInformationRepository.new
  end

  def test_execute_when_managed_lecture_room_file_is_not_found
    command = SelectCommand.new(@managed_lecture_room_repository, InteractiveMenu.new)

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND, result.error_number
  end

  def test_execute_when_user_accepts_managed_lecture_rooms
    informations = [OpenStruct.new(room_name: "Room A")]
    ExcelDataLoader.managed_lecture_room_workbook = [informations]
    command = SelectCommand.new(@managed_lecture_room_repository, InteractiveMenu.new(true))

    capture_io do
      @result = command.execute
    end

    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    assert_equal informations, @managed_lecture_room_repository.find_all
  end

  def test_execute_when_user_rejects_managed_lecture_rooms
    ExcelDataLoader.managed_lecture_room_workbook = [[OpenStruct.new(room_name: "Room A")]]
    command = SelectCommand.new(@managed_lecture_room_repository, InteractiveMenu.new(false))

    capture_io do
      @result = command.execute
    end

    assert_equal false, @result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED, @result.error_number
  end
end
