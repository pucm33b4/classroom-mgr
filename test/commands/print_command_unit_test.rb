# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/print_command"

class PrintCommandTest < Minitest::Test
  def setup
    @may_first = PrintableLectureRoomManagementInformation.new(
      date: Date.new(2026, 5, 1),
      subject: "Math",
      label: "May first Math"
    )
    @may_second = PrintableLectureRoomManagementInformation.new(
      date: Date.new(2026, 5, 2),
      subject: "English",
      label: "May second English"
    )
    @repository = LectureRoomManagementInformationRepository.new([@may_first, @may_second])
  end

  def test_execute_when_information_is_not_found
    command = PrintCommand.new(LectureRoomManagementInformationRepository.new)

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND, result.error_number
  end

  def test_find_by_subject
    command = PrintCommand.new(@repository, nil, "Math")

    assert_equal [@may_first], command.find_by_subject(@repository.find_all)
  end

  def test_find_by_date
    command = PrintCommand.new(@repository, "0501", nil)

    assert_equal [@may_first], command.find_by_date(@repository.find_all)
  end

  def test_print_all
    command = PrintCommand.new(@repository)

    output, = capture_io do
      command.print_all([@may_first])
    end

    assert_equal "May first Math\n", output
  end

  def test_execute_prints_filtered_information
    command = PrintCommand.new(@repository, "0501", "Math")

    output, = capture_io do
      @result = command.execute
    end

    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    assert_equal "May first Math\n", output
  end
end
