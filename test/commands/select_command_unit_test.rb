# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../lib/select_command"

class SelectCommandTest < Minitest::Test
  def setup
    @repository = ManagedLectureRoomInformationRepository.new
    @interactive_menu = InteractiveMenu.allocate
    @original_loader = ExcelDataLoader.method(:load_managed_lecture_room_xlsx_file)
    @original_parser_new = ManagedLectureRoomParser.method(:new)
    @original_dir_glob = Dir.method(:glob)
  end

  def teardown
    original_loader = @original_loader
    ExcelDataLoader.define_singleton_method(:load_managed_lecture_room_xlsx_file) do
      original_loader.call
    end

    original_parser_new = @original_parser_new
    ManagedLectureRoomParser.define_singleton_method(:new) do |worksheet|
      original_parser_new.call(worksheet)
    end

    original_dir_glob = @original_dir_glob
    Dir.define_singleton_method(:glob) do |*arguments, **keywords|
      original_dir_glob.call(*arguments, **keywords)
    end
  end

  def use_workbook(workbook)
    ExcelDataLoader.define_singleton_method(:load_managed_lecture_room_xlsx_file) do
      workbook
    end
  end

  def use_parser(parser)
    ManagedLectureRoomParser.define_singleton_method(:new) do |_worksheet|
      parser
    end
  end

  def use_xlsx_files(xlsx_files)
    Dir.define_singleton_method(:glob) do |_pattern|
      xlsx_files
    end
  end

  def test_initialize
    command = SelectCommand.new(@repository, @interactive_menu)

    assert_instance_of SelectCommand, command
  end

  def test_valid_lecture_room_names
    expected_names = [
      "1講",
      "第1講義室",
      "2講",
      "第2講義室",
      "4講",
      "第4講義室",
      "5講",
      "第5講義室",
      "10講",
      "第10講義室",
      "11講",
      "第11講義室",
      "14講",
      "第14講義室",
      "15講",
      "第15講義室",
      "17講",
      "第17講義室",
      "プログラミング演習室1",
      "プログラミング演習室2",
      "環104",
      "環104室",
      "自然大",
      "環101",
      "環101室",
      "303",
      "303室",
      "103",
      "103室",
      "一般B41",
      "一般B41室",
      "一般B33",
      "一般B33室",
      "コモンズ",
      "工大"
    ]

    assert_equal expected_names, SelectCommand::VALID_LECTURE_ROOM_NAMES
  end

  def test_initialize_rejects_invalid_repository
    assert_raises(TypeError) do
      SelectCommand.new(Object.new, @interactive_menu)
    end
  end

  def test_initialize_rejects_invalid_interactive_menu
    assert_raises(TypeError) do
      SelectCommand.new(@repository, Object.new)
    end
  end

  def test_execute_returns_error_when_workbook_is_not_found
    command = SelectCommand.new(@repository, @interactive_menu)
    use_workbook(nil)
    use_xlsx_files([])

    result = command.execute

    assert_equal false, result.exit_flag
    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND, result.error_number
  end

  def test_execute_returns_parse_error_when_multiple_workbooks_exist
    command = SelectCommand.new(@repository, @interactive_menu)
    use_workbook(nil)
    use_xlsx_files(["first.xlsx", "second.xlsx"])

    result = command.execute

    assert_equal false, result.exit_flag
    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED, result.error_number
  end

  def test_execute_returns_error_when_parsed_information_is_empty
    command = SelectCommand.new(@repository, @interactive_menu)
    parser = Object.new
    parser.define_singleton_method(:parse_managed_lecture_room_worksheet) { [] }
    use_workbook([Object.new])
    use_parser(parser)

    result = command.execute

    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED, result.error_number
  end

  def test_execute_returns_parse_error_when_room_name_is_not_valid
    informations = [
      ManagedLectureRoomInformation.new(room_name: "10講"),
      ManagedLectureRoomInformation.new(room_name: "存在しない講義室")
    ]
    parser = Object.new
    parser.define_singleton_method(:parse_managed_lecture_room_worksheet) { informations }
    @interactive_menu.define_singleton_method(:ask_yes_or_no) do |_message|
      raise "The confirmation menu must not be displayed"
    end
    command = SelectCommand.new(@repository, @interactive_menu)
    use_workbook([Object.new])
    use_parser(parser)

    result = command.execute

    assert_equal false, result.exit_flag
    assert_equal false, result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED, result.error_number
    assert_empty @repository.find_all
  end

  def test_execute_replaces_repository_when_user_selects_yes
    input_room_names = [
      "10講",
      "第１１講義室",
      "プログラミング演習室１",
      "環１０４室",
      "３０３室",
      "一般Ｂ４１室",
      "工大"
    ]
    informations = input_room_names.map do |room_name|
      ManagedLectureRoomInformation.new(room_name: room_name)
    end
    parser = Object.new
    parser.define_singleton_method(:parse_managed_lecture_room_worksheet) { informations }
    @interactive_menu.define_singleton_method(:ask_yes_or_no) do |message|
      @received_message = message
      true
    end
    command = SelectCommand.new(@repository, @interactive_menu)
    use_workbook([Object.new])
    use_parser(parser)

    output, = capture_io do
      @result = command.execute
    end

    assert_equal false, @result.exit_flag
    assert_equal true, @result.is_succeed
    assert_equal Command::SUCCESS, @result.error_number
    assert_equal informations, @repository.find_all
    assert_equal input_room_names, @repository.find_all.map(&:room_name)
    assert_equal "表示されている講義室を管理対象としますか？",
                 @interactive_menu.instance_variable_get(:@received_message)
    assert_includes output, "管理対象講義室の設定が完了しました．"
  end

  def test_execute_does_not_replace_repository_when_user_selects_no
    information = ManagedLectureRoomInformation.new(room_name: "10講")
    parser = Object.new
    parser.define_singleton_method(:parse_managed_lecture_room_worksheet) { [information] }
    @interactive_menu.define_singleton_method(:ask_yes_or_no) { |_message| false }
    command = SelectCommand.new(@repository, @interactive_menu)
    use_workbook([Object.new])
    use_parser(parser)

    capture_io do
      @result = command.execute
    end

    assert_equal false, @result.exit_flag
    assert_equal false, @result.is_succeed
    assert_equal ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED, @result.error_number
    assert_empty @repository.find_all
  end
end
